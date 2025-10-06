import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../theme/tokens.dart';
import '../bloc/menu_bloc.dart';
import 'menu_item_wizard/menu_item_wizard_screen.dart';
import '../../domain/entities/menu_item_edit_entity.dart';

/// Menu Editor Screen - Manage menu items with wizard integration
class MenuEditorScreenNew extends StatefulWidget {
  const MenuEditorScreenNew({super.key});

  @override
  State<MenuEditorScreenNew> createState() => _MenuEditorScreenNewState();
}

class _MenuEditorScreenNewState extends State<MenuEditorScreenNew> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    // Load menu items
    context.read<MenuBloc>().add(GetMenuItemsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Menu Editor',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1F2937)),
        actions: [
          // Add New Item button
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _openWizard(context, null),
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Add New Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxWidth < 600;
                
                return isCompact
                    ? Column(
                        children: [
                          // Search field
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            decoration: InputDecoration(
                              hintText: 'Search menu items...',
                              prefixIcon: const Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF2196F3),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Category filter
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade50,
                            ),
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              underline: const SizedBox(),
                              isExpanded: true,
                              items: [
                                {'value': 'All', 'label': 'All'},
                                {'value': 'cat-1', 'label': 'Pizza'},
                                {'value': 'cat-2', 'label': 'Burgers'},
                                {'value': 'cat-3', 'label': 'Pasta'},
                                {'value': 'cat-4', 'label': 'Salads'},
                                {'value': 'cat-5', 'label': 'Desserts'},
                                {'value': 'cat-6', 'label': 'Beverages'},
                              ].map((category) {
                                return DropdownMenuItem(
                                  value: category['value'],
                                  child: Text(category['label']!),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value ?? 'All';
                                });
                              },
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          // Search field
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                hintText: 'Search menu items...',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF2196F3),
                                    width: 2,
                                  ),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Category filter
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.grey.shade50,
                            ),
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              underline: const SizedBox(),
                              items: [
                                {'value': 'All', 'label': 'All'},
                                {'value': 'cat-1', 'label': 'Pizza'},
                                {'value': 'cat-2', 'label': 'Burgers'},
                                {'value': 'cat-3', 'label': 'Pasta'},
                                {'value': 'cat-4', 'label': 'Salads'},
                                {'value': 'cat-5', 'label': 'Desserts'},
                                {'value': 'cat-6', 'label': 'Beverages'},
                              ].map((category) {
                                return DropdownMenuItem(
                                  value: category['value'],
                                  child: Text(category['label']!),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value ?? 'All';
                                });
                              },
                            ),
                          ),
                        ],
                      );
              },
            ),
          ),

          // Menu items list
          Expanded(
            child: BlocBuilder<MenuBloc, MenuState>(
              builder: (context, state) {
                // Debug logging
                print('Menu Editor - Current state: ${state.runtimeType}');
                
                if (state is MenuLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is MenuError) {
                  print('Menu Editor - Error: ${state.message}');
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading menu items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is MenuLoaded) {
                  print('Menu Editor - Total items loaded: ${state.items.length}');
                  print('Menu Editor - Selected category: $_selectedCategory');
                  print('Menu Editor - Search query: $_searchQuery');
                  
                  // Filter items based on search and category
                  var items = state.items.where((item) {
                    final matchesSearch = _searchQuery.isEmpty ||
                        item.name.toLowerCase().contains(_searchQuery.toLowerCase());
                    final matchesCategory = _selectedCategory == 'All' ||
                        item.categoryId == _selectedCategory;
                    
                    if (!matchesCategory) {
                      print('Item "${item.name}" filtered out: categoryId=${item.categoryId}, filter=$_selectedCategory');
                    }
                    
                    return matchesSearch && matchesCategory;
                  }).toList();

                  print('Menu Editor - Filtered items count: ${items.length}');

                  if (items.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildMenuItemCard(context, item);
                    },
                  );
                }

                print('Menu Editor - Unknown state, showing empty');
                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard(BuildContext context, dynamic item) {
    // Responsive: Check if we're on mobile
    final isCompact = MediaQuery.of(context).size.width < 600;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Image and basic info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: item.image != null && item.image!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            item.image!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.restaurant,
                                size: 32,
                                color: Colors.grey.shade400,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.restaurant,
                          size: 32,
                          color: Colors.grey.shade400,
                        ),
                ),
                const SizedBox(width: 12),
                
                // Name and description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      if (item.description != null && item.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Bottom row: Category, Price, and Actions
            Row(
              children: [
                // Category tag
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.categoryId,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2196F3),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Price
                Text(
                  '\$${item.basePrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF10B981),
                  ),
                ),
                
                const Spacer(),
                
                // Action buttons - compact on mobile
                if (isCompact) ...[
                  // Show menu on mobile
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _openWizard(context, item);
                          break;
                        case 'duplicate':
                          _duplicateItem(context, item);
                          break;
                        case 'delete':
                          _deleteItem(context, item);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.content_copy, size: 18),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Color(0xFFEF4444)),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Color(0xFFEF4444))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // Show all buttons on desktop
                  IconButton(
                    onPressed: () => _openWizard(context, item),
                    icon: const Icon(Icons.edit, size: 20),
                    tooltip: 'Edit',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      foregroundColor: const Color(0xFF2196F3),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => _duplicateItem(context, item),
                    icon: const Icon(Icons.content_copy, size: 20),
                    tooltip: 'Duplicate',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () => _deleteItem(context, item),
                    icon: const Icon(Icons.delete, size: 20),
                    tooltip: 'Delete',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty
                ? 'No menu items yet'
                : 'No items found',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Click "Add New Item" to get started'
                : 'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openWizard(context, null),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openWizard(BuildContext context, dynamic existingItem) async {
    // TODO: Convert existing item to MenuItemEditEntity if editing
    // For now, we'll just open the wizard
    final result = await Navigator.push<MenuItemEditEntity>(
      context,
      MaterialPageRoute(
        builder: (context) => const MenuItemWizardScreen(
          existingItem: null, // TODO: Convert existingItem
          isDuplicate: false,
        ),
      ),
    );

    if (result != null) {
      // Item was saved, reload the menu
      if (context.mounted) {
        context.read<MenuBloc>().add(GetMenuItemsEvent());
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${result.name}" saved successfully!'),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _duplicateItem(BuildContext context, dynamic item) async {
    // TODO: Convert item to MenuItemEditEntity
    final result = await Navigator.push<MenuItemEditEntity>(
      context,
      MaterialPageRoute(
        builder: (context) => const MenuItemWizardScreen(
          existingItem: null, // TODO: Convert item
          isDuplicate: true,
        ),
      ),
    );

    if (result != null && context.mounted) {
      context.read<MenuBloc>().add(GetMenuItemsEvent());
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${result.name}" duplicated successfully!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _deleteItem(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Item?'),
        content: Text(
          'Are you sure you want to delete "${item.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement delete
              Navigator.pop(dialogContext);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${item.name}" deleted'),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                ),
              );
              
              // Reload menu
              context.read<MenuBloc>().add(GetMenuItemsEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}