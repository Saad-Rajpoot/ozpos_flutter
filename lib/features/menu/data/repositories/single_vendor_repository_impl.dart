import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../../../core/config/branch_tax_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/failures.dart';
import 'dart:convert';

import '../../../../core/network/network_info.dart';
import '../../../../core/db/menu_snapshot_dao.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/utils/repository_error_handler.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/dietary_label_entity.dart';
import '../../domain/entities/menu_category_entity.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/modifier_group_entity.dart';
import '../../domain/entities/modifier_option_entity.dart';
import '../../domain/entities/menu_schedule_entry.dart';
import '../../domain/entities/single_vendor_menu_entity.dart';
import '../../domain/repositories/single_vendor_repository.dart';
import '../datasources/single_vendor_remote_datasource.dart';
import '../models/single_vendor_response_model.dart';

class SingleVendorRepositoryImpl implements SingleVendorRepository {
  final SingleVendorRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;
  final NetworkInfo networkInfo;
  final MenuSnapshotDao menuSnapshotDao;

  SingleVendorRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
    required this.networkInfo,
    required this.menuSnapshotDao,
  });

  @override
  Future<Either<Failure, SingleVendorMenuEntity>> getSingleVendorMenu({
    String? menuType,
    String? menuId,
  }) async {
    final vendorUuid =
        sharedPreferences.getString(AppConstants.authVendorUuidKey);
    final branchUuid =
        sharedPreferences.getString(AppConstants.authBranchUuidKey);

    if (vendorUuid == null ||
        vendorUuid.isEmpty ||
        branchUuid == null ||
        branchUuid.isEmpty) {
      return const Left(
        AuthFailure(message: 'Session expired'),
      );
    }

    return RepositoryErrorHandler.handleOperation<SingleVendorMenuEntity>(
      operation: () async {
        final isConnected = await networkInfo.isConnected;

        if (isConnected) {
          // Online path: prefer live API result. Snapshot persistence
          // failures should not block the menu from loading.
          final response = await remoteDataSource.getSingleVendor(
            vendorUuid: vendorUuid,
            branchUuid: branchUuid,
          );

          try {
            await menuSnapshotDao.upsertSnapshot(
              vendorUuid: vendorUuid,
              branchUuid: branchUuid,
              payloadJson: jsonEncode(response.toJson()),
              version: response.meta?.version,
            );
          } catch (e) {
            debugPrint('Menu snapshot upsert failed: $e');
          }

          final entity = _mapToEntity(
            response,
            desiredMenuType: menuType,
            desiredMenuId: menuId,
          );
          final tzName = entity.timezone;
          if (tzName != null && tzName.isNotEmpty) {
            await sharedPreferences.setString(
              AppConstants.branchTimezoneKey,
              tzName,
            );
          }
          return entity;
        }

        // Offline: try to load last cached snapshot.
        final snapshot = await menuSnapshotDao.getSnapshot(
          vendorUuid: vendorUuid,
          branchUuid: branchUuid,
        );

        if (snapshot == null) {
          throw const ServerException(
            message: 'Unable to load menu offline',
          );
        }

        final payload = snapshot.payloadJson;
        final decodedJson = jsonDecode(payload) as Map<String, dynamic>;
        final decoded = SingleVendorResponseModel.fromJson(decodedJson);
        final entity = _mapToEntity(
          decoded,
          desiredMenuType: menuType,
          desiredMenuId: menuId,
        );
        final tzName = entity.timezone;
        if (tzName != null && tzName.isNotEmpty) {
          await sharedPreferences.setString(
            AppConstants.branchTimezoneKey,
            tzName,
          );
        }
        return entity;
      },
      networkInfo: networkInfo,
      operationName: 'loading menu',
      skipNetworkCheck: true,
    );
  }

  SingleVendorMenuEntity _mapToEntity(
    SingleVendorResponseModel response, {
    String? desiredMenuType,
    String? desiredMenuId,
  }) {
    final branch = response.data.branch;
    final menuV2 = branch.menuV2;

    // Update global branch tax config for cart/checkout
    final tax = branch.tax;
    if (tax != null) {
      BranchTaxConfigStore.instance.updateFromApi(
        taxEnable: tax.taxEnable,
        taxName: tax.taxName,
        taxType: tax.taxType,
        taxValue: tax.taxValue,
        taxInclusive: tax.taxInclusive,
      );
    } else {
      BranchTaxConfigStore.instance.clear();
    }

    if (menuV2.isEmpty) {
      return SingleVendorMenuEntity(
        menuName: branch.name ?? 'Menu',
        categories: const [],
        items: const [],
        timezone: branch.timezone,
      );
    }

    // Current time in branch timezone (API: day_of_week 1=Mon..7=Sun).
    final now = _nowInBranchTimezone(branch.timezone);

    // Determine which menus belong to the requested type (delivery/pickup).
    // When a type is requested, use only menus of that type (never fall back to
    // all menus). Additionally, include the "default" menu type everywhere so it
    // appears in Delivery, Pickup, and Dine-In.
    List<SingleVendorMenuV2Model> variantSource = menuV2;
    if (desiredMenuType != null && desiredMenuType.isNotEmpty) {
      final lowerDesired = desiredMenuType.toLowerCase();
      variantSource = menuV2
          .where(
            (m) {
              final t = (m.menuType ?? '').toLowerCase();
              return t == lowerDesired || t == 'default';
            },
          )
          .toList();
    }

    // No menus of the requested type at all (e.g. no delivery menus in response).
    if (variantSource.isEmpty) {
      return SingleVendorMenuEntity(
        menuName: branch.name ?? 'Menu',
        categories: const [],
        items: const [],
        activeMenuId: null,
        scheduleTimeRange: null,
        timezone: branch.timezone,
        menuSubtitle: null,
        menuVersion: null,
        menuType: desiredMenuType,
        openingHours: const [],
        variants: const [],
        secondsUntilNextScheduleChange: null,
      );
    }

    // Split menus into those that are currently active and those that are not,
    // and compute the next schedule boundary (start or end) across all of them.
    final activeVariantSource = <SingleVendorMenuV2Model>[];
    int? secondsUntilNextChange;

    for (final m in variantSource) {
      final isActive = _isMenuActiveNow(m, now);
      if (isActive) {
        activeVariantSource.add(m);
      }
      final menuNextChange = _secondsUntilNextScheduleChange(m, now);
      if (menuNextChange != null) {
        if (secondsUntilNextChange == null ||
            menuNextChange < secondsUntilNextChange) {
          secondsUntilNextChange = menuNextChange;
        }
      }
    }

    if (activeVariantSource.isEmpty) {
      // No active menus for this type at the current time: return an empty
      // payload so the UI shows no menu/items for this order type. We still
      // provide opening hours based on the first configured menu (if any) so
      // the DETAILS dialog can show schedule information, and we expose the
      // next schedule boundary so the UI can refresh exactly at that moment.
      final fallbackMenu = variantSource.first;
      final openingHours = _buildOpeningHours(fallbackMenu, now);

      return SingleVendorMenuEntity(
        menuName: branch.name ?? 'Menu',
        categories: const [],
        items: const [],
        activeMenuId: null,
        scheduleTimeRange: null,
        timezone: branch.timezone,
        menuSubtitle: null,
        menuVersion: null,
        menuType: desiredMenuType ?? fallbackMenu.menuType,
        openingHours: openingHours,
        variants: const [],
        secondsUntilNextScheduleChange: secondsUntilNextChange,
      );
    }

    // Pick the primary "active" menu (drives the top heading + DETAILS),
    // but categories/items below will be aggregated from *all* active menus in
    // [activeVariantSource].
    final menu = _selectMenu(
      activeVariantSource,
      now,
      desiredMenuType: desiredMenuType,
      desiredMenuId: desiredMenuId,
    );
    final scheduleRange = _getActiveScheduleTimeRange(menu, now);
    final openingHours = _buildOpeningHours(menu, now);

    // Flatten categories and items from all relevant active menus so the UI can
    // present one continuous list/grid covering every active menu while preserving
    // which concrete menu each category belongs to.
    final categories = <MenuCategoryEntity>[];
    final items = <MenuItemEntity>[];

    for (final m in activeVariantSource) {
      final mId = m.id ?? 0;
      final variantId = m.id?.toString() ?? m.ueExternalId ?? m.name ?? '';

      for (var catIndex = 0; catIndex < m.categories.length; catIndex++) {
        final cat = m.categories[catIndex];
        final catId = cat.ueExternalId ?? 'cat_${mId}_$catIndex';

        categories.add(MenuCategoryEntity(
          id: catId,
          name: cat.name ?? '',
          description: cat.description,
          image: cat.imageUrl,
          sortOrder: cat.sortOrder ?? 0,
          isActive: cat.isAvailable ?? true,
          createdAt: now,
          updatedAt: now,
          menuId: variantId.isEmpty ? null : variantId,
        ));

        for (var itemIndex = 0; itemIndex < cat.items.length; itemIndex++) {
          final it = cat.items[itemIndex];
          final itemId = it.sku ?? 'item_${mId}_${catIndex}_$itemIndex';

          items.add(MenuItemEntity(
            id: itemId,
            categoryId: catId,
            name: it.name ?? '',
            description: it.description ?? '',
            image: it.imageUrl,
            basePrice: it.priceAsDouble,
            calories: it.calories,
            tags: it.featured == true ? ['Popular'] : const [],
            modifierGroups: _mapModifierGroups(it.modifierGroups),
            comboOptions: const [],
            recommendedAddOnIds: const [],
            dietaryLabels: _mapDietaryLabels(it.dietaryLabels),
            allergens: _mapAllergens(it.allergens),
            ingredients: _mapIngredients(it.ingredients),
            additives: _mapAdditives(it.additives),
          ));
        }
      }
    }

    // Build lightweight headers for *all* menus of this type (variantSource),
    // not just the ones currently active, so the UI can show every delivery
    // menu that exists while still only showing items for active menus.
    final variants = <MenuVariantHeader>[];
    for (final m in variantSource) {
      final id = m.id?.toString() ?? m.ueExternalId ?? m.name ?? '';
      if (id.isEmpty) continue;
      final range = _getActiveScheduleTimeRange(m, now);
      final variantOpeningHours = _buildOpeningHours(m, now);
      variants.add(
        MenuVariantHeader(
          id: id,
          name: m.name ?? 'Menu',
          subtitle: m.subtitle,
          menuType: m.menuType,
          scheduleTimeRange: range,
          openingHours: variantOpeningHours,
        ),
      );
    }

    return SingleVendorMenuEntity(
      menuName: menu.name ?? branch.name ?? 'Menu',
      categories: categories,
      items: items,
      activeMenuId: menu.id?.toString() ?? menu.ueExternalId ?? menu.name,
      scheduleTimeRange: scheduleRange,
      timezone: branch.timezone,
      menuSubtitle: menu.subtitle,
      menuVersion: menu.version,
      menuType: menu.menuType,
      openingHours: openingHours,
      variants: variants,
      secondsUntilNextScheduleChange: secondsUntilNextChange,
    );
  }

  static const List<String> _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
  ];

  /// Builds opening hours list with today first (API day_of_week 1=Mon..7=Sun).
  List<MenuScheduleEntry> _buildOpeningHours(
    SingleVendorMenuV2Model menu,
    DateTime nowInBranchTz,
  ) {
    final schedules = menu.schedules;
    if (schedules == null || schedules.isEmpty) return [];

    final todayDow = nowInBranchTz.weekday; // 1..7
    final byDay = <int, SingleVendorSchedule>{};
    for (final s in schedules) {
      final dow = s.dayOfWeek;
      if (dow != null && dow >= 1 && dow <= 7) byDay[dow] = s;
    }

    final result = <MenuScheduleEntry>[];
    for (var i = 0; i < 7; i++) {
      final dow = (todayDow - 1 + i) % 7 + 1;
      final dayName = _dayNames[dow - 1];
      final isToday = dow == todayDow;
      final s = byDay[dow];
      final startStr = _formatTimeForDisplay(s?.startTime);
      final endStr = _formatTimeForDisplay(s?.endTime);
      final timeRange = (startStr != null && endStr != null)
          ? '$startStr - $endStr'
          : '—';
      result.add(MenuScheduleEntry(
        dayName: isToday ? '$dayName (Today)' : dayName,
        timeRange: timeRange,
        isToday: isToday,
      ));
    }
    return result;
  }

  /// Returns current date/time in branch timezone for schedule comparison.
  /// Uses branch's local weekday (1–7), hour and minute so menu schedules match API.
  DateTime _nowInBranchTimezone(String? timezoneName) {
    if (timezoneName == null || timezoneName.isEmpty) return DateTime.now();
    try {
      final location = tz.getLocation(timezoneName);
      final tzNow = tz.TZDateTime.now(location);
      return DateTime(
        tzNow.year,
        tzNow.month,
        tzNow.day,
        tzNow.hour,
        tzNow.minute,
        tzNow.second,
      );
    } catch (_) {
      return DateTime.now();
    }
  }

  /// Selects the concrete menu to use:
  /// 1. If [desiredMenuId] is provided, try to match by id / ue_external_id / name.
  /// 2. Otherwise, pick the first menu whose schedule matches [now] and, when
  ///    provided, whose [menuType] matches [desiredMenuType] (e.g. 'delivery', 'pickup').
  /// 3. Falls back to default/first menu if no exact match is found.
  SingleVendorMenuV2Model _selectMenu(
    List<SingleVendorMenuV2Model> menuV2,
    DateTime now, {
    String? desiredMenuType,
    String? desiredMenuId,
  }) {
    // Step 1: concrete menu id selection (used when user taps a specific menu pill).
    if (desiredMenuId != null && desiredMenuId.isNotEmpty) {
      final byId = menuV2.firstWhere(
        (m) =>
            m.id?.toString() == desiredMenuId ||
            m.ueExternalId == desiredMenuId ||
            m.name == desiredMenuId,
        orElse: () => menuV2.first,
      );
      return byId;
    }

    // Step 2: type + schedule-based selection (original behavior).
    List<SingleVendorMenuV2Model> candidates = menuV2;

    if (desiredMenuType != null && desiredMenuType.isNotEmpty) {
      final lowerDesired = desiredMenuType.toLowerCase();
      final filtered = menuV2
          .where(
            (m) => (m.menuType ?? '').toLowerCase() == lowerDesired,
          )
          .toList();
      if (filtered.isNotEmpty) {
        candidates = filtered;
      }
    }

    for (final m in candidates) {
      if (_isMenuActiveNow(m, now)) return m;
    }

    return candidates.firstWhere(
      (m) => m.isDefault == true,
      orElse: () => candidates.first,
    );
  }

  bool _isMenuActiveNow(SingleVendorMenuV2Model menu, DateTime now) {
    final schedules = menu.schedules;
    if (schedules == null || schedules.isEmpty) return false;
    // API day_of_week: 1=Monday .. 7=Sunday (same as Dart DateTime.weekday)
    final nowDow = now.weekday;
    final nowMinutes = now.hour * 60 + now.minute;
    for (final s in schedules) {
      final scheduleDow = s.dayOfWeek ?? -1;
      if (scheduleDow != nowDow) continue;
      final startM = _parseTimeToMinutes(s.startTime);
      final endM = _parseTimeToMinutes(s.endTime);
      if (startM == null || endM == null) continue;
      if (startM <= endM) {
        if (nowMinutes >= startM && nowMinutes < endM) return true;
      } else {
        if (nowMinutes >= startM || nowMinutes < endM) return true;
      }
    }
    return false;
  }

  /// Returns minutes since midnight (0-1439), or null if unparseable.
  int? _parseTimeToMinutes(String? time) {
    if (time == null || time.isEmpty) return null;
    final t = time.trim();
    final parts = t.split(RegExp(r'[:\s]'));
    if (parts.isEmpty) return null;
    int? h = int.tryParse(parts[0]);
    int m = 0;
    if (parts.length >= 2) m = int.tryParse(parts[1]) ?? 0;
    if (h == null) return null;
    if (parts.length >= 3) {
      final lower = parts[2].toLowerCase();
      if (lower == 'pm' && h < 12) h += 12;
      if (lower == 'am' && h == 12) h = 0;
    }
    if (h >= 24 || m >= 60) return null;
    return h * 60 + m;
  }

  /// Returns the number of seconds from [now] in branch timezone until the next
  /// schedule boundary (start or end) for [menu], or null if the menu has no
  /// schedules.
  int? _secondsUntilNextScheduleChange(
    SingleVendorMenuV2Model menu,
    DateTime now,
  ) {
    final schedules = menu.schedules;
    if (schedules == null || schedules.isEmpty) return null;

    final nowDow = now.weekday; // 1=Mon..7=Sun

    DateTime? earliestBoundary;

    for (final s in schedules) {
      final scheduleDow = s.dayOfWeek;
      if (scheduleDow == null || scheduleDow < 1 || scheduleDow > 7) continue;

      final startM = _parseTimeToMinutes(s.startTime);
      final endM = _parseTimeToMinutes(s.endTime);
      if (startM == null || endM == null) continue;

      // Helper to build the next occurrence (>= now) of a given day-of-week +
      // minutes-since-midnight combination.
      DateTime buildNext(int targetDow, int minutes) {
        final baseToday = DateTime(
          now.year,
          now.month,
          now.day,
        );
        final deltaDays = (targetDow - nowDow + 7) % 7;
        final candidateDay = baseToday.add(Duration(days: deltaDays));
        final candidate = candidateDay.add(Duration(minutes: minutes));
        if (candidate.isBefore(now)) {
          return candidate.add(const Duration(days: 7));
        }
        return candidate;
      }

      // For the start boundary
      final nextStart = buildNext(scheduleDow, startM);
      if (nextStart.isAfter(now)) {
        if (earliestBoundary == null || nextStart.isBefore(earliestBoundary)) {
          earliestBoundary = nextStart;
        }
      }

      // For the end boundary
      final nextEnd = buildNext(scheduleDow, endM);
      if (nextEnd.isAfter(now)) {
        if (earliestBoundary == null || nextEnd.isBefore(earliestBoundary)) {
          earliestBoundary = nextEnd;
        }
      }
    }

    if (earliestBoundary == null) return null;
    final diff = earliestBoundary.difference(now);
    final seconds = diff.inSeconds;
    return seconds <= 0 ? null : seconds;
  }

  String? _getActiveScheduleTimeRange(
    SingleVendorMenuV2Model menu,
    DateTime now,
  ) {
    final schedules = menu.schedules;
    if (schedules == null || schedules.isEmpty) return null;
    final nowDow = now.weekday; // 1=Mon .. 7=Sun, matches API day_of_week
    for (final s in schedules) {
      if (s.dayOfWeek != nowDow) continue;
      final startStr = _formatTimeForDisplay(s.startTime);
      final endStr = _formatTimeForDisplay(s.endTime);
      if (startStr != null && endStr != null) return '$startStr - $endStr';
    }
    return null;
  }

  String? _formatTimeForDisplay(String? time) {
    final m = _parseTimeToMinutes(time);
    if (m == null) return null;
    final h = m ~/ 60;
    final min = m % 60;
    if (h == 0) return '12:${min.toString().padLeft(2, '0')} AM';
    if (h == 12) return '12:${min.toString().padLeft(2, '0')} PM';
    if (h < 12) return '$h:${min.toString().padLeft(2, '0')} AM';
    return '${h - 12}:${min.toString().padLeft(2, '0')} PM';
  }

  List<ModifierGroupEntity> _mapModifierGroups(
    List<SingleVendorModifierGroup>? apiGroups, {
    String pathPrefix = '',
  }) {
    if (apiGroups == null || apiGroups.isEmpty) return const [];

    final sorted = List<SingleVendorModifierGroup>.from(apiGroups)
      ..sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));

    final result = <ModifierGroupEntity>[];
    for (var gIndex = 0; gIndex < sorted.length; gIndex++) {
      final g = sorted[gIndex];
      if (g.isAvailable == false) continue;

      final groupId = g.ueExternalId ?? 'modgrp_$gIndex';
      final fullGroupId = pathPrefix.isEmpty ? groupId : '$pathPrefix$groupId';

      final rule = g.quantityRule;
      final isRequired = rule?.isRequired ?? false;
      final minSel = rule?.minSelections ?? 0;
      final maxSel = rule?.maxSelections ?? 999;

      final options = <ModifierOptionEntity>[];
      final rawModifiers = g.modifiers ?? [];
      final modifiers = List<SingleVendorModifier>.from(rawModifiers)
        ..sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));
      var hasDefault = false;
      for (var oIndex = 0; oIndex < modifiers.length; oIndex++) {
        final m = modifiers[oIndex];
        if (m.isAvailable == false) continue;

        final optionId = m.ueExternalId ?? 'mod_${g.ueExternalId ?? gIndex}_$oIndex';
        final priceDelta = _parseModifierPrice(m.price, m.priceCents);
        final isDefault = isRequired && priceDelta == 0 && !hasDefault;
        if (isDefault) hasDefault = true;

        final nestedGroups = _mapModifierGroups(
          m.modifierGroups,
          pathPrefix: '$fullGroupId|$optionId|',
        );

        options.add(ModifierOptionEntity(
          id: optionId,
          name: m.name ?? '',
          priceDelta: priceDelta,
          calories: m.calories,
          isDefault: isDefault,
          nestedModifierGroups: nestedGroups,
        ));
      }

      if (options.isEmpty) continue;

      result.add(ModifierGroupEntity(
        id: fullGroupId,
        name: g.name ?? g.title ?? '',
        isRequired: isRequired,
        minSelection: minSel,
        maxSelection: maxSel,
        options: options,
      ));
    }
    return result;
  }

  double _parseModifierPrice(String? priceStr, int? priceCents) {
    if (priceCents != null) return priceCents / 100.0;
    final p = double.tryParse(priceStr ?? '');
    return p ?? 0.0;
  }

  List<DietaryLabelEntity> _mapDietaryLabels(List<dynamic>? raw) {
    if (raw == null || raw.isEmpty) return const [];
    final result = <DietaryLabelEntity>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final isAvailable = map['is_available'] ?? map['is_active'] ?? true;
      if (isAvailable == false) continue;
      final name = map['name'] as String? ?? '';
      if (name.isEmpty) continue;
      final hex = map['badge_color'] as String? ?? '#9E9E9E';
      result.add(DietaryLabelEntity(
        name: name,
        badgeColor: _parseHexColor(hex),
      ));
    }
    return result;
  }

  List<String> _mapAllergens(List<dynamic>? raw) {
    if (raw == null || raw.isEmpty) return const [];
    return raw
        .whereType<Map>()
        .map((m) => m['name'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  List<String> _mapIngredients(List<dynamic>? raw) {
    if (raw == null || raw.isEmpty) return const [];
    return raw
        .whereType<Map>()
        .map((m) => m['name'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  List<String> _mapAdditives(List<dynamic>? raw) {
    if (raw == null || raw.isEmpty) return const [];
    return raw
        .whereType<Map>()
        .map((m) => m['name'] as String? ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }

  Color _parseHexColor(String hex) {
    String h = hex.replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    final value = int.tryParse(h, radix: 16) ?? 0xFF9E9E9E;
    return Color(value);
  }
}
