import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/addon_management_entities.dart';
import '../bloc/addon_management_bloc.dart';
import '../bloc/addon_management_event.dart';
import '../bloc/addon_management_state.dart';

/// Compact display of addon rules attached to a size or item
/// Shows blue expansion panels with edit capabilities
class AddonRulesCompactDisplay extends StatelessWidget {
  final String itemId;
  final String? sizeId;
  final String? sizeLabel;

  const AddonRulesCompactDisplay({
    super.key,
    required this.itemId,
    this.sizeId,
    this.sizeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddonManagementBloc, AddonManagementState>(
      builder: (context, state) {
        if (state is! AddonManagementLoaded) {
          return const SizedBox.shrink();
        }

        final effectiveRules = state.getEffectiveRules(itemId, sizeId);
        final hasSpecificRules =
            sizeId != null &&
            AddonRuleResolver.hasSpecificRules(
              itemId: itemId,
              sizeId: sizeId!,
              attachments: state.getItemAttachments(itemId),
            );

        final attachedCategoryIds = effectiveRules
            .map((r) => r.categoryId)
            .toSet();
        final availableCategories = state.categories
            .where((cat) => !attachedCategoryIds.contains(cat.id))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with helpful hint
            Row(
              children: [
                const Text(
                  'Add-on Sets',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message:
                      'Click on any available set below to add it. All items are included by default.',
                  child: Icon(
                    Icons.help_outline,
                    size: 16,
                    color: Colors.grey.shade500,
                  ),
                ),
                const Spacer(),
                if (hasSpecificRules)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber,
                          size: 12,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Overridden',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Show available sets first (if any)
            if (availableCategories.isNotEmpty) ...[
              _buildAvailableSetsSection(context, state, availableCategories),
              if (effectiveRules.isNotEmpty) const SizedBox(height: 16),
            ],

            // Show attached sets
            if (effectiveRules.isNotEmpty)
              _buildAttachedSetsList(
                context,
                state,
                effectiveRules,
                hasSpecificRules,
              )
            else if (availableCategories.isEmpty)
              _buildNoSetsAvailable(context),
          ],
        );
      },
    );
  }

  Widget _buildAvailableSetsSection(
    BuildContext context,
    AddonManagementLoaded state,
    List<AddonCategory> availableCategories,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.touch_app, size: 14, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Click on a set below to add it instantly',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableCategories.map((category) {
            return _buildAvailableSetChip(context, category);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAvailableSetChip(BuildContext context, AddonCategory category) {
    return InkWell(
      onTap: () => _attachCategoryWithAllItems(context, category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.add_circle_outline,
                size: 16,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  '${category.items.length} items',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSetsAvailable(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green.shade400,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'All available add-on sets have been added',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachedSetsList(
    BuildContext context,
    AddonManagementLoaded state,
    List<AddonRule> rules,
    bool hasOverrides,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 14,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Active Sets (${rules.length})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Tap to expand and edit',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (hasOverrides) _buildResetButton(context),
        ...rules.map((rule) => _buildExpandableRuleCard(context, state, rule)),
      ],
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton.icon(
        onPressed: () {
          context.read<AddonManagementBloc>().add(
            ResetSizeRulesToItemLevelEvent(itemId: itemId, sizeId: sizeId!),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reset to item-level rules'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.restore, size: 16),
        label: const Text('Reset to Item-Level'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.orange,
          side: BorderSide(color: Colors.orange.shade300),
        ),
      ),
    );
  }

  Widget _buildExpandableRuleCard(
    BuildContext context,
    AddonManagementLoaded state,
    AddonRule rule,
  ) {
    final category = state.getCategoryById(rule.categoryId);
    if (category == null) return const SizedBox.shrink();

    final validation = state.getValidation(itemId, rule.categoryId);
    final hasErrors = validation != null && !validation.isValid;
    final selectedCount = rule.defaultItemIds.length;
    final totalCount = category.items.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasErrors ? Colors.red.shade300 : Colors.blue.shade300,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: true, // Auto-expand for inline editing
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Icon(
              hasErrors ? Icons.error : Icons.category,
              size: 18,
              color: hasErrors ? Colors.red : Colors.blue.shade700,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$selectedCount of $totalCount items selected',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          color: Colors.red.shade400,
          tooltip: 'Remove this add-on set',
          onPressed: () => _removeAddonSet(context, category),
        ),
        children: [
          // Rules section at the top
          _buildRulesSection(context, rule),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Items section
          _buildItemsSection(context, state, category, rule),

          // Add items from category button
          const SizedBox(height: 12),
          _buildAddItemsButton(context, category, rule),
        ],
      ),
    );
  }

  Widget _buildRulesSection(BuildContext context, AddonRule rule) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rule, size: 14, color: Colors.grey.shade700),
              const SizedBox(width: 6),
              Text(
                'Selection Rules',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRuleField(
                  context,
                  label: 'Min',
                  value: rule.minSelection,
                  onChanged: (value) =>
                      _updateRule(context, rule.copyWith(minSelection: value)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRuleField(
                  context,
                  label: 'Max',
                  value: rule.maxSelection,
                  onChanged: (value) =>
                      _updateRule(context, rule.copyWith(maxSelection: value)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Required',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
            subtitle: Text(
              'Customer must select from this set',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
            value: rule.isRequired,
            activeThumbColor: Colors.red.shade600,
            onChanged: (value) =>
                _updateRule(context, rule.copyWith(isRequired: value)),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleField(
    BuildContext context, {
    required String label,
    required int value,
    required Function(int) onChanged,
  }) {
    final controller = TextEditingController(text: value.toString());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
            ),
          ),
          style: const TextStyle(fontSize: 13),
          onChanged: (text) {
            final newValue = int.tryParse(text);
            if (newValue != null && newValue >= 0) {
              onChanged(newValue);
            }
          },
        ),
      ],
    );
  }

  Widget _buildItemsSection(
    BuildContext context,
    AddonManagementLoaded state,
    AddonCategory category,
    AddonRule rule,
  ) {
    final validation = state.getValidation(itemId, rule.categoryId);
    final hasErrors = validation != null && !validation.isValid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list_alt, size: 14, color: Colors.grey.shade700),
            const SizedBox(width: 6),
            Text(
              'Selected Items',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const Spacer(),
            Text(
              '${rule.defaultItemIds.length} items',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ],
        ),
        if (hasErrors) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: validation.errors
                  .map(
                    (error) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 14,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              error,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.red.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 12),
        if (rule.defaultItemIds.isNotEmpty)
          ...rule.defaultItemIds.map((addonItemId) {
            final item = category.items.firstWhere(
              (i) => i.id == addonItemId,
              orElse: () =>
                  const AddonItem(id: '', name: 'Unknown', basePriceDelta: 0),
            );
            if (item.id.isEmpty) return const SizedBox.shrink();

            return _buildEditableItemCard(context, item, rule);
          })
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Center(
              child: Text(
                'No items selected. Add items below.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEditableItemCard(
    BuildContext context,
    AddonItem item,
    AddonRule rule,
  ) {
    final hasOverride = rule.priceOverrides.containsKey(item.id);
    final currentPrice = rule.priceOverrides[item.id] ?? item.basePriceDelta;
    final priceController = TextEditingController(
      text: currentPrice.toStringAsFixed(2),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasOverride ? Colors.orange.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: hasOverride ? Colors.orange.shade300 : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hasOverride)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Original: +\$${item.basePriceDelta.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: TextFormField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                prefixText: '\$',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
                ),
              ),
              style: const TextStyle(fontSize: 13),
              onChanged: (text) {
                final newPrice = double.tryParse(text);
                if (newPrice != null && newPrice >= 0) {
                  _updateItemPrice(context, rule, item.id, newPrice);
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: Colors.red.shade400,
            tooltip: 'Remove item',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _removeItemFromRule(context, rule, item.id),
          ),
        ],
      ),
    );
  }

  Widget _buildAddItemsButton(
    BuildContext context,
    AddonCategory category,
    AddonRule rule,
  ) {
    final unselectedItems = category.items
        .where((item) => !rule.defaultItemIds.contains(item.id))
        .toList();

    if (unselectedItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
            const SizedBox(width: 8),
            Text(
              'All items from this category are added',
              style: TextStyle(fontSize: 12, color: Colors.green.shade800),
            ),
          ],
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () =>
          _showAddItemsDialog(context, category, rule, unselectedItems),
      icon: const Icon(Icons.add, size: 16),
      label: Text('Add Items (${unselectedItems.length} available)'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.blue.shade700,
        side: BorderSide(color: Colors.blue.shade300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _attachCategoryWithAllItems(
    BuildContext context,
    AddonCategory category,
  ) {
    // Create rule with all items selected by default
    final allItemIds = category.items.map((item) => item.id).toList();

    // First attach the category
    context.read<AddonManagementBloc>().add(
      AttachAddonCategoryEvent(
        itemId: itemId,
        sizeId: sizeId,
        categoryId: category.id,
        appliesToAllSizes: sizeId == null,
      ),
    );

    // Wait a frame for the attachment to complete, then update with all items selected
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!context.mounted) return;

      final state = context.read<AddonManagementBloc>().state;
      if (state is! AddonManagementLoaded) return;

      final rules = state.getEffectiveRules(itemId, sizeId);
      final rule = rules.firstWhere(
        (r) => r.categoryId == category.id,
        orElse: () => throw Exception('Rule not found'),
      );

      // Update rule with all items selected
      context.read<AddonManagementBloc>().add(
        UpdateAddonRuleEvent(
          itemId: itemId,
          sizeId: sizeId,
          rule: rule.copyWith(defaultItemIds: allItemIds),
        ),
      );
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${category.name} added with ${category.items.length} items',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _updateRule(BuildContext context, AddonRule rule) {
    context.read<AddonManagementBloc>().add(
      UpdateAddonRuleEvent(itemId: itemId, sizeId: sizeId, rule: rule),
    );
  }

  void _updateItemPrice(
    BuildContext context,
    AddonRule rule,
    String addonItemId,
    double newPrice,
  ) {
    final newOverrides = Map<String, double>.from(rule.priceOverrides);
    final item = context.read<AddonManagementBloc>().state;
    if (item is AddonManagementLoaded) {
      final category = item.getCategoryById(rule.categoryId);
      if (category != null) {
        final addonItem = category.items.firstWhere(
          (i) => i.id == addonItemId,
          orElse: () => const AddonItem(id: '', name: '', basePriceDelta: 0),
        );

        // If price matches base price, remove override
        if ((newPrice - addonItem.basePriceDelta).abs() < 0.01) {
          newOverrides.remove(addonItemId);
        } else {
          newOverrides[addonItemId] = newPrice;
        }
      }
    }

    context.read<AddonManagementBloc>().add(
      UpdateAddonRuleEvent(
        itemId: itemId,
        sizeId: sizeId,
        rule: rule.copyWith(priceOverrides: newOverrides),
      ),
    );
  }

  void _removeItemFromRule(
    BuildContext context,
    AddonRule rule,
    String addonItemId,
  ) {
    final newItemIds = rule.defaultItemIds
        .where((id) => id != addonItemId)
        .toList();
    final newOverrides = Map<String, double>.from(rule.priceOverrides)
      ..remove(addonItemId);

    context.read<AddonManagementBloc>().add(
      UpdateAddonRuleEvent(
        itemId: itemId,
        sizeId: sizeId,
        rule: rule.copyWith(
          defaultItemIds: newItemIds,
          priceOverrides: newOverrides,
        ),
      ),
    );
  }

  void _removeAddonSet(BuildContext context, AddonCategory category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove Add-on Set'),
        content: Text('Remove "${category.name}" from this item/size?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AddonManagementBloc>().add(
                RemoveAddonCategoryEvent(
                  itemId: itemId,
                  sizeId: sizeId,
                  categoryId: category.id,
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${category.name} removed'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showAddItemsDialog(
    BuildContext context,
    AddonCategory category,
    AddonRule rule,
    List<AddonItem> availableItems,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Add Items to ${category.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableItems.length,
            itemBuilder: (context, index) {
              final item = availableItems[index];
              return ListTile(
                dense: true,
                title: Text(item.name),
                subtitle: Text('+\$${item.basePriceDelta.toStringAsFixed(2)}'),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _addItemToRule(context, rule, item.id);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _addItemToRule(
    BuildContext context,
    AddonRule rule,
    String addonItemId,
  ) {
    final newItemIds = [...rule.defaultItemIds, addonItemId];

    context.read<AddonManagementBloc>().add(
      UpdateAddonRuleEvent(
        itemId: itemId,
        sizeId: sizeId,
        rule: rule.copyWith(defaultItemIds: newItemIds),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item added'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
