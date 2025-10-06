import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/data/seed_data.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../theme/tokens.dart';
import '../../../../utils/responsive.dart';
import '../../../../widgets/menu/menu_item_card.dart';
import '../../../../widgets/cart/cart_pane.dart';
import '../../../../widgets/sidebar_nav.dart';
import '../bloc/cart_bloc.dart';

/// New Menu Screen with Seed Data and Cart Integration
class MenuScreenNew extends StatefulWidget {
  const MenuScreenNew({super.key});

  @override
  State<MenuScreenNew> createState() => _MenuScreenNewState();
}

class _MenuScreenNewState extends State<MenuScreenNew> {
  String _selectedCategory = 'all';
  String _searchQuery = '';

  List<String> get _categories {
    final allCategories = SeedData.menuItems
        .map((item) => item.categoryId)
        .toSet()
        .toList();
    return ['all', ...allCategories];
  }

  List<dynamic> get _filteredItems {
    var items = SeedData.menuItems;

    // Apply category filter
    if (_selectedCategory != 'all') {
      items = items.where((item) => item.categoryId == _selectedCategory).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    return BlocProvider(
      create: (context) => CartBloc()..add(InitializeCart()),
      child: ClampedTextScaling(
        child: Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
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
                child: Column(
                  children: [
                    // Header
                    _buildHeader(context),
                    // Search bar
                    _buildSearchBar(),
                    // Category tabs
                    _buildCategoryTabs(),
                    // Menu grid
                    Expanded(
                      child: _buildMenuGrid(),
                    ),
                  ],
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

  Widget _buildHeader(BuildContext context) {
    return Container(
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
      child: Row(
        children: [
          const Text(
            'Menu',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const Spacer(),
          // Cart icon with badge (mobile/tablet)
          if (MediaQuery.of(context).size.width <= 1024)
            BlocBuilder<CartBloc, CartState>(
              builder: (context, state) {
                final itemCount = state is CartLoaded ? state.itemCount : 0;
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search menu items...',
          prefixIcon: const Icon(Icons.search, size: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          final displayName = category == 'all' 
              ? 'All' 
              : category[0].toUpperCase() + category.substring(1);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFEF4444),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF374151),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
              side: BorderSide(
                color: isSelected ? const Color(0xFFEF4444) : const Color(0xFFD1D5DB),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuGrid() {
    final items = _filteredItems;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No items found for "$_searchQuery"'
                  : 'No menu items available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
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

    // Responsive grid columns
    if (screenWidth > 1400) {
      crossAxisCount = 5;
      spacing = 20;
    } else if (screenWidth > 1024) {
      crossAxisCount = 4;
      spacing = 16;
    } else if (screenWidth > 768) {
      crossAxisCount = 3;
      spacing = 16;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
      spacing = 12;
    } else {
      crossAxisCount = 2;
      spacing = 12;
    }

    return GridView.builder(
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.75,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MenuItemCard(
          item: item,
          onTap: () {
            // Fast add for items without required modifiers
            if (item.isFastAdd) {
              context.read<CartBloc>().add(
                    AddItemToCart(
                      menuItem: item,
                      quantity: 1,
                      unitPrice: item.basePrice,
                      selectedModifiers: {},
                      modifierSummary: '',
                    ),
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Added ${item.name} to cart'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            }
          },
        );
      },
    );
  }

  void _showCartDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }
}
