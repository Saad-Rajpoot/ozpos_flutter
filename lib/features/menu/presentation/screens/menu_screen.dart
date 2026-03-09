import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/menu_category_entity.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/constants/app_responsive.dart';
import '../widgets/menu_item_card.dart';
import '../widgets/menu_item_list_tile.dart';
import '../widgets/menu_item_text_tile.dart';
import '../../../checkout/presentation/widgets/cart_pane.dart';
import '../../../checkout/presentation/bloc/cart_bloc.dart' as cart_bloc;
import '../../../../core/widgets/sidebar_nav.dart';
import '../bloc/menu_bloc.dart';
import '../bloc/menu_event.dart';
import '../bloc/menu_state.dart';
import '../../domain/entities/single_vendor_menu_entity.dart';
import '../../domain/entities/menu_schedule_entry.dart';
import 'menu_sections.dart';
import '../../../orders/presentation/widgets/order_alert_widget.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/domain/entities/order_item_entity.dart';
import '../../../../core/widgets/limit_reached_toast.dart';
import '../../../tables/domain/entities/table_entity.dart';

/// Menu Screen with Seed Data and Cart Integration
class MenuScreen extends StatefulWidget {
  final String? orderType;
  /// When navigating from Orders screen "Edit", passed by router so edit mode works reliably.
  final OrderEntity? editOrder;
  final String? editOrderId;
  final String? editOrderDisplayId;

