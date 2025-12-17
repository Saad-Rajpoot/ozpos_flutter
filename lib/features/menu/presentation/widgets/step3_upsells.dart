import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/menu_category_entity.dart';
import '../bloc/menu_edit_bloc.dart';
import '../bloc/menu_edit_event.dart';
import '../bloc/menu_edit_state.dart';

/// Step 3: Upsells & Suggestions - Related items and recommendations
class Step3Upsells extends StatelessWidget {
  const Step3Upsells({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuEditBloc, MenuEditState>(
      builder: (context, state) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Add items that pair well with this product or suggest alternatives to increase sales.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Upsell Items Section
              _buildSection(
                title: 'Upsell Items',
                description:
                    'Suggest complementary items (e.g., "Add fries with that?")',
                icon: Icons.add_shopping_cart,
                items: state.item.upsellItemIds,
                onAdd: () => _showItemPicker(
                  context,
                  'Add Upsell Items',
                  state.item.upsellItemIds,
                  state.availableItems,
                  state.categories,
                  (selectedIds) {
                    // Add new items that aren't already in the list
                    for (final id in selectedIds) {
                      if (!state.item.upsellItemIds.contains(id)) {
                        context.read<MenuEditBloc>().add(AddUpsellItem(id));
                      }
                    }
                  },
                ),
                onRemove: (itemId) {
                  context.read<MenuEditBloc>().add(RemoveUpsellItem(itemId));
                },
              ),
              const SizedBox(height: 32),

              // Related Items Section
              _buildSection(
                title: 'Related Items',
                description:
                    'Show similar or alternative items customers might prefer',
                icon: Icons.link,
                items: state.item.relatedItemIds,
                onAdd: () => _showItemPicker(
                  context,
                  'Add Related Items',
                  state.item.relatedItemIds,
                  state.availableItems,
                  state.categories,
                  (selectedIds) {
                    // Add new items that aren't already in the list
                    for (final id in selectedIds) {
                      if (!state.item.relatedItemIds.contains(id)) {
                        context.read<MenuEditBloc>().add(AddRelatedItem(id));
                      }
                    }
                  },
                ),
                onRemove: (itemId) {
                  context.read<MenuEditBloc>().add(RemoveRelatedItem(itemId));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required IconData icon,
    required List<String> items,
    required VoidCallback onAdd,
    required Function(String) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF2196F3)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Items'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Items list
        if (items.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade400, size: 20),
                const SizedBox(width: 12),
                Text(
                  'No items added yet',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: items.map((itemId) {
                return BlocBuilder<MenuEditBloc, MenuEditState>(
                  builder: (context, state) {
                    return _buildItemCard(
                      itemId: itemId,
                      availableItems: state.availableItems,
                      categories: state.categories,
                      onRemove: () => onRemove(itemId),
                    );
                  },
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildItemCard({
    required String itemId,
    required List<MenuItemEntity> availableItems,
    required List<MenuCategoryEntity> categories,
    required VoidCallback onRemove,
  }) {
    // Find the actual item from available items
    final item = availableItems.firstWhere(
      (item) => item.id == itemId,
      orElse: () => MenuItemEntity(
        id: itemId,
        name: 'Unknown Item',
        description: '',
        categoryId: '',
        basePrice: 0.0,
        tags: const [],
      ),
    );

    // Find the category name
    final category = categories.firstWhere(
      (cat) => cat.id == item.categoryId,
      orElse: () => MenuCategoryEntity(
        id: item.categoryId,
        name: 'Uncategorized',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: item.image != null && item.image!.isNotEmpty
            ? CircleAvatar(backgroundImage: NetworkImage(item.image!))
            : CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: Icon(Icons.fastfood, color: Colors.grey.shade600),
              ),
        title: Text(item.name),
        subtitle: Text(
          '${category.name} • \$${item.basePrice.toStringAsFixed(2)}',
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.grey.shade400),
          onPressed: onRemove,
        ),
      ),
    );
  }

  void _showItemPicker(
    BuildContext context,
    String title,
    List<String> currentItemIds,
    List<MenuItemEntity> availableItems,
    List<MenuCategoryEntity> categories,
    Function(List<String>) onSelectionChanged,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => _ItemPickerDialog(
        title: title,
        availableItems: availableItems,
        categories: categories,
        currentItemIds: currentItemIds,
        onSelectionChanged: onSelectionChanged,
      ),
    );
  }
}

class _ItemPickerDialog extends StatefulWidget {
  final String title;
  final List<MenuItemEntity> availableItems;
  final List<MenuCategoryEntity> categories;
  final List<String> currentItemIds;
  final Function(List<String>) onSelectionChanged;

  const _ItemPickerDialog({
    required this.title,
    required this.availableItems,
    required this.categories,
    required this.currentItemIds,
    required this.onSelectionChanged,
  });

  @override
  State<_ItemPickerDialog> createState() => _ItemPickerDialogState();
}

class _ItemPickerDialogState extends State<_ItemPickerDialog> {
  late final ValueNotifier<Set<String>> _selectedIdsNotifier;
  late final ValueNotifier<String> _searchQueryNotifier;
  late final ValueNotifier<String> _selectedCategoryNotifier;

  @override
  void initState() {
    super.initState();
    _selectedIdsNotifier = ValueNotifier<Set<String>>(
      Set<String>.from(widget.currentItemIds),
    );
    _searchQueryNotifier = ValueNotifier<String>('');
    _selectedCategoryNotifier = ValueNotifier<String>('All');
  }

  @override
  void dispose() {
    _selectedIdsNotifier.dispose();
    _searchQueryNotifier.dispose();
    _selectedCategoryNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryNames = <String>{
      'All',
      ...widget.categories.map((c) => c.name)
    };

    return ValueListenableBuilder<Set<String>>(
      valueListenable: _selectedIdsNotifier,
      builder: (context, selectedIds, _) {
        return ValueListenableBuilder<String>(
          valueListenable: _searchQueryNotifier,
          builder: (context, searchQuery, __) {
            return ValueListenableBuilder<String>(
              valueListenable: _selectedCategoryNotifier,
              builder: (context, selectedCategory, ___) {
                final filteredItems = widget.availableItems.where((item) {
                  final matchesSearch = item.name
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase());

                  final category = widget.categories.firstWhere(
                    (cat) => cat.id == item.categoryId,
                    orElse: () => MenuCategoryEntity(
                      id: item.categoryId,
                      name: 'Uncategorized',
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    ),
                  );

                  final matchesCategory = selectedCategory == 'All' ||
                      category.name == selectedCategory;
                  return matchesSearch && matchesCategory;
                }).toList();

                return AlertDialog(
                  title: Text(widget.title),
                  content: SizedBox(
                    width: 500,
                    height: 500,
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) =>
                              _searchQueryNotifier.value = value,
                          decoration: InputDecoration(
                            hintText: 'Search items...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            const Text(
                              'Category:',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(width: 4),
                            ...categoryNames.map((category) {
                              return ChoiceChip(
                                label: Text(category),
                                selected: selectedCategory == category,
                                onSelected: (selected) {
                                  if (selected) {
                                    _selectedCategoryNotifier.value = category;
                                  }
                                },
                              );
                            }),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: filteredItems.isEmpty
                              ? Center(
                                  child: Text(
                                    'No items found',
                                    style:
                                        TextStyle(color: Colors.grey.shade600),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredItems.length,
                                  itemBuilder: (context, index) {
                                    final item = filteredItems[index];
                                    final isSelected =
                                        selectedIds.contains(item.id);

                                    final category =
                                        widget.categories.firstWhere(
                                      (cat) => cat.id == item.categoryId,
                                      orElse: () => MenuCategoryEntity(
                                        id: item.categoryId,
                                        name: 'Uncategorized',
                                        createdAt: DateTime.now(),
                                        updatedAt: DateTime.now(),
                                      ),
                                    );

                                    return CheckboxListTile(
                                      value: isSelected,
                                      onChanged: (value) {
                                        final updated =
                                            Set<String>.from(selectedIds);
                                        if (value == true) {
                                          updated.add(item.id);
                                        } else {
                                          updated.remove(item.id);
                                        }
                                        _selectedIdsNotifier.value = updated;
                                      },
                                      title: Text(item.name),
                                      subtitle: Text(
                                        '${category.name} • \$${item.basePrice.toStringAsFixed(2)}',
                                      ),
                                      secondary: item.image != null &&
                                              item.image!.isNotEmpty
                                          ? CircleAvatar(
                                              backgroundImage:
                                                  NetworkImage(item.image!),
                                            )
                                          : CircleAvatar(
                                              backgroundColor:
                                                  Colors.grey.shade200,
                                              child: Icon(
                                                Icons.fastfood,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        widget.onSelectionChanged(selectedIds.toList());
                        Navigator.pop(context);
                      },
                      child: Text('Add ${selectedIds.length} Items'),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
