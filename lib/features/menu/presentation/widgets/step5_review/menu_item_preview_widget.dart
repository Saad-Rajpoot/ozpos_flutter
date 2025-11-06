import 'package:flutter/material.dart';
import '../../../domain/entities/menu_item_edit_entity.dart';
import '../../../domain/entities/menu_item_entity.dart';
import '../../bloc/menu_edit_state.dart';

/// Menu item preview widget showing how the item will appear to customers
class MenuItemPreviewWidget extends StatelessWidget {
  final MenuEditState state;

  const MenuItemPreviewWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final item = state.item;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(item),
          _buildContent(item, state),
        ],
      ),
    );
  }

  Widget _buildHeader(MenuItemEditEntity item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF4F46E5),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name.isEmpty ? 'Item Name' : item.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          if (item.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              item.description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent(MenuItemEditEntity item, MenuEditState state) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.hasSizes && item.sizes.isNotEmpty) ...[
            _buildSizeSelection(item),
            const SizedBox(height: 24),
          ],
          if (item.hasSizes && item.sizes.isNotEmpty) ...[
            _buildAddOnsSection(item),
            const SizedBox(height: 24),
          ],
          _buildTotalPrice(item),
          const SizedBox(height: 24),
          if (item.upsellItemIds.isNotEmpty || item.relatedItemIds.isNotEmpty)
            _buildUpsellsSection(item, state),
        ],
      ),
    );
  }

  Widget _buildSizeSelection(MenuItemEditEntity item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Size',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        ...item.sizes.map((size) => _buildSizeOption(size)),
      ],
    );
  }

  Widget _buildSizeOption(SizeEditEntity size) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: size.isDefault ? const Color(0xFFEFF6FF) : Colors.white,
        border: Border.all(
          color: size.isDefault
              ? const Color(0xFF3B82F6)
              : Colors.grey.shade300,
          width: size.isDefault ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                size.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              if (size.isDefault)
                const Text(
                  'Default',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF3B82F6),
                  ),
                ),
            ],
          ),
          Text(
            '\$${size.dineInPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddOnsSection(MenuItemEditEntity item) {
    final defaultSize = item.sizes.where((s) => s.isDefault).firstOrNull ??
        item.sizes.first;

    if (defaultSize.addOnItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group by category
    final groupedAddOns = <String, List<AddOnItemEditEntity>>{};
    for (final addon in defaultSize.addOnItems) {
      groupedAddOns
          .putIfAbsent(addon.categoryName, () => [])
          .add(addon);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Customize Your Order',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        ...groupedAddOns.entries.expand((entry) => [
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              ...entry.value.map((addon) => _buildAddOnItem(addon)),
              const SizedBox(height: 16),
            ]),
      ],
    );
  }

  Widget _buildAddOnItem(AddOnItemEditEntity addon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade400,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              addon.itemName,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          Text(
            '+\$${addon.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF059669),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPrice(MenuItemEditEntity item) {
    final price = item.hasSizes && item.sizes.isNotEmpty
        ? item.sizes
            .firstWhere(
              (s) => s.isDefault,
              orElse: () => item.sizes.first,
            )
            .dineInPrice
        : item.basePrice;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Price',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          Text(
            '\$${price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpsellsSection(MenuItemEditEntity item, MenuEditState state) {
    // Create lookup map for O(1) access
    final itemsMap = Map.fromEntries(
      state.availableItems.map((i) => MapEntry(i.id, i)),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFCD34D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('⭐ ', style: TextStyle(fontSize: 16)),
              Text(
                'UPGRADE YOUR ORDER',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF92400E),
                ),
              ),
            ],
          ),
          if (item.upsellItemIds.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: item.upsellItemIds
                  .take(2)
                  .map((id) => Expanded(
                        child: _buildUpsellCard(
                          id,
                          itemsMap,
                          isUpsell: true,
                        ),
                      ))
                  .toList(),
            ),
          ],
          if (item.relatedItemIds.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Row(
              children: [
                Text('🤝 ', style: TextStyle(fontSize: 16)),
                Text(
                  'YOU MIGHT ALSO LIKE',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E40AF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: item.relatedItemIds
                  .take(2)
                  .map((id) => Expanded(
                        child: _buildUpsellCard(
                          id,
                          itemsMap,
                          isUpsell: false,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUpsellCard(
    String itemId,
    Map<String, MenuItemEntity> itemsMap, {
    required bool isUpsell,
  }) {
    final item = itemsMap[itemId] ??
        MenuItemEntity(
          id: itemId,
          name: 'Item',
          description: '',
          categoryId: '',
          basePrice: 0.0,
          tags: const [],
        );

    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isUpsell ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '+\$${item.basePrice.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isUpsell ? const Color(0xFF059669) : const Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }
}

