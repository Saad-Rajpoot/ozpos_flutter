import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../bloc/addon_management_bloc.dart';
import '../bloc/addon_management_event.dart';
import '../bloc/addon_management_state.dart';
import '../../domain/entities/addon_management_entities.dart';
import '../widgets/addon_category_editor_dialog.dart';

/// Standalone screen for managing add-on categories system-wide
/// Accessible from Menu Editor screen for creating/editing reusable addon sets
///
/// Note: This screen is wrapped with BlocProvider in AppRouter
class AddonCategoriesScreen extends StatelessWidget {
  const AddonCategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Add-on Categories',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: 'Help',
            onPressed: () => _showHelp(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: BlocBuilder<AddonManagementBloc, AddonManagementState>(
              builder: (context, state) {
                if (state is AddonManagementLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is AddonManagementError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.message}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<AddonManagementBloc>().add(
                              const LoadAddonCategoriesEvent(),
                            );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is AddonManagementLoaded) {
                  if (state.categories.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return _buildCategoryList(context, state);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryEditor(context, null),
        icon: const Icon(Icons.add),
        label: const Text('New Category'),
        backgroundColor: const Color(0xFF2196F3),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.category,
                  color: Colors.blue.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage Add-on Categories',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Create reusable add-on sets that can be attached to menu items',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<AddonManagementBloc, AddonManagementState>(
            builder: (context, state) {
              if (state is AddonManagementLoaded) {
                final totalCategories = state.categories.length;
                final totalItems = state.categories.fold<int>(
                  0,
                  (sum, cat) => sum + cat.items.length,
                );

                return Row(
                  children: [
                    _buildStatCard(
                      'Categories',
                      totalCategories.toString(),
                      Icons.folder,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Total Items',
                      totalItems.toString(),
                      Icons.fastfood,
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Add-on Categories Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first add-on category to start organizing menu customizations',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showCategoryEditor(context, null),
              icon: const Icon(Icons.add),
              label: const Text('Create First Category'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, AddonManagementLoaded state) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: state.categories.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final category = state.categories[index];
        return _buildCategoryCard(context, category);
      },
    );
  }

  Widget _buildCategoryCard(BuildContext context, AddonCategory category) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade100, width: 1),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.all(20),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade400, Colors.blue.shade600],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.category, color: Colors.white, size: 24),
        ),
        title: Text(
          category.name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            category.description,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Text(
                '${category.items.length} items',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              color: Colors.blue.shade700,
              tooltip: 'Edit category name/description',
              onPressed: () => _showCategoryEditor(context, category),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.red.shade400,
              tooltip: 'Delete category',
              onPressed: () => _showDeleteConfirmation(context, category),
            ),
          ],
        ),
        children: [
          const Divider(height: 24),
          _buildInlineItemsEditor(context, category),
        ],
      ),
    );
  }

  Widget _buildInlineItemsEditor(BuildContext context, AddonCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.fastfood, size: 18, color: Colors.green.shade700),
            const SizedBox(width: 8),
            const Text(
              'Items in this category',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () => _showAddItemDialog(context, category),
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (category.items.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.fastfood, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'No items yet',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showAddItemDialog(context, category),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Item'),
                  ),
                ],
              ),
            ),
          )
        else
          ...category.items
              .map((item) => _buildInlineItemRow(context, category, item))
              .toList(),
      ],
    );
  }

  Widget _buildInlineItemRow(
    BuildContext context,
    AddonCategory category,
    AddonItem item,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade50,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.fastfood, size: 20, color: Colors.green.shade700),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Price: +\$${item.basePriceDelta.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: Colors.blue.shade600,
            tooltip: 'Edit item',
            onPressed: () => _showEditItemDialog(context, category, item),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            color: Colors.red.shade400,
            tooltip: 'Delete item',
            style: IconButton.styleFrom(backgroundColor: Colors.red.shade50),
            onPressed: () =>
                _showDeleteItemConfirmation(context, category, item),
          ),
        ],
      ),
    );
  }

  void _showCategoryEditor(BuildContext context, AddonCategory? category) {
    AddonCategoryEditorDialog.show(context: context, category: category);
  }

  void _showDeleteConfirmation(BuildContext context, AddonCategory category) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          'Are you sure you want to delete "${category.name}"?\n\nThis will also remove it from all menu items using this category.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AddonManagementBloc>().add(
                DeleteAddonCategoryEvent(category.id),
              );
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${category.name} deleted'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, AddonCategory category) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AddonManagementBloc>(),
        child: AlertDialog(
          title: const Text('Add Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name *',
                  hintText: 'e.g., Cheddar Cheese',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fastfood),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price *',
                  hintText: '0.00',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  final newItem = AddonItem(
                    id: const Uuid().v4(),
                    name: nameController.text,
                    basePriceDelta:
                        double.tryParse(priceController.text) ?? 0.0,
                    sortOrder: category.items.length,
                  );

                  final updatedCategory = category.copyWith(
                    items: [...category.items, newItem],
                  );

                  context.read<AddonManagementBloc>().add(
                    UpdateAddonCategoryEvent(updatedCategory),
                  );

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${newItem.name} added'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditItemDialog(
    BuildContext context,
    AddonCategory category,
    AddonItem item,
  ) {
    final nameController = TextEditingController(text: item.name);
    final priceController = TextEditingController(
      text: item.basePriceDelta.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<AddonManagementBloc>(),
        child: AlertDialog(
          title: const Text('Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Item Name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fastfood),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Price *',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  final updatedItem = item.copyWith(
                    name: nameController.text,
                    basePriceDelta:
                        double.tryParse(priceController.text) ?? 0.0,
                  );

                  final updatedItems = category.items.map((i) {
                    return i.id == item.id ? updatedItem : i;
                  }).toList();

                  final updatedCategory = category.copyWith(
                    items: updatedItems,
                  );

                  context.read<AddonManagementBloc>().add(
                    UpdateAddonCategoryEvent(updatedCategory),
                  );

                  Navigator.pop(dialogContext);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${updatedItem.name} updated'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteItemConfirmation(
    BuildContext context,
    AddonCategory category,
    AddonItem item,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Remove "${item.name}" from this category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedItems = category.items
                  .where((i) => i.id != item.id)
                  .toList();
              final updatedCategory = category.copyWith(items: updatedItems);

              context.read<AddonManagementBloc>().add(
                UpdateAddonCategoryEvent(updatedCategory),
              );

              Navigator.pop(dialogContext);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.name} removed'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Color(0xFF2196F3)),
            SizedBox(width: 12),
            Text('About Add-on Categories'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add-on categories are reusable sets of customization options that can be attached to menu items.',
                style: TextStyle(fontSize: 15, height: 1.5),
              ),
              const SizedBox(height: 16),
              _buildHelpItem(
                'Create Categories',
                'Group related add-ons like "Cheese Options" or "Extra Toppings"',
              ),
              _buildHelpItem(
                'Add Items',
                'Each category contains individual items with their base prices',
              ),
              _buildHelpItem(
                'Reuse Anywhere',
                'Attach categories to multiple menu items or specific sizes',
              ),
              _buildHelpItem(
                'Override Prices',
                'Customize pricing per item or size when attaching',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Color(0xFF2196F3),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
