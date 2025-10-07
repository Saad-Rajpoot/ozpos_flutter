import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/addon_management_entities.dart';
import '../bloc/addon_management_bloc.dart';
import '../bloc/addon_management_event.dart';
import '../bloc/addon_management_state.dart';

/// Dialog for configuring addon items within a category
class AddonItemSelectorDialog extends StatefulWidget {
  final String itemId;
  final String? sizeId;
  final String categoryId;
  final String categoryName;

  const AddonItemSelectorDialog({
    Key? key,
    required this.itemId,
    this.sizeId,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  State<AddonItemSelectorDialog> createState() =>
      _AddonItemSelectorDialogState();

  static Future<void> show({
    required BuildContext context,
    required String itemId,
    String? sizeId,
    required String categoryId,
    required String categoryName,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AddonManagementBloc>(),
        child: AddonItemSelectorDialog(
          itemId: itemId,
          sizeId: sizeId,
          categoryId: categoryId,
          categoryName: categoryName,
        ),
      ),
    );
  }
}

class _AddonItemSelectorDialogState extends State<AddonItemSelectorDialog> {
  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();
  bool _isRequired = false;
  String _searchQuery = '';

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(24),
        child: BlocBuilder<AddonManagementBloc, AddonManagementState>(
          builder: (context, state) {
            if (state is! AddonManagementLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final category = state.getCategoryById(widget.categoryId);
            if (category == null) {
              return const Center(child: Text('Category not found'));
            }

            final rules = state.getEffectiveRules(widget.itemId, widget.sizeId);
            final rule = rules.firstWhere(
              (r) => r.categoryId == widget.categoryId,
              orElse: () => AddonRule(
                id: '',
                categoryId: widget.categoryId,
                minSelection: 0,
                maxSelection: 999,
                isRequired: false,
                defaultItemIds: [],
                priceOverrides: {},
              ),
            );

            // Initialize controllers
            if (_minController.text.isEmpty) {
              _minController.text = rule.minSelection.toString();
              _maxController.text = rule.maxSelection.toString();
              _isRequired = rule.isRequired;
            }

            final validation = state.getValidation(
              widget.itemId,
              widget.categoryId,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 16),
                _buildRuleConfiguration(rule),
                if (validation != null && !validation.isValid) ...[
                  const SizedBox(height: 12),
                  _buildValidationErrors(validation),
                ],
                const SizedBox(height: 16),
                Expanded(child: _buildItemList(context, state, category, rule)),
                const SizedBox(height: 16),
                _buildFooter(context, state, rule),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configure ${widget.categoryName}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Select items and configure rules',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search items...',
        prefixIcon: const Icon(Icons.search, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
    );
  }

  Widget _buildRuleConfiguration(AddonRule rule) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, size: 20, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'Selection Rules',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  controller: _minController,
                  label: 'Min',
                  hint: '0',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField(
                  controller: _maxController,
                  label: 'Max',
                  hint: '999',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: CheckboxListTile(
                  value: _isRequired,
                  onChanged: (value) {
                    setState(() {
                      _isRequired = value ?? false;
                    });
                  },
                  title: const Text('Required', style: TextStyle(fontSize: 14)),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildValidationErrors(AddonRuleValidation validation) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, size: 16, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Text(
                'Validation Errors',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...validation.errors.map(
            (error) => Padding(
              padding: const EdgeInsets.only(left: 24, bottom: 4),
              child: Text(
                '• $error',
                style: TextStyle(fontSize: 12, color: Colors.red.shade800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemList(
    BuildContext context,
    AddonManagementLoaded state,
    AddonCategory category,
    AddonRule rule,
  ) {
    final filteredItems = _searchQuery.isEmpty
        ? category.items
        : category.items
              .where((item) => item.name.toLowerCase().contains(_searchQuery))
              .toList();

    if (filteredItems.isEmpty) {
      return Center(
        child: Text(
          'No matching items',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    final selectedCount = rule.defaultItemIds.length;
    final totalPrice = rule.defaultItemIds.fold<double>(0, (sum, itemId) {
      final item = category.items.firstWhere((i) => i.id == itemId);
      final price = rule.priceOverrides[itemId] ?? item.basePriceDelta;
      return sum + price;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$selectedCount items selected',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Total: \$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.separated(
            itemCount: filteredItems.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              final isSelected = rule.defaultItemIds.contains(item.id);
              final hasOverride = rule.priceOverrides.containsKey(item.id);
              final displayPrice =
                  rule.priceOverrides[item.id] ?? item.basePriceDelta;

              return _buildAddonItemTile(
                context,
                state,
                item,
                isSelected,
                hasOverride,
                displayPrice,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAddonItemTile(
    BuildContext context,
    AddonManagementLoaded state,
    AddonItem item,
    bool isSelected,
    bool hasOverride,
    double displayPrice,
  ) {
    return ListTile(
      dense: true,
      leading: Checkbox(
        value: isSelected,
        onChanged: (value) {
          context.read<AddonManagementBloc>().add(
            ToggleAddonItemSelectionEvent(
              itemId: widget.itemId,
              sizeId: widget.sizeId,
              categoryId: widget.categoryId,
              addonItemId: item.id,
            ),
          );
        },
      ),
      title: Text(
        item.name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      subtitle: hasOverride
          ? Row(
              children: [
                Text(
                  '\$${item.basePriceDelta.toStringAsFixed(2)}',
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 10),
                const SizedBox(width: 4),
                Text(
                  '\$${displayPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                    fontSize: 11,
                  ),
                ),
              ],
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\$${displayPrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: hasOverride ? Colors.orange : Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              hasOverride ? Icons.edit : Icons.price_change,
              size: 20,
              color: hasOverride ? Colors.orange : Colors.grey.shade400,
            ),
            onPressed: () =>
                _showPriceOverrideDialog(context, item, displayPrice),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    AddonManagementLoaded state,
    AddonRule rule,
  ) {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            context.read<AddonManagementBloc>().add(
              RemoveAddonCategoryEvent(
                itemId: widget.itemId,
                sizeId: widget.sizeId,
                categoryId: widget.categoryId,
              ),
            );
            Navigator.of(context).pop();
          },
          child: const Text('Remove Set', style: TextStyle(color: Colors.red)),
        ),
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _onSave(context, state, rule),
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _showPriceOverrideDialog(
    BuildContext context,
    AddonItem item,
    double currentPrice,
  ) {
    final controller = TextEditingController(
      text: currentPrice.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Override Price: ${item.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Base price: \$${item.basePriceDelta.toStringAsFixed(2)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Override Price',
                prefixText: '\$',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<AddonManagementBloc>().add(
                OverrideAddonItemPriceEvent(
                  itemId: widget.itemId,
                  sizeId: widget.sizeId,
                  categoryId: widget.categoryId,
                  addonItemId: item.id,
                  overridePrice: null,
                ),
              );
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(controller.text);
              if (price != null && price >= 0) {
                context.read<AddonManagementBloc>().add(
                  OverrideAddonItemPriceEvent(
                    itemId: widget.itemId,
                    sizeId: widget.sizeId,
                    categoryId: widget.categoryId,
                    addonItemId: item.id,
                    overridePrice: price,
                  ),
                );
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _onSave(
    BuildContext context,
    AddonManagementLoaded state,
    AddonRule rule,
  ) {
    final minSelection = int.tryParse(_minController.text) ?? 0;
    final maxSelection = int.tryParse(_maxController.text) ?? 999;

    // Update selection rules
    context.read<AddonManagementBloc>().add(
      UpdateSelectionRulesEvent(
        itemId: widget.itemId,
        sizeId: widget.sizeId,
        categoryId: widget.categoryId,
        minSelection: minSelection,
        maxSelection: maxSelection,
        isRequired: _isRequired,
      ),
    );

    // Validate
    context.read<AddonManagementBloc>().add(
      ValidateAddonRulesEvent(widget.itemId),
    );

    Navigator.of(context).pop();
  }
}
