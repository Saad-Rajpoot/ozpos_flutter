import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../theme/tokens.dart';
import '../../../../utils/responsive.dart';
import '../bloc/menu_bloc.dart';
import '../../../../widgets/menu/menu_item_card.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load menu data when screen initializes
    context.read<MenuBloc>().add(GetMenuItemsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return ClampedTextScaling(
      child: Scaffold(
        backgroundColor: AppColors.bgPrimary,
        appBar: AppBar(
          title: const Text('Menu'),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.checkout);
              },
              icon: const Icon(Icons.shopping_cart),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            _buildCategoryTabs(),
            Expanded(child: _buildMenuGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search menu items...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
          if (value.isNotEmpty) {
            // TODO: Implement search functionality
            // context.read<MenuBloc>().add(SearchMenuItems(query: value));
          } else {
            context.read<MenuBloc>().add(GetMenuItemsEvent());
          }
        },
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = [
      {'id': 'all', 'name': 'All'},
      {'id': 'burgers', 'name': 'Burgers'},
      {'id': 'pizza', 'name': 'Pizza'},
      {'id': 'drinks', 'name': 'Drinks'},
      {'id': 'desserts', 'name': 'Desserts'},
    ];

    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['id'];

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(category['name']!),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category['id']!;
                });
                if (category['id'] == 'all') {
                  context.read<MenuBloc>().add(GetMenuItemsEvent());
                } else {
                  // TODO: Implement category filtering
                  // context.read<MenuBloc>().add(LoadMenuItemsByCategory(categoryId: category['id']!));
                }
              },
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuGrid() {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        if (state is MenuLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is MenuError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: AppSpacing.md),
                Text(
                  state.message,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  onPressed: () {
                    context.read<MenuBloc>().add(GetMenuItemsEvent());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is MenuLoaded) {
          if (state.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 64,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No menu items found',
                    style: AppTypography.heading3.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: context.isCompact ? 2 : 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
            ),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return MenuItemCard(
                item: item,
                onTap: () {
                  // Handle item tap - could show details or add to cart
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Tapped on ${item.name}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
