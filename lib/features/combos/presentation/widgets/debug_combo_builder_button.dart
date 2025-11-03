import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/combo_management_bloc.dart';
import '../bloc/combo_management_event.dart';
import '../bloc/combo_management_state.dart';
import '../../domain/entities/combo_entity.dart';
import '../../domain/entities/combo_availability_entity.dart';
import '../../domain/entities/combo_limits_entity.dart';
import '../../domain/entities/combo_pricing_entity.dart';
import 'combo_builder_modal.dart';

class DebugComboBuilderButton extends StatefulWidget {
  const DebugComboBuilderButton({super.key});

  @override
  State<DebugComboBuilderButton> createState() =>
      _DebugComboBuilderButtonState();
}

class _DebugComboBuilderButtonState extends State<DebugComboBuilderButton> {
  bool _isHovering = false;
  ComboEntity? _savedCombo;

  @override
  Widget build(BuildContext context) {
    final gradientColors = _isHovering
        ? const [Color(0xFF16A34A), Color(0xFF047857)]
        : const [Color(0xFF22C55E), Color(0xFF10B981)];

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _showDebugDialog,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                '🔧 Debug Combo Builder',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDebugDialog() {
    final rootContext = context;

    showDialog<void>(
      context: rootContext,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (dialogContext) {
        return ComboBuilderDebugDialog(
          rootContext: rootContext,
          initialSavedCombo: _savedCombo,
          onSavedCombo: (combo) {
            setState(() => _savedCombo = combo);
          },
          onOpenBuilder: () => _openComboBuilder(rootContext),
        );
      },
    );
  }

  Future<void> _openComboBuilder(BuildContext rootContext) async {
    final comboBloc = rootContext.read<ComboManagementBloc>();
    comboBloc.add(const StartComboEdit());

    await showDialog<void>(
      context: rootContext,
      barrierDismissible: false,
      builder: (_) => const ComboBuilderModal(),
    );
  }
}

class ComboBuilderDebugDialog extends StatefulWidget {
  const ComboBuilderDebugDialog({
    required this.rootContext,
    required this.initialSavedCombo,
    required this.onSavedCombo,
    required this.onOpenBuilder,
    super.key,
  });

  final BuildContext rootContext;
  final ComboEntity? initialSavedCombo;
  final ValueChanged<ComboEntity?> onSavedCombo;
  final Future<void> Function() onOpenBuilder;

  @override
  State<ComboBuilderDebugDialog> createState() =>
      _ComboBuilderDebugDialogState();
}

class _ComboBuilderDebugDialogState extends State<ComboBuilderDebugDialog> {
  late ComboEntity? _savedCombo;

  static final List<_DebugMenuItem> _mockMenuItems = [
    _DebugMenuItem(
      id: 'burger-1',
      name: 'Classic Burger',
      price: 12.99,
      category: 'burgers',
      sizes: const ['Small', 'Medium', 'Large'],
      modifiers: const [
        _DebugModifier(id: 'mod-1', name: 'Extra Cheese'),
        _DebugModifier(id: 'mod-2', name: 'Extra Meat'),
        _DebugModifier(id: 'mod-3', name: 'No Pickles'),
        _DebugModifier(id: 'mod-4', name: 'Extra Bacon'),
      ],
    ),
    _DebugMenuItem(
      id: 'pizza-1',
      name: 'Margherita Pizza',
      price: 18.0,
      category: 'pizzas',
      sizes: const ['Small', 'Medium', 'Large', 'X-Large'],
      modifiers: const [
        _DebugModifier(id: 'mod-5', name: 'Extra Cheese'),
        _DebugModifier(id: 'mod-6', name: 'Olives'),
        _DebugModifier(id: 'mod-7', name: 'Mushrooms'),
      ],
    ),
    _DebugMenuItem(
      id: 'fries-1',
      name: 'French Fries',
      price: 5.0,
      category: 'sides',
      sizes: const ['Small', 'Medium', 'Large'],
      modifiers: const [],
    ),
    _DebugMenuItem(
      id: 'drink-1',
      name: 'Coca-Cola',
      price: 3.5,
      category: 'beverages',
      sizes: const ['Small', 'Medium', 'Large'],
      modifiers: const [],
    ),
    _DebugMenuItem(
      id: 'drink-2',
      name: 'Sprite',
      price: 3.5,
      category: 'beverages',
      sizes: const ['Small', 'Medium', 'Large'],
      modifiers: const [],
    ),
    _DebugMenuItem(
      id: 'dessert-1',
      name: 'Chocolate Cake',
      price: 6.5,
      category: 'desserts',
      sizes: const [],
      modifiers: const [
        _DebugModifier(id: 'mod-8', name: 'Extra Cream'),
        _DebugModifier(id: 'mod-9', name: 'Ice Cream'),
      ],
    ),
    _DebugMenuItem(
      id: 'dessert-2',
      name: 'Apple Pie',
      price: 5.5,
      category: 'desserts',
      sizes: const [],
      modifiers: const [
        _DebugModifier(id: 'mod-10', name: 'Ice Cream'),
      ],
    ),
  ];