  const MenuScreen({
    super.key,
    this.orderType,
    this.editOrder,
    this.editOrderId,
    this.editOrderDisplayId,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Timer? _searchDebounce;
  final TextEditingController _searchController = TextEditingController();

  /// Persists the last selected view so it survives navigation (same screen session).
  static bool _lastIsGridView = true;
  static bool _lastIsTextOnlyView = false;
  late bool _isGridView;
  late bool _isTextOnlyView;
  bool _editCartInitialized = false;
  String? _lastRequestedMenuType;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _menuSectionKeys = {};
  final GlobalKey _headerKey = GlobalKey();
  MenuVariantHeader? _visibleMenuVariant;
  Timer? _menuRefreshTimer;

  @override
  void initState() {
    super.initState();
    _isGridView = _lastIsGridView;
    _isTextOnlyView = _lastIsTextOnlyView;
    _scrollController.addListener(_handleScroll);

    // When the menu screen is first opened, immediately load the menu that
    // matches the currently selected order type (Dine-In / Pickup / Delivery)
    // in the shared CartBloc. This prevents an empty "No menu data" state
    // when there hasn't yet been an order-type change to trigger the listener
    // below.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final cartState = context.read<cart_bloc.CartBloc>().state;
      if (cartState is! cart_bloc.CartLoaded) return;

      String desiredMenuType;
      switch (cartState.orderType) {
        case cart_bloc.OrderType.delivery:
          desiredMenuType = 'delivery';
          break;
        case cart_bloc.OrderType.dineIn:
        case cart_bloc.OrderType.takeaway:
          desiredMenuType = 'pickup';
          break;
      }

      // Avoid double-fetching if something else already requested this type.
      if (_lastRequestedMenuType == desiredMenuType) return;
      _lastRequestedMenuType = desiredMenuType;
      context.read<MenuBloc>().add(FetchMenuEvent(menuType: desiredMenuType));
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Get category names for tabs - cached to avoid recreation when categories don't change
  List<String> _getCategoryNames(List<MenuCategoryEntity> categories) {
    // Since categories don't change often, this is reasonably efficient
    // Could be further optimized with memoization if categories change frequently
    return ['all', ...categories.map((cat) => cat.name)];
  }

  void _initializeCartForEditedOrder(OrderEntity order) {
    final cartBlocInstance = context.read<cart_bloc.CartBloc>();

    // Clear any existing items and set initial order type from the original order.
    cartBlocInstance.add(cart_bloc.ClearCart());
    final initialOrderType = switch (order.orderType) {
      OrderType.dinein => cart_bloc.OrderType.dineIn,
      OrderType.takeaway => cart_bloc.OrderType.takeaway,
      OrderType.delivery => cart_bloc.OrderType.delivery,
    };
    cartBlocInstance.add(
      cart_bloc.ChangeOrderType(orderType: initialOrderType),
    );

    // Preselect table for dine-in orders (shows in CartPane header).
    final tableNumber = order.tableNumber?.trim();
    if (initialOrderType == cart_bloc.OrderType.dineIn &&
        tableNumber != null &&
        tableNumber.isNotEmpty) {
      cartBlocInstance.add(
        cart_bloc.SelectTable(
          table: TableEntity(
            id: 'history-table-$tableNumber',
            number: tableNumber,
            seats: 0,
            status: TableStatus.occupied,
          ),
        ),
      );
    }

    for (var i = 0; i < order.items.length; i++) {
      final item = order.items[i];

      // Create a lightweight synthetic MenuItemEntity so the cart can display
      // and price items coming from history, even if they don't exactly match
      // the current menu payload.
      final syntheticMenuItem = MenuItemEntity(
        id: 'history-${order.id}-$i',
        categoryId: 'history',
        name: item.name,
        description: item.instructions ?? '',
        image: null,
        basePrice: item.price,
      );

      cartBlocInstance.add(
        cart_bloc.AddItemToCart(
          menuItem: syntheticMenuItem,
          quantity: item.quantity,
          unitPrice: item.price,
          selectedComboId: null,
          selectedModifiers: const <String, List<String>>{},
          modifierSummary:
              item.modifiers == null ? '' : item.modifiers!.join(', '),
          specialInstructions: item.instructions,
          activeMenuId: null,
        ),
      );
    }
  }

  void _handleScroll() {
    if (!mounted) return;
    final state = context.read<MenuBloc>().state;
    if (state is! MenuLoaded) return;
    if (state.variants.length <= 1) return;
    _updateVisibleMenuVariant(state);
  }

  void _updateVisibleMenuVariant(MenuLoaded state) {
    final headerBox =
        _headerKey.currentContext?.findRenderObject() as RenderBox?;
    if (headerBox == null || !headerBox.attached) return;

    final headerBottomGlobal =
        headerBox.localToGlobal(Offset(0, headerBox.size.height)).dy;

    MenuVariantHeader? closestVariant;
    double? closestDistance;

    for (final variant in state.variants) {
      final key = _menuSectionKeys[variant.id];
      final ctx = key?.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) continue;
      final pos = box.localToGlobal(Offset.zero);
      final dy = pos.dy;

      final distance = (dy - headerBottomGlobal).abs();
      if (closestDistance == null || distance < closestDistance) {
        closestDistance = distance;
        closestVariant = variant;
      }
    }

    if (closestVariant != null &&
        (_visibleMenuVariant == null ||
            _visibleMenuVariant!.id != closestVariant.id)) {
      setState(() {
        _visibleMenuVariant = closestVariant;
      });
    }
  }

  GlobalKey _getMenuSectionKey(String id) {
    return _menuSectionKeys[id] ??= GlobalKey();
  }

  void _scheduleNextMenuRefresh(MenuLoaded state) {
    // Cancel any previously scheduled refresh.
    _menuRefreshTimer?.cancel();
    _menuRefreshTimer = null;

    final seconds = state.secondsUntilNextScheduleChange;
    if (seconds == null || seconds <= 0) return;

    _menuRefreshTimer = Timer(Duration(seconds: seconds), () {
      if (!mounted) return;
      if (_lastRequestedMenuType == null) return;
      context
          .read<MenuBloc>()
          .add(FetchMenuEvent(menuType: _lastRequestedMenuType));
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width > AppConstants.desktopBreakpoint;

    // Prefer edit/orderType from widget (passed by router) so edit flow works reliably.
    // Fall back to route arguments for other entry points (e.g. deep links).
    final routeSettings = ModalRoute.of(context)?.settings;
    final args = routeSettings?.arguments;
    final Map<String, dynamic>? navigationArgs =
        args is Map<String, dynamic> ? args : null;
    final orderTypeString =
        widget.orderType ?? navigationArgs?['orderType'] as String?;
    final editingOrder =
        widget.editOrder ?? navigationArgs?['editOrder'] as OrderEntity?;
    final editingOrderDisplayId = widget.editOrderDisplayId ??
        navigationArgs?['editOrderDisplayId'] as String?;
    final cartBlocInstance = context.read<cart_bloc.CartBloc>();
    final cartState = cartBlocInstance.state;

    // If we are NOT in edit mode but the cart still contains synthetic
    // history-based items from a previous edit session, clear it once so
    // a fresh menu visit always starts with a clean cart.
    if (editingOrder == null &&
        cartState is cart_bloc.CartLoaded &&
        cartState.items.any((item) => item.id.startsWith('history-'))) {
      debugPrint(
        'MenuScreen: clearing leftover synthetic history-* cart items '
        'because we are not in edit mode.',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<cart_bloc.CartBloc>().add(cart_bloc.ClearCart());
      });
    }

    // Convert string to OrderType enum and update cart order type.
    // When editing an existing order, we DON'T force the order type from
    // navigation args so the user can freely switch between Dine-In/Pickup/Delivery.
    if (editingOrder == null &&
        orderTypeString != null &&
        orderTypeString.isNotEmpty) {
      cart_bloc.OrderType? orderType;
      switch (orderTypeString) {
        case 'takeaway':
          orderType = cart_bloc.OrderType.takeaway;
          break;
        case 'dine-in':
          orderType = cart_bloc.OrderType.dineIn;
          break;
        case 'delivery':
          orderType = cart_bloc.OrderType.delivery;
          break;
        default:
          // Log invalid order type for debugging
          debugPrint('Invalid order type received: $orderTypeString');
          break;
      }

      // Update the shared CartBloc's order type if specified and valid
      if (orderType != null) {
        final desiredOrderType = orderType;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          final latestState = context.read<cart_bloc.CartBloc>().state;
          if (latestState is cart_bloc.CartLoaded &&
              latestState.orderType == desiredOrderType) {
            return;
          }

          context.read<cart_bloc.CartBloc>().add(
                cart_bloc.ChangeOrderType(orderType: desiredOrderType),
              );
        });
      }
    }

    // If we navigated here to edit an existing Pay Later order, pre-populate
    // the cart with that order's items (once per screen lifetime).
    if (editingOrder != null && !_editCartInitialized) {
      _editCartInitialized = true;
      _initializeCartForEditedOrder(editingOrder);
    }

    return BlocListener<cart_bloc.CartBloc, cart_bloc.CartState>(
      listenWhen: (previous, current) {
        if (previous is cart_bloc.CartLoaded &&
            current is cart_bloc.CartLoaded) {
          return previous.orderType != current.orderType;
        }
        return previous.runtimeType != current.runtimeType;
      },
      listener: (context, cartState) {
        if (cartState is! cart_bloc.CartLoaded) return;

        String desiredMenuType;
        switch (cartState.orderType) {
          case cart_bloc.OrderType.delivery:
            desiredMenuType = 'delivery';
            break;
          case cart_bloc.OrderType.dineIn:
          case cart_bloc.OrderType.takeaway:
            desiredMenuType = 'pickup';
            break;
        }

        debugPrint(
          'MenuScreen: CartBloc orderType changed to '
          '${cartState.orderType}, requesting menuType=$desiredMenuType '
          '(lastRequested=$_lastRequestedMenuType)',
        );

        if (desiredMenuType == _lastRequestedMenuType) return;
        _lastRequestedMenuType = desiredMenuType;
        context.read<MenuBloc>().add(FetchMenuEvent(menuType: desiredMenuType));
      },
      child: ClampedTextScaling(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          endDrawer: !isDesktop
              ? Drawer(
                  width: MediaQuery.of(context).size.width * 0.85,
                  child: const CartPane(),
                )
              : null,
          body: Row(
            children: [
              // Left Sidebar (fixed 80dp) - always show on desktop
              if (context.isDesktopOrLarger)
                const SidebarNav(activeRoute: AppRouter.menu),

              // Main content (menu grid)
              Expanded(
                child: BlocListener<MenuBloc, MenuState>(
                  listenWhen: (_, curr) => curr is MenuLoaded,
                  listener: (context, menuState) {
                    if (menuState is! MenuLoaded) return;

                    // New menu payload (e.g. switching between pickup/delivery):
                    // clear any stale section/header state so DETAILS and the
                    // sticky header always reflect the current order type.
                    _visibleMenuVariant = null;
                    _menuSectionKeys.clear();

                    // Schedule a one-shot refresh at the next known schedule
                    // boundary (start or end) for this menu type so that menus
                    // and items appear/disappear at the correct times without
                    // polling.
                    _scheduleNextMenuRefresh(menuState);

                    // When editing an existing order, we intentionally keep
                    // all cart items (which are synthetic "history-*" items
                    // that may not exist in the current menu payload). In
                    // this mode we skip the automatic cart cleanup so the
                    // user can safely modify the original order.
                    if (editingOrder != null) {
                      debugPrint(
                        'MenuScreen: edit mode active for order '
                        '${editingOrder.id}, skipping cart cleanup on menu load.',
                      );
                      return;
                    }

                    final cartBlocInstance = context.read<cart_bloc.CartBloc>();
                    final cartState = cartBlocInstance.state;
                    if (cartState is! cart_bloc.CartLoaded) return;
                    if (cartState.items.isEmpty) return;

                    // 1) Remove individual line items whose menu items are no
                    // longer present in the current menu payload (e.g. because
                    // their menu window has ended).
                    final availableItemIds =
                        menuState.items.map((i) => i.id).toSet();
                    final expiredLineItems = cartState.items
                        .where(
                          (line) =>
                              !availableItemIds.contains(line.menuItem.id),
                        )
                        .toList();

                    if (expiredLineItems.isNotEmpty) {
                      debugPrint(
                        'MenuScreen: removing ${expiredLineItems.length} '
                        'cart line items not found in current menu payload. '
                        'activeMenuId=${menuState.activeMenuId}, '
                        'menuType=${menuState.menuType}, '
                        'availableItemCount=${menuState.items.length}',
                      );
                      for (final line in expiredLineItems) {
                        debugPrint(
                          '  - expired lineId=${line.id}, '
                          'menuItemId=${line.menuItem.id}, '
                          'name=${line.menuItem.name}',
                        );
                      }

                      for (final line in expiredLineItems) {
                        cartBlocInstance.add(
                          cart_bloc.RemoveLineItem(lineItemId: line.id),
                        );
                      }

                      if (context.mounted) {
                        LimitReachedToast.show(
                          context,
                          title: 'Items removed',
                          message:
                              'Some items are no longer available and were removed from your cart.',
                          backgroundColor: const Color(0xFFF59E0B),
                        );
                      }
                    }

                    // 2) As a safety net, if the active menu id itself changed
                    // (for example, schedule rollover to a completely different
                    // menu), clear any remaining items to avoid mixing menus.
                    final latestCartState = cartBlocInstance.state;
                    if (latestCartState is! cart_bloc.CartLoaded) return;
                    if (latestCartState.items.isEmpty) return;
                    if (latestCartState.activeMenuId == null) return;
                    if (latestCartState.activeMenuId == menuState.activeMenuId)
                      return;

                    debugPrint(
                      'MenuScreen: activeMenuId changed from '
                      '${latestCartState.activeMenuId} to '
                      '${menuState.activeMenuId}, clearing cart with '
                      '${latestCartState.items.length} items to avoid mixing menus.',
                    );

                    cartBlocInstance.add(cart_bloc.ClearCart());
                    if (context.mounted) {
                      LimitReachedToast.show(
                        context,
                        title: 'Cart cleared',
                        message:
                            'Menu has changed to ${menuState.menuName ?? "new schedule"}. Your cart has been cleared.',
                        backgroundColor: const Color(0xFFF59E0B),
                      );
                    }
                  },
                  child: BlocBuilder<MenuBloc, MenuState>(
                    buildWhen: (prev, curr) =>
                        prev.runtimeType != curr.runtimeType ||
                        (prev is MenuLoaded &&
                            curr is MenuLoaded &&
                            prev.menuName != curr.menuName),
                    builder: (context, state) {
                      return Column(
                        children: [
                          // Header
                          _buildHeader(
                            context,
                            state,
                            editingOrderDisplayId: editingOrderDisplayId,
                            visibleVariant: _visibleMenuVariant,
                          ),
                          // Search bar
                          _buildSearchBar(),
                          // List / Grid view toggle
                          _buildViewToggle(),
                          // Menu content with BLoC state management
                          Expanded(
                            child: BlocListener<MenuBloc, MenuState>(
                              listener: (context, state) {
                                // Handle error states
                                if (state is MenuError) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(state.message),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              },
                              child: Column(
                                children: [
                                  BlocBuilder<MenuBloc, MenuState>(
                                    buildWhen: (previous, current) {
                                      if (previous.runtimeType !=
                                          current.runtimeType) {
                                        return true;
                                      }

                                      if (previous is MenuLoaded &&
                                          current is MenuLoaded) {
                                        return previous.categories !=
                                                current.categories ||
                                            previous.selectedCategory !=
                                                current.selectedCategory ||
                                            previous.searchQuery !=
                                                current.searchQuery;
                                      }

                                      return false;
                                    },
                                    builder: (context, state) {
                                      if (state is MenuLoaded) {
                                        final categoryNames =
                                            _getCategoryNames(state.categories);
                                        return _buildCategoryTabs(
                                          categoryNames,
                                          state.categories,
                                          state,
                                        );
                                      }

                                      if (state is MenuLoading) {
                                        return const SizedBox(height: 50);
                                      }

                                      return const SizedBox.shrink();
                                    },
                                  ),
                                  Expanded(
                                    child: BlocBuilder<MenuBloc, MenuState>(
                                      buildWhen: (previous, current) {
                                        if (previous.runtimeType !=
                                            current.runtimeType) {
                                          return true;
                                        }

                                        if (previous is MenuLoaded &&
                                            current is MenuLoaded) {
                                          return previous.items !=
                                                  current.items ||
                                              previous.filteredItems !=
                                                  current.filteredItems;
                                        }

                                        return false;
                                      },
                                      builder: (context, state) {
                                        if (state is MenuLoading) {
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        }

                                        if (state is MenuError) {
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.error_outline,
                                                  size: 64,
                                                  color: Colors.red,
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  state.message,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    context.read<MenuBloc>().add(
                                                        const FetchMenuEvent());
                                                  },
                                                  child: const Text('Retry'),
                                                ),
                                              ],
                                            ),
                                          );
                                        }

                                        if (state is MenuLoaded) {
                                          final itemsToShow =
                                              state.filteredItems ??
                                                  state.items;
                                          final hasMultipleMenus =
                                              state.variants.length > 1;

                                          if (hasMultipleMenus) {
                                            // Clear and rebuild section keys when menu payload changes.
                                            _menuSectionKeys.clear();
                                            _visibleMenuVariant ??=
                                                state.variants.first;
                                          }

                                          if (_isGridView && !_isTextOnlyView) {
                                            return hasMultipleMenus
                                                ? _buildMultiMenuGrid(
                                                    state,
                                                    itemsToShow,
                                                  )
                                                : _buildMenuGrid(itemsToShow);
                                          } else if (_isTextOnlyView) {
                                            return hasMultipleMenus
                                                ? _buildMultiMenuListNoImage(
                                                    state,
                                                    itemsToShow,
                                                  )
                                                : _buildMenuListNoImage(
                                                    itemsToShow,
                                                  );
                                          } else {
                                            return hasMultipleMenus
                                                ? _buildMultiMenuList(
                                                    state,
                                                    itemsToShow,
                                                  )
                                                : _buildMenuList(itemsToShow);
                                          }
                                        }

                                        return const Center(
                                          child: Text('No menu data available'),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // Cart pane (desktop only)
              if (isDesktop) const CartPane(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    MenuState state, {
    String? editingOrderDisplayId,
    MenuVariantHeader? visibleVariant,
  }) {
    String menuName = 'Menu';
    String? scheduleTimeRange;

    if (state is MenuLoaded) {
      final variantToShow = visibleVariant ??
          state.variants.firstWhere(
            (v) => v.id == (state.activeMenuId ?? ''),
            orElse: () => state.variants.isNotEmpty
                ? state.variants.first
                : const MenuVariantHeader(id: '', name: ''),
          );

      if (variantToShow.id.isNotEmpty) {
        menuName = variantToShow.name;
        scheduleTimeRange =
            variantToShow.scheduleTimeRange ?? state.scheduleTimeRange;
      } else {
        if (state.menuName != null) {
          menuName = state.menuName!;
        }
        scheduleTimeRange = state.scheduleTimeRange;
      }
    }

    final displayName = menuName.toUpperCase();
    return Container(
      key: _headerKey,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant,
                size: 28,
                color: AppColors.error,
              ),
              const SizedBox(width: 10),
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (scheduleTimeRange != null &&
                  scheduleTimeRange.isNotEmpty) ...[
                const SizedBox(width: 12),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.textSecondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.access_time,
                    size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  scheduleTimeRange,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              const Spacer(),
              OutlinedButton(
                onPressed: state is MenuLoaded
                    ? () => _showMenuDetailsSheet(
                          context,
                          state,
                          visibleVariant: visibleVariant ?? _visibleMenuVariant,
                        )
                    : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('DETAILS'),
              ),
              const SizedBox(width: 12),
              // Demo Alert Buttons
              ElevatedButton(
                onPressed: () => _showDemoAlert(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Demo Alert',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (editingOrderDisplayId != null &&
              editingOrderDisplayId.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.04),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withOpacity(0.8),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.edit,
                    size: 16,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Editing order $editingOrderDisplayId',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(width: 8),
          // Cart icon with badge (mobile/tablet)
          if (MediaQuery.of(context).size.width <=
              AppConstants.desktopBreakpoint)
            BlocBuilder<cart_bloc.CartBloc, cart_bloc.CartState>(
              buildWhen: (previous, current) {
                // Always rebuild on state type changes
                if (previous.runtimeType != current.runtimeType) {
                  return true;
                }

                // For CartLoaded state, only rebuild if item count changes
                if (previous is cart_bloc.CartLoaded &&
                    current is cart_bloc.CartLoaded) {
                  return previous.itemCount != current.itemCount;
                }

                return false;
              },
              builder: (context, state) {
                final itemCount =
                    state is cart_bloc.CartLoaded ? state.itemCount : 0;
                return Stack(
                  children: [
                    IconButton(
                      onPressed: () => _showCartDrawer(context),
                      icon: const Icon(Icons.shopping_cart_outlined, size: 28),
                      color: const Color(0xFF111827),
                    ),
                    if (itemCount > 0)
                      Positioned(
                        right: 4,
                        top: 4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          child: Text(
                            '$itemCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMenuList(List<MenuItemEntity> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No menu items available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MenuItemListTile(item: item);
      },
    );
  }

  Widget _buildMenuListNoImage(List<MenuItemEntity> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No menu items available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MenuItemTextTile(item: item);
      },
    );
  }

  void _showMenuDetailsSheet(
    BuildContext context,
    MenuLoaded state, {
    MenuVariantHeader? visibleVariant,
  }) {
    showDialog<void>(
      context: context,
      builder: (ctx) => _MenuDetailsDialog(
        state: state,
        visibleVariant: visibleVariant,
      ),
    );
  }

  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Text(
            'View',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ViewToggleButton(
                  icon: Icons.grid_view_rounded,
                  isSelected: _isGridView && !_isTextOnlyView,
                  onTap: () {
                    _lastIsGridView = true;
                    _lastIsTextOnlyView = false;
                    setState(() {
                      _isGridView = true;
                      _isTextOnlyView = false;
                    });
                  },
                ),
                _ViewToggleButton(
                  icon: Icons.view_list_rounded,
                  isSelected: !_isGridView && !_isTextOnlyView,
                  onTap: () {
                    _lastIsGridView = false;
                    _lastIsTextOnlyView = false;
                    setState(() {
                      _isGridView = false;
                      _isTextOnlyView = false;
                    });
                  },
                ),
                _ViewToggleButton(
                  icon: Icons.view_headline_rounded,
                  isSelected: _isTextOnlyView,
                  onTap: () {
                    _lastIsGridView = false;
                    _lastIsTextOnlyView = true;
                    setState(() {
                      _isGridView = false;
                      _isTextOnlyView = true;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search menu items...',
          prefixIcon: const Icon(Icons.search, size: 20),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          // Cancel previous debounce timer
          _searchDebounce?.cancel();

          // Sanitize input
          final sanitized = value.trim();

          // Prevent excessive queries (max 100 characters)
          if (sanitized.length > 100) {
            return;
          }

          // Debounce search - wait 300ms after user stops typing
          _searchDebounce = Timer(AppConstants.searchDebounceDelay, () {
            if (mounted) {
              context.read<MenuBloc>().add(SearchMenuItems(query: sanitized));
            }
          });
        },
      ),
    );
  }

  Widget _buildCategoryTabs(List<String> categoryNames,
      List<MenuCategoryEntity> categories, MenuLoaded state) {
    return SizedBox(
      height: 50,
      width: double.infinity, // Ensure full width is available
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categoryNames.length,
        itemBuilder: (context, index) {
          final categoryName = categoryNames[index];
          final isAll = categoryName == 'all';
          final displayName = isAll ? 'All' : categoryName;

          // Check if this category is selected
          // "All" is selected when no filters are active (no selected category and no search)
          final isAllSelected =
              (state.selectedCategory == null && state.searchQuery == null);
          final isCategorySelected =
              (state.selectedCategory?.name == categoryName);

          final isSelected = isAll ? isAllSelected : isCategorySelected;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(displayName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected && !isAll) {
                  final category = categories.firstWhere(
                    (cat) => cat.name == categoryName,
                  );
                  context
                      .read<MenuBloc>()
                      .add(FilterByCategory(category: category));
                } else if (selected && isAll) {
                  context.read<MenuBloc>().add(const ClearFilters());
                }
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFEF4444),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF374151),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFD1D5DB),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuGrid(List<MenuItemEntity> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No menu items available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    double spacing;
    double childAspectRatio;
    int maxLines;

    // Responsive grid columns with proper aspect ratios to prevent overflow
    if (screenWidth > AppConstants.desktopBreakpoint * 1.4) {
      crossAxisCount = AppConstants.gridColumnsUltraWide;
      spacing = AppConstants.spacingLarge;
      childAspectRatio = 0.8; // Taller cards for more content
      maxLines = 3;
    } else if (screenWidth > AppConstants.desktopBreakpoint) {
      crossAxisCount = AppConstants.gridColumnsDesktop;
      spacing = AppConstants.spacingMedium;
      childAspectRatio = 0.8;
      maxLines = 3;
    } else if (screenWidth > AppConstants.tabletBreakpoint) {
      crossAxisCount = AppConstants.gridColumnsTablet;
      spacing = AppConstants.spacingMedium;
      maxLines = 2;
      childAspectRatio = 1.0;
    } else if (screenWidth > AppConstants.mobileBreakpoint) {
      crossAxisCount = AppConstants.gridColumnsMobile;
      spacing = AppConstants.spacingSmall * 1.5;
      maxLines = 2;
      childAspectRatio = 1.1;
    } else {
      crossAxisCount = AppConstants.gridColumnsMobile;
      spacing = AppConstants.spacingSmall * 1.5;
      maxLines = 1;
      childAspectRatio = 1.1; // More height for mobile
    }

    return GridView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MenuItemCard(
          maxLines: maxLines,
          item: item,
          onTap: () {
            final menuState = context.read<MenuBloc>().state;
            final activeMenuId =
                menuState is MenuLoaded ? menuState.activeMenuId : null;
            context.read<cart_bloc.CartBloc>().add(
                  cart_bloc.AddItemToCart(
                    menuItem: item,
                    quantity: 1,
                    unitPrice: item.basePrice,
                    selectedModifiers: {},
                    modifierSummary: '',
                    activeMenuId: activeMenuId,
                  ),
                );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added ${item.name} to cart'),
                duration: AppConstants.snackbarShortDuration,
                backgroundColor: AppColors.success,
              ),
            );
          },
        );
      },
    );
  }

  List<MenuSection> _buildMenuSections(
    MenuLoaded state,
    List<MenuItemEntity> itemsToShow,
  ) {
    if (itemsToShow.isEmpty) return const [];

    final categoriesById = <String, MenuCategoryEntity>{};
    for (final cat in state.categories) {
      categoriesById[cat.id] = cat;
    }

    final itemsByMenuId = <String?, List<MenuItemEntity>>{};
    for (final item in itemsToShow) {
      final category = categoriesById[item.categoryId];
      final menuId = category?.menuId;
      itemsByMenuId.putIfAbsent(menuId, () => <MenuItemEntity>[]).add(item);
    }

    final sections = <MenuSection>[];

    // First, add sections for known variants in their defined order.
    for (final variant in state.variants) {
      final items = itemsByMenuId.remove(variant.id);
      if (items == null || items.isEmpty) continue;
      sections.add(
        MenuSection(
          menuId: variant.id,
          variant: variant,
          items: items,
        ),
      );
    }

    // Any remaining items without a variant mapping go into a fallback section.
    for (final entry in itemsByMenuId.entries) {
      final items = entry.value;
      if (items.isEmpty) continue;
      sections.add(
        MenuSection(
          menuId: entry.key,
          variant: null,
          items: items,
        ),
      );
    }

    return sections;
  }

  Widget _buildMultiMenuList(MenuLoaded state, List<MenuItemEntity> items) {
    final sections = _buildMenuSections(state, items);
    if (sections.isEmpty) {
      return _buildMenuList(items);
    }

    final children = <Widget>[];

    for (final section in sections) {
      if (section.variant != null) {
        final key = _getMenuSectionKey(section.variant!.id);
        children.add(
          Container(
            key: key,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.borderLight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  section.variant!.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (section.variant!.scheduleTimeRange != null &&
                    section.variant!.scheduleTimeRange!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.access_time,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    section.variant!.scheduleTimeRange!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }

      for (final item in section.items) {
        children.add(MenuItemListTile(item: item));
      }
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: children,
    );
  }

  Widget _buildMultiMenuListNoImage(
    MenuLoaded state,
    List<MenuItemEntity> items,
  ) {
    final sections = _buildMenuSections(state, items);
    if (sections.isEmpty) {
      return _buildMenuListNoImage(items);
    }

    final children = <Widget>[];

    for (final section in sections) {
      if (section.variant != null) {
        final key = _getMenuSectionKey(section.variant!.id);
        children.add(
          Container(
            key: key,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.borderLight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  section.variant!.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (section.variant!.scheduleTimeRange != null &&
                    section.variant!.scheduleTimeRange!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.access_time,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    section.variant!.scheduleTimeRange!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }

      for (final item in section.items) {
        children.add(MenuItemTextTile(item: item));
      }
    }

    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: children,
    );
  }

  Widget _buildMultiMenuGrid(MenuLoaded state, List<MenuItemEntity> items) {
    final sections = _buildMenuSections(state, items);
    if (sections.isEmpty) {
      return _buildMenuGrid(items);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    double spacing;
    double childAspectRatio;
    int maxLines;

    if (screenWidth > AppConstants.desktopBreakpoint * 1.4) {
      crossAxisCount = AppConstants.gridColumnsUltraWide;
      spacing = AppConstants.spacingLarge;
      childAspectRatio = 0.8;
      maxLines = 3;
    } else if (screenWidth > AppConstants.desktopBreakpoint) {
      crossAxisCount = AppConstants.gridColumnsDesktop;
      spacing = AppConstants.spacingMedium;
      childAspectRatio = 0.8;
      maxLines = 3;
    } else if (screenWidth > AppConstants.tabletBreakpoint) {
      crossAxisCount = AppConstants.gridColumnsTablet;
      spacing = AppConstants.spacingMedium;
      maxLines = 2;
      childAspectRatio = 1.0;
    } else if (screenWidth > AppConstants.mobileBreakpoint) {
      crossAxisCount = AppConstants.gridColumnsMobile;
      spacing = AppConstants.spacingSmall * 1.5;
      maxLines = 2;
      childAspectRatio = 1.1;
    } else {
      crossAxisCount = AppConstants.gridColumnsMobile;
      spacing = AppConstants.spacingSmall * 1.5;
      maxLines = 1;
      childAspectRatio = 1.1;
    }

    final children = <Widget>[];

    for (final section in sections) {
      if (section.variant != null) {
        final key = _getMenuSectionKey(section.variant!.id);
        children.add(
          Container(
            key: key,
            margin: EdgeInsets.fromLTRB(spacing, spacing, spacing, spacing / 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  section.variant!.name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (section.variant!.scheduleTimeRange != null &&
                    section.variant!.scheduleTimeRange!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.access_time,
                      size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    section.variant!.scheduleTimeRange!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }

      children.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
            ),
            itemCount: section.items.length,
            itemBuilder: (context, index) {
              final item = section.items[index];
              return MenuItemCard(
                maxLines: maxLines,
                item: item,
                onTap: () {
                  final menuState = context.read<MenuBloc>().state;
                  final activeMenuId =
                      menuState is MenuLoaded ? menuState.activeMenuId : null;
                  context.read<cart_bloc.CartBloc>().add(
                        cart_bloc.AddItemToCart(
                          menuItem: item,
                          quantity: 1,
                          unitPrice: item.basePrice,
                          selectedModifiers: {},
                          modifierSummary: '',
                          activeMenuId: activeMenuId,
                        ),
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added ${item.name} to cart'),
                      duration: AppConstants.snackbarShortDuration,
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
              );
            },
          ),
        ),
      );
    }

    return ListView(
      controller: _scrollController,
      children: children,
    );
  }

  void _showCartDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void _showDemoAlert(BuildContext context) {
    // Create a demo order
    final demoOrder = OrderEntity(
      id: 'demo-8642',
      queueNumber: '8642',
      channel: OrderChannel.app,
      orderType: OrderType.takeaway,
      paymentStatus: PaymentStatus.unpaid,
      status: OrderStatus.active,
      displayStatus: 'UNPAID',
      customerName: 'Michael Brown',
      customerPhone: '+1234567890',
      items: const [
        OrderItemEntity(
          name: 'Classic Burger',
          quantity: 2,
          price: 12.99,
        ),
        OrderItemEntity(
          name: 'French Fries',
          quantity: 1,
          price: 4.99,
        ),
        OrderItemEntity(
          name: 'Coca-Cola',
          quantity: 2,
          price: 2.99,
        ),
      ],
      subtotal: 38.94,
      tax: 3.67,
      total: 42.61,
      createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
      estimatedTime: DateTime.now().add(const Duration(minutes: 30)),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OrderAlertWidget(
        order: demoOrder,
        onAccept: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order #8642 accepted!'),
              backgroundColor: AppColors.success,
            ),
          );
        },
        onReject: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order #8642 rejected'),
              backgroundColor: AppColors.error,
            ),
          );
        },
      ),
    );
  }
}

/// Toggle button for grid vs list view (icon only, selected state).
class _ViewToggleButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewToggleButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppColors.primary.withValues(alpha: 0.12)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Icon(
            icon,
            size: 22,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// Menu details dialog matching design: red header, menu card, opening hours.
class _MenuDetailsDialog extends StatelessWidget {
  final MenuLoaded state;
  final MenuVariantHeader? visibleVariant;

  const _MenuDetailsDialog({
    required this.state,
    this.visibleVariant,
  });

  @override
  Widget build(BuildContext context) {
    final variant = visibleVariant;
    final effectiveName = variant?.name ?? state.menuName ?? 'Menu';
    final menuName = effectiveName.toUpperCase();
    final subtitle = variant?.subtitle ?? state.menuSubtitle ?? '—';
    final version = state.menuVersion?.toString() ?? '—';
    final typeLabel = _formatMenuType(variant?.menuType ?? state.menuType);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Red header: MENU DETAILS + close button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              color: AppColors.error,
              child: Row(
                children: [
                  const Text(
                    'MENU DETAILS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close,
                          color: AppColors.error, size: 22),
                      padding: const EdgeInsets.all(6),
                      style: IconButton.styleFrom(
                        minimumSize: const Size(36, 36),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Menu info card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            menuName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _detailRow(context, 'Subtitle:', subtitle),
                          const SizedBox(height: 6),
                          _detailRow(context, 'Version:', version),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Type:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  typeLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // OPENING HOURS section
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'OPENING HOURS',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._buildOpeningHoursForDialog().map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: entry.isToday
                                  ? AppColors.error.withOpacity(0.08)
                                  : null,
                              borderRadius: BorderRadius.circular(24),
                              border: entry.isToday
                                  ? Border.all(
                                      color: AppColors.error,
                                      width: 1.5,
                                    )
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  entry.dayName,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: entry.isToday
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  entry.timeRange,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: entry.isToday
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<MenuScheduleEntry> _buildOpeningHoursForDialog() {
    final variantHours = visibleVariant?.openingHours;
    if (variantHours != null && variantHours.isNotEmpty) {
      return variantHours;
    }
    return state.openingHours;
  }

  Widget _detailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  String _formatMenuType(String? type) {
    if (type == null || type.isEmpty) return '—';
    switch (type.toLowerCase()) {
      case 'pickup':
        return 'PICKUP';
      case 'delivery':
        return 'DELIVERY';
      case 'dine_in':
        return 'DINE IN';
      default:
        return type.toUpperCase();
    }
  }
}
