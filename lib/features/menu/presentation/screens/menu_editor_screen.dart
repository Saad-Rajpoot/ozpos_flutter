import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../bloc/menu_bloc.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/menu_item_edit_entity.dart';
import '../../../combos/presentation/bloc/combo_management_bloc.dart';
import '../../../combos/presentation/widgets/combo_card.dart';
import '../../../combos/presentation/widgets/combo_builder_modal.dart';
import '../../../combos/presentation/bloc/combo_management_event.dart';
import '../../../combos/presentation/bloc/combo_management_state.dart';
import '../../../combos/domain/entities/combo_entity.dart';

/// Menu Editor Screen - Matches reference UI design
class MenuEditorScreen extends StatefulWidget {
  const MenuEditorScreen({super.key});

  @override
  State<MenuEditorScreen> createState() => _MenuEditorScreenState();
}

class _MenuEditorScreenState extends State<MenuEditorScreen> {
  String _searchQuery = '';
  String? _selectedCategoryId;
  final Map<String, bool> _collapsedCategories = {};

  @override
  void initState() {
    super.initState();
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Row(
        children: [
          // Left Sidebar
          _buildLeftSidebar(),

          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildMainContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftSidebar() {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Menu Categories',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ),

          // New Meal Combo Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: () => _openComboCreator(context),
              icon: const Icon(Icons.bolt, size: 18),
              label: const Text('New Meal Combo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // New Category Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('New Category'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6B7280),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Manage Add-on Sets Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => _openAddonManagement(context),
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Manage Add-on Sets'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2196F3),
                side: const BorderSide(color: Color(0xFF2196F3)),
                minimumSize: const Size(double.infinity, 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Categories List
          Expanded(
            child: BlocBuilder<MenuBloc, MenuState>(
              builder: (context, state) {
                if (state is MenuLoaded) {
                  // Group items by category
                  final categoryGroups = <String, List<MenuItemEntity>>{};
                  for (final item in state.items) {
                    categoryGroups
                        .putIfAbsent(item.categoryId, () => [])
                        .add(item);
                  }

                  return ListView(
                    padding: EdgeInsets.zero,
                    children: categoryGroups.entries.map((entry) {
                      return _buildCategoryItem(
                        entry.key,
                        _getCategoryName(entry.key),
                        entry.value.length,
                      );
                    }).toList(),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String categoryId, String name, int count) {
    final isSelected = _selectedCategoryId == categoryId;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedCategoryId = isSelected ? null : categoryId;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        color: isSelected ? const Color(0xFFF3F4F6) : null,
        child: Row(
          children: [
            Icon(Icons.drag_indicator, size: 16, color: Colors.grey.shade400),
            const SizedBox(width: 8),
            _getCategoryIcon(name),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            if (!isSelected)
              const Icon(
                Icons.chevron_right,
                size: 16,
                color: Color(0xFF9CA3AF),
              ),
          ],
        ),
      ),
    );
  }

  Widget _getCategoryIcon(String categoryName) {
    IconData icon;
    switch (categoryName) {
      case 'Pizza':
      case 'Pizzas':
        icon = Icons.local_pizza;
        break;
      case 'Burgers':
        icon = Icons.lunch_dining;
        break;
      case 'Pasta':
        icon = Icons.ramen_dining;
        break;
      case 'Salads':
        icon = Icons.eco;
        break;
      case 'Desserts':
        icon = Icons.cake;
        break;
      case 'Beverages':
        icon = Icons.local_cafe;
        break;
      default:
        icon = Icons.restaurant;
    }
    return Icon(icon, size: 18, color: const Color(0xFFF59E0B));
  }

  String _getCategoryName(String categoryId) {
    final map = {
      'cat-1': 'Pizzas',
      'cat-2': 'Burgers',
      'cat-3': 'Pasta',
      'cat-4': 'Salads',
      'cat-5': 'Desserts',
      'cat-6': 'Beverages',
    };
    return map[categoryId] ?? 'Unknown';
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text(
            'Menu Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Unsaved changes • 3',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFFD97706),
              ),
            ),
          ),
          // Search
          SizedBox(
            width: 300,
            height: 40,
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search items, categories',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _openComboCreator(context),
            icon: const Icon(Icons.bolt, size: 18),
            label: const Text('New Meal Combo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () => _openWizard(context, null),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add New Item'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1F2937),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save All'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1F2937),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        if (state is MenuLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MenuError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is MenuLoaded) {
          // Group items by category
          final categoryGroups = <String, List<MenuItemEntity>>{};
          for (final item in state.items) {
            if (_selectedCategoryId == null ||
                item.categoryId == _selectedCategoryId) {
              if (_searchQuery.isEmpty ||
                  item.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  )) {
                categoryGroups.putIfAbsent(item.categoryId, () => []).add(item);
              }
            }
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Combo Deals Section
              _buildComboDealsSection(),
              const SizedBox(height: 32),

              // Menu Items Sections
              ...categoryGroups.entries.map((entry) {
                return _buildCategorySection(
                  entry.key,
                  _getCategoryName(entry.key),
                  entry.value,
                );
              }),
            ],
          );
        }

        return const Center(child: Text('No items'));
      },
    );
  }

  Widget _buildComboDealsSection() {
    return BlocBuilder<ComboManagementBloc, ComboManagementState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Color(0xFF8B5CF6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Meal Combos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${state.filteredCombos.length} combos',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '📈 Boost Sales',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _openComboCreator(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text(
                      'Create Combo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Combo Cards
              if (state.isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                  ),
                )
              else if (state.hasError)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading combos',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.currentErrorMessage ?? 'Something went wrong',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else if (state.filteredCombos.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF8B5CF6,
                            ).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.restaurant_menu,
                            size: 32,
                            color: Color(0xFF8B5CF6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No combo deals yet',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create meal combos to boost sales and offer better value',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _openComboCreator(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Create First Combo'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // Combo Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _getComboGridCrossAxisCount(context),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: state.filteredCombos.length,
                  itemBuilder: (context, index) {
                    final combo = state.filteredCombos[index];
                    return ComboCard(
                      combo: combo,
                      onEdit: () => _editCombo(context, combo.id),
                      onDuplicate: () => _duplicateCombo(context, combo.id),
                      onToggleVisibility: () =>
                          _toggleComboVisibility(context, combo),
                      onDelete: () => _deleteCombo(context, combo.id),
                      onAddToCart: () => _addComboToCart(context, combo),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  int _getComboGridCrossAxisCount(BuildContext context) {
    final width =
        MediaQuery.of(context).size.width - 340; // Subtract sidebar width
    if (width > 1200) return 3;
    if (width > 800) return 2;
    return 1;
  }

  void _editCombo(BuildContext context, String comboId) {
    final comboBloc = context.read<ComboManagementBloc>();
    comboBloc.add(StartComboEdit(comboId: comboId));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider.value(
        value: comboBloc,
        child: const ComboBuilderModal(),
      ),
    );
  }

  void _duplicateCombo(BuildContext context, String comboId) {
    context.read<ComboManagementBloc>().add(DuplicateCombo(comboId: comboId));
  }

  void _toggleComboVisibility(BuildContext context, combo) {
    final newStatus = combo.status == ComboStatus.active
        ? ComboStatus.hidden
        : ComboStatus.active;

    context.read<ComboManagementBloc>().add(
      ToggleComboVisibility(comboId: combo.id, newStatus: newStatus),
    );
  }

  void _deleteCombo(BuildContext context, String comboId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Combo'),
        content: const Text(
          'Are you sure you want to delete this combo? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ComboManagementBloc>().add(
                DeleteCombo(comboId: comboId),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addComboToCart(BuildContext context, combo) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${combo.name}" to cart'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  Widget _buildCategorySection(
    String categoryId,
    String categoryName,
    List<MenuItemEntity> items,
  ) {
    final isCollapsed = _collapsedCategories[categoryId] ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Text(
                categoryName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${items.length} Items',
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.reorder, size: 18),
                label: const Text('Reorder'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _collapsedCategories[categoryId] = !isCollapsed;
                  });
                },
                icon: Icon(
                  isCollapsed ? Icons.expand_more : Icons.expand_less,
                  size: 18,
                ),
                label: Text(isCollapsed ? 'Expand' : 'Collapse'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),

        // Items
        if (!isCollapsed) ...items.map((item) => _buildMenuItem(item)),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildMenuItem(MenuItemEntity item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: item.image != null
                ? Image.network(
                    item.image!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    Text(
                      'from \$${item.basePrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Tags
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...item.tags.map((tag) => _buildTag(tag)),
                    _buildTag('2 add-on sets', color: Colors.grey.shade100),
                  ],
                ),

                const SizedBox(height: 12),

                // Channel indicators
                Row(
                  children: [
                    _buildChannelChip('POS', true),
                    const SizedBox(width: 8),
                    _buildChannelChip('Online', false),
                    const SizedBox(width: 8),
                    _buildChannelChip('Delivery', false),
                  ],
                ),

                const SizedBox(height: 12),

                // Actions
                Row(
                  children: [
                    _buildActionButton(
                      Icons.edit_outlined,
                      'Edit',
                      () => _openWizard(context, item),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      Icons.content_copy_outlined,
                      'Duplicate',
                      () {},
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      Icons.visibility_off_outlined,
                      'Hide',
                      () {},
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      Icons.delete_outline,
                      'Delete',
                      () {},
                      isDestructive: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(Icons.restaurant, color: Colors.grey.shade400, size: 32),
    );
  }

  Widget _buildTag(String label, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color != null ? Colors.grey.shade700 : Colors.orange.shade700,
        ),
      ),
    );
  }

  Widget _buildChannelChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.grey.shade100 : Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isActive ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed, {
    bool isDestructive = false,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: isDestructive
            ? const Color(0xFFEF4444)
            : const Color(0xFF6B7280),
        side: BorderSide(
          color: isDestructive
              ? const Color(0xFFEF4444)
              : const Color(0xFFE5E7EB),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  void _openWizard(BuildContext context, MenuItemEntity? item) async {
    final result = await NavigationService.pushNamed<MenuItemEditEntity>(
      AppRouter.menuItemWizard,
      arguments: {'existingItem': item, 'isDuplicate': false},
    );

    if (result != null && context.mounted) {
      context.read<MenuBloc>().add(GetMenuItemsEvent());
      NavigationService.showSuccess('"${result.name}" saved successfully!');
    }
  }

  void _openAddonManagement(BuildContext context) {
    NavigationService.pushNamed(AppRouter.addonManagement);
  }

  void _openComboCreator(BuildContext context) {
    // Get or create ComboManagementBloc
    final comboBloc = context.read<ComboManagementBloc>();
    comboBloc.add(const StartComboEdit());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BlocProvider.value(
        value: comboBloc,
        child: const ComboBuilderModal(),
      ),
    );
  }
}