  static final List<String> _categories = [
    'burgers',
    'pizzas',
    'sides',
    'beverages',
    'desserts',
  ];

  @override
  void initState() {
    super.initState();
    _savedCombo = widget.initialSavedCombo;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.transparent,
      child: BlocListener<ComboManagementBloc, ComboManagementState>(
        listenWhen: (previous, current) =>
            previous.lastSavedCombo != current.lastSavedCombo,
        listener: (context, state) {
          if (state.lastSavedCombo != null) {
            setState(() => _savedCombo = state.lastSavedCombo);
            widget.onSavedCombo(state.lastSavedCombo);
            _showSaveSnackBar();
          }
        },
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 24),
                      _buildCategoriesSection(),
                      const SizedBox(height: 24),
                      _buildItemsSection(),
                      const SizedBox(height: 24),
                      _buildActions(context),
                      if (_savedCombo != null) ...[
                        const SizedBox(height: 24),
                        _buildSavedComboSummary(_savedCombo!),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Combo Builder Debug Tool',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Use this to test the combo builder with proper mock data',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          tooltip: 'Close',
        ),
      ],
    );
  }

  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories
              .map(
                (category) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0369A1),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mock Menu Items',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 3.2,
          ),
          itemCount: _mockMenuItems.length,
          itemBuilder: (context, index) {
            final item = _mockMenuItems[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _buildItemMeta(item),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  String _buildItemMeta(_DebugMenuItem item) {
    final parts = <String>[
      _capitalize(item.category),
      '\$${item.price.toStringAsFixed(2)}',
      item.sizes.isEmpty
          ? 'No sizes'
          : '${item.sizes.length} size${item.sizes.length == 1 ? '' : 's'}',
      item.modifiers.isEmpty
          ? 'No modifiers'
          : '${item.modifiers.length} modifier${item.modifiers.length == 1 ? '' : 's'}',
    ];

    return parts.join(' \u2022 ');
  }

  Widget _buildActions(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 12,
      spacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close Debug'),
        ),
        if (_savedCombo != null)
          OutlinedButton(
            onPressed: _handleViewSavedCombo,
            child: const Text('View Saved Combo (Console)'),
          ),
        _GradientButton(
          label: 'Open Combo Builder',
          onPressed: _handleOpenComboBuilder,
        ),
      ],
    );
  }

  Future<void> _handleOpenComboBuilder() async {
    final openBuilder = widget.onOpenBuilder;
    final navigator = Navigator.of(widget.rootContext, rootNavigator: true);

    navigator.pop();
    await Future.microtask(() {});
    await openBuilder();
  }

  Widget _buildSavedComboSummary(ComboEntity combo) {
    final availability = combo.availability;
    final pricing = combo.pricing;
    final orderTypes =
        availability.orderTypes.map(_formatOrderType).toList(growable: false);
    final displayLocations = <String>[];
    if (availability.posSystem) displayLocations.add('POS System');
    if (availability.onlineMenu) displayLocations.add('Online Menu');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✅ Combo Saved Successfully!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF047857),
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
              'Combo Name', combo.name.isEmpty ? 'Untitled combo' : combo.name),
          _buildSummaryRow('Items Count', '${combo.slots.length} item(s)'),
          _buildSummaryRow(
            'Combo Price',
            '\$${pricing.finalPrice.toStringAsFixed(2)}',
          ),
          _buildSummaryRow(
            'Savings',
            pricing.savings > 0
                ? '\$${pricing.savings.toStringAsFixed(2)}'
                : 'No savings applied',
          ),
          if (displayLocations.isNotEmpty)
            _buildSummaryRow('Display Locations', displayLocations.join(', ')),
          if (orderTypes.isNotEmpty)
            _buildSummaryRow('Order Types', orderTypes.join(', ')),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF065F46),
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF065F46),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleViewSavedCombo() async {
    if (_savedCombo == null) return;

    final comboMap = _comboToDebugMap(_savedCombo!);
    debugPrint('Saved combo snapshot:');
    debugPrint(const JsonEncoder.withIndent('  ').convert(comboMap));

    final messenger = ScaffoldMessenger.maybeOf(widget.rootContext);
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Saved combo details logged to console'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSaveSnackBar() {
    final messenger = ScaffoldMessenger.maybeOf(widget.rootContext);
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Combo saved. Summary updated in debug tool.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Map<String, dynamic> _comboToDebugMap(ComboEntity combo) {
    return {
      'id': combo.id,
      'name': combo.name,
      'description': combo.description,
      'status': combo.status.name,
      'categoryTag': combo.categoryTag,
      'pointsReward': combo.pointsReward,
      'createdAt': combo.createdAt.toIso8601String(),
      'updatedAt': combo.updatedAt.toIso8601String(),
      'items': combo.slots
          .map(
            (slot) => {
              'id': slot.id,
              'name': slot.name,
              'sourceType': slot.sourceType.name,
              'specificItemIds': slot.specificItemIds,
              'specificItemNames': slot.specificItemNames,
              'categoryId': slot.categoryId,
              'categoryName': slot.categoryName,
              'required': slot.required,
              'defaultIncluded': slot.defaultIncluded,
              'allowQuantityChange': slot.allowQuantityChange,
              'maxQuantity': slot.maxQuantity,
              'defaultPrice': slot.defaultPrice,
              'allowedSizeIds': slot.allowedSizeIds,
              'defaultSizeId': slot.defaultSizeId,
              'modifierGroupAllowed': slot.modifierGroupAllowed,
              'modifierExclusions': slot.modifierExclusions,
              'sortOrder': slot.sortOrder,
            },
          )
          .toList(),
      'pricing': _pricingToMap(combo.pricing),
      'availability': _availabilityToMap(combo.availability),
      'limits': _limitsToMap(combo.limits),
    };
  }

  Map<String, dynamic> _pricingToMap(ComboPricingEntity pricing) {
    return {
      'mode': pricing.mode.name,
      'fixedPrice': pricing.fixedPrice,
      'percentOff': pricing.percentOff,
      'amountOff': pricing.amountOff,
      'mixCategoryId': pricing.mixCategoryId,
      'mixCategoryName': pricing.mixCategoryName,
      'mixQuantity': pricing.mixQuantity,
      'mixPrice': pricing.mixPrice,
      'mixPercentOff': pricing.mixPercentOff,
      'totalIndividualPrice': pricing.totalIfSeparate,
      'finalPrice': pricing.finalPrice,
      'savings': pricing.savings,
      'calculatedAt': pricing.calculatedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> _availabilityToMap(
      ComboAvailabilityEntity availability) {
    return {
      'displayLocations': {
        'pos': availability.posSystem,
        'online': availability.onlineMenu,
      },
      'orderTypes': availability.orderTypes.map((e) => e.name).toList(),
      'timeRestrictions': availability.timeWindows
          .map(
            (window) => {
              'id': window.id,
              'name': window.name,
              'start': window.startTime.formatted,
              'end': window.endTime.formatted,
            },
          )
          .toList(),
      'dayRestrictions':
          availability.daysOfWeek.map((day) => day.name).toList(),
      'dateRange': {
        'start': availability.startDate?.toIso8601String(),
        'end': availability.endDate?.toIso8601String(),
      },
    };
  }

  Map<String, dynamic> _limitsToMap(ComboLimitsEntity limits) {
    return {
      'maxPerOrder': limits.maxPerOrder,
      'maxPerDay': limits.maxPerDay,
      'maxPerCustomer': limits.maxPerCustomer,
      'customerLimitMinutes': limits.customerLimitPeriod?.inMinutes,
      'maxPerDevice': limits.maxPerDevice,
      'deviceLimitMinutes': limits.deviceLimitPeriod?.inMinutes,
      'allowStackingWithOtherPromos': limits.allowStackingWithOtherPromos,
      'allowStackingWithItemDiscounts': limits.allowStackingWithItemDiscounts,
      'excludeComboIds': limits.excludeComboIds,
      'autoApplyOnEligibility': limits.autoApplyOnEligibility,
      'showAsSuggestion': limits.showAsSuggestion,
      'allowedBranchIds': limits.allowedBranchIds,
      'excludedBranchIds': limits.excludedBranchIds,
    };
  }

  String _formatOrderType(OrderType type) {
    switch (type) {
      case OrderType.dineIn:
        return 'Dine In';
      case OrderType.takeaway:
        return 'Takeaway';
      case OrderType.delivery:
        return 'Delivery';
      case OrderType.online:
        return 'Online Order';
    }
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _GradientButton extends StatefulWidget {
  const _GradientButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final Future<void> Function() onPressed;

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> {
  bool _working = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ElevatedButton(
          onPressed: _working ? null : _handlePressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _working
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  widget.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _handlePressed() async {
    setState(() => _working = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) {
        setState(() => _working = false);
      }
    }
  }
}

class _DebugMenuItem {
  const _DebugMenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.sizes,
    required this.modifiers,
  });

  final String id;
  final String name;
  final double price;
  final String category;
  final List<String> sizes;
  final List<_DebugModifier> modifiers;
}

class _DebugModifier {
  const _DebugModifier({required this.id, required this.name});

  final String id;
  final String name;
}
