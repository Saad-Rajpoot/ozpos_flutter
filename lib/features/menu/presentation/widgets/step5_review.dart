import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/menu_edit_bloc.dart';
import '../bloc/menu_edit_event.dart';
import '../bloc/menu_edit_state.dart';
import '../../domain/entities/menu_item_edit_entity.dart';
import '../../domain/entities/menu_item_entity.dart';

/// Step 5: Review & Save - Review all details before saving
class Step5Review extends StatelessWidget {
  const Step5Review({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuEditBloc, MenuEditState>(
      builder: (context, state) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Success banner if validation passes
              if (state.validation.isValid)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF10B981),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ready to Save!',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF065F46),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'All required information has been provided. Review the details below and click "Save & Finish" to complete.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              else
                // Error banner if validation fails
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFEF4444)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error,
                        color: Color(0xFFEF4444),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Action Required',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Please fix the following issues before saving:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red.shade900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...state.validation.errors.map((error) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    const Text(
                                      '• ',
                                      style: TextStyle(
                                        color: Color(0xFFEF4444),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        error,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF991B1B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),

              // Visual Menu Preview
              _buildMenuItemPreview(context, state),
              const SizedBox(height: 32),

              // Item Details Summary
              _buildReviewSection(
                context,
                title: 'Item Details',
                icon: Icons.restaurant_menu,
                stepNumber: 1,
                content: [
                  _buildReviewRow(
                    'Name',
                    state.item.name.isNotEmpty ? state.item.name : 'Not set',
                  ),
                  if (state.item.description.isNotEmpty)
                    _buildReviewRow('Description', state.item.description),
                  if (state.item.sku.isNotEmpty)
                    _buildReviewRow('SKU', state.item.sku),
                  _buildReviewRow(
                    'Category',
                    state.item.categoryId.isNotEmpty
                        ? state.item.categoryId
                        : 'Not set',
                  ),
                  if (state.item.badges.isNotEmpty)
                    _buildReviewRow(
                      'Badges',
                      state.item.badges.map((b) => b.label).join(', '),
                    ),
                  if (state.item.displayImagePath != null &&
                      state.item.displayImagePath!.isNotEmpty)
                    _buildImagePreview(state.item.displayImagePath!),
                ],
              ),
              const SizedBox(height: 24),

              // Sizes & Pricing Summary
              _buildReviewSection(
                context,
                title: 'Sizes & Pricing',
                icon: Icons.straighten,
                stepNumber: 2,
                content: [
                  if (state.item.sizes.isEmpty)
                    _buildEmptyMessage('No sizes configured')
                  else
                    ...state.item.sizes.map((size) {
                      return _buildSizeCard(size, state);
                    }),
                ],
              ),
              const SizedBox(height: 24),

              // Upsells Summary
              _buildReviewSection(
                context,
                title: 'Upsells & Related Items',
                icon: Icons.add_shopping_cart,
                stepNumber: 3,
                content: [
                  _buildReviewRow(
                    'Upsell Items',
                    state.item.upsellItemIds.isEmpty
                        ? 'None'
                        : '${state.item.upsellItemIds.length} items',
                  ),
                  _buildReviewRow(
                    'Related Items',
                    state.item.relatedItemIds.isEmpty
                        ? 'None'
                        : '${state.item.relatedItemIds.length} items',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Availability Summary
              _buildReviewSection(
                context,
                title: 'Availability & Settings',
                icon: Icons.settings,
                stepNumber: 4,
                content: [
                  _buildReviewRow(
                    'Dine-In',
                    state.item.dineInAvailable ? 'Available' : 'Not available',
                  ),
                  _buildReviewRow(
                    'Takeaway',
                    state.item.takeawayAvailable
                        ? 'Available'
                        : 'Not available',
                  ),
                  _buildReviewRow(
                    'Delivery',
                    state.item.deliveryAvailable
                        ? 'Available'
                        : 'Not available',
                  ),
                  if (state.item.prepTimeMinutes != null &&
                      state.item.prepTimeMinutes! > 0)
                    _buildReviewRow(
                      'Prep Time',
                      '${state.item.prepTimeMinutes} minutes',
                    ),
                  if (state.item.kitchenStation != null &&
                      state.item.kitchenStation!.isNotEmpty)
                    _buildReviewRow(
                      'Kitchen Station',
                      state.item.kitchenStation!,
                    ),
                  if (state.item.taxCategory.isNotEmpty)
                    _buildReviewRow('Tax Category', state.item.taxCategory),
                  if (state.item.isVegetarian ||
                      state.item.isVegan ||
                      state.item.isGlutenFree ||
                      state.item.isDairyFree ||
                      state.item.isNutFree ||
                      state.item.isHalal)
                    _buildDietaryFlags(state),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReviewSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required int stepNumber,
    required List<Widget> content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with edit button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 24, color: const Color(0xFF2196F3)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    context.read<MenuEditBloc>().add(
                          NavigateToStep(stepNumber),
                        );
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Image',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 200,
              height: 120,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 200,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, size: 48),
              ),
              errorWidget: (context, url, error) => Container(
                width: 200,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.broken_image, size: 48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeCard(SizeEditEntity size, MenuEditState state) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            size.name.isNotEmpty ? size.name : 'Unnamed Size',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildPriceInfo('Dine-In', size.dineInPrice)),
              Expanded(child: _buildPriceInfo('Takeaway', size.takeawayPrice)),
              Expanded(child: _buildPriceInfo('Delivery', size.deliveryPrice)),
            ],
          ),
          if (size.addOnItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: size.addOnItems.map((addOnItem) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    addOnItem.itemName,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPriceInfo(String channel, double? price) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          channel,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          (price != null && price > 0) ? '\$${price.toStringAsFixed(2)}' : '-',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildDietaryFlags(MenuEditState state) {
    final flags = <String>[];
    if (state.item.isVegetarian) flags.add('Vegetarian');
    if (state.item.isVegan) flags.add('Vegan');
    if (state.item.isGlutenFree) flags.add('Gluten-Free');
    if (state.item.isDairyFree) flags.add('Dairy-Free');
    if (!state.item.isNutFree) flags.add('Contains Nuts');
    if (state.item.isHalal) flags.add('Halal');

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dietary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: flags.map((flag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Text(
                  flag,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF065F46),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessage(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade400, size: 20),
          const SizedBox(width: 12),
          Text(
            message,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemPreview(BuildContext context, MenuEditState state) {
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
          // Blue Header with Item Name
          Container(
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
          ),

          // Content Body
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Size Selection
                if (item.hasSizes && item.sizes.isNotEmpty) ...[
                  const Text(
                    'Select Size',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...item.sizes.map(
                    (size) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: size.isDefault
                            ? const Color(0xFFEFF6FF)
                            : Colors.white,
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
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Add-ons Section
                if (item.hasSizes && item.sizes.isNotEmpty) ...[
                  const Text(
                    'Customize Your Order',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...item.sizes.where((s) => s.isDefault).expand((size) {
                    if (size.addOnItems.isEmpty) {
                      return [const SizedBox.shrink()];
                    }
                    // Group by category
                    final groupedAddOns = <String, List<AddOnItemEditEntity>>{};
                    for (final addon in size.addOnItems) {
                      groupedAddOns
                          .putIfAbsent(addon.categoryName, () => [])
                          .add(addon);
                    }

                    return groupedAddOns.entries.expand(
                      (entry) => [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...entry.value.map(
                          (addon) => Container(
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
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),
                ],

                // Total Price
                Container(
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
                        item.hasSizes && item.sizes.isNotEmpty
                            ? '\$${item.sizes.firstWhere((s) => s.isDefault, orElse: () => item.sizes.first).dineInPrice.toStringAsFixed(2)}'
                            : '\$${item.basePrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3B82F6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Upsells Section
                if (item.upsellItemIds.isNotEmpty ||
                    item.relatedItemIds.isNotEmpty) ...[
                  Container(
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
                                .map(
                                  (id) => Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: const Color(0xFF10B981),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getItemName(id, state),
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
                                            '+\$${_getItemPrice(id, state)}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF059669),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
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
                                .map(
                                  (id) => Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: const Color(0xFF3B82F6),
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _getItemName(id, state),
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
                                            '+\$${_getItemPrice(id, state)}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF3B82F6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getItemName(String itemId, MenuEditState state) {
    final item = state.availableItems.firstWhere(
      (i) => i.id == itemId,
      orElse: () => MenuItemEntity(
        id: itemId,
        name: 'Item',
        description: '',
        categoryId: '',
        basePrice: 0.0,
        tags: const [],
      ),
    );
    return item.name;
  }

  String _getItemPrice(String itemId, MenuEditState state) {
    final item = state.availableItems.firstWhere(
      (i) => i.id == itemId,
      orElse: () => MenuItemEntity(
        id: itemId,
        name: 'Item',
        description: '',
        categoryId: '',
        basePrice: 0.0,
        tags: const [],
      ),
    );
    return item.basePrice.toStringAsFixed(2);
  }
}
