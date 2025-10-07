import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../pos/data/seed_data.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/utils/responsive.dart';
import '../widgets/menu_item_card.dart';
import '../../../pos/presentation/widgets/cart_pane.dart';
import '../../../../core/widgets/sidebar_nav.dart';
import '../../../pos/presentation/bloc/cart_bloc.dart' as cart_bloc;

/// Menu Screen with Seed Data and Cart Integration
class MenuScreen extends StatefulWidget {
  final String? orderType;

  const MenuScreen({super.key, this.orderType});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';

  List<String> get _categories {
    final Set<String> allCategories = {};
    for (final item in SeedData.menuItems) {
      if (item.categoryId.isNotEmpty) {
        allCategories.add(item.categoryId);
      }
    }
    return ['all', ...allCategories.toList()];
  }

  List<MenuItemEntity> get _filteredItems {
    List<MenuItemEntity> items = SeedData.menuItems;

    // Apply category filter
    if (_selectedCategory != 'all') {
      items = items
          .where((item) => item.categoryId == _selectedCategory)
          .toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        final name = item.name;
        final description = item.description;
        return name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 1024;

    // Extract orderType from navigation arguments
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final orderTypeString = args?['orderType'] as String?;

    // Convert string to OrderType enum and update cart order type
    if (orderTypeString != null) {
      cart_bloc.OrderType? orderType;
      switch (orderTypeString) {
        case 'takeaway':
          orderType = cart_bloc.OrderType.takeaway;
          break;
        case 'dine-in':
          orderType = cart_bloc.OrderType.dineIn;
          break;
        case 'delivery':
          orderType = cart_bloc.OrderType.delivery;
          break;
      }

      // Update the shared CartBloc's order type if specified
      if (orderType != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<cart_bloc.CartBloc>().add(
            cart_bloc.ChangeOrderType(orderType: orderType!),
          );
        });
      }
    }

    return ClampedTextScaling(
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
                  Expanded(child: _buildMenuGrid()),
                ],
              ),
            ),

            // Cart pane (desktop only)
            if (isDesktop) const CartPane(),
          ],
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
            color: Colors.black.withValues(alpha: 0.05),
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
            BlocBuilder<cart_bloc.CartBloc, cart_bloc.CartState>(
              builder: (context, state) {
                final itemCount = state is cart_bloc.CartLoaded
                    ? state.itemCount
                    : 0;
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
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
                color: isSelected
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFD1D5DB),
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
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade300),
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
    double childAspectRatio;
    int maxLines;

    // Responsive grid columns with proper aspect ratios to prevent overflow
    if (screenWidth > 1400) {
      crossAxisCount = 5;
      spacing = 20;
      childAspectRatio = 0.8; // Taller cards for more content
      maxLines = 3;
    } else if (screenWidth > 1024) {
      crossAxisCount = 4;
      spacing = 16;
      childAspectRatio = 0.8;
      maxLines = 3;
    } else if (screenWidth > 768) {
      crossAxisCount = 3;
      spacing = 16;
      maxLines = 2;
      childAspectRatio = 1.0;
    } else if (screenWidth > 600) {
      crossAxisCount = 2;
      spacing = 12;
      maxLines = 2;
      childAspectRatio = 1.1;
    } else {
      crossAxisCount = 2;
      spacing = 12;
      maxLines = 1;
      childAspectRatio = 1.1; // More height for mobile
    }

    return GridView.builder(
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return MenuItemCard(
          maxLines: maxLines,
          item: item,
          onTap: () {
            // Fast add for items without required modifiers
            if (item.isFastAdd) {
              context.read<cart_bloc.CartBloc>().add(
                cart_bloc.AddItemToCart(
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
