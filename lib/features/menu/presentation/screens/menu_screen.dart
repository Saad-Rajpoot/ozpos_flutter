import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/entities/menu_category_entity.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/constants/app_responsive.dart';
import '../widgets/menu_item_card.dart';
import '../../../checkout/presentation/widgets/cart_pane.dart';
import '../../../checkout/presentation/bloc/cart_bloc.dart' as cart_bloc;
import '../../../../core/widgets/sidebar_nav.dart';
import '../bloc/menu_bloc.dart';
import '../bloc/menu_event.dart';
import '../bloc/menu_state.dart';
import '../../../orders/presentation/widgets/order_alert_widget.dart';
import '../../../orders/domain/entities/order_entity.dart';
import '../../../orders/domain/entities/order_item_entity.dart';

/// Menu Screen with Seed Data and Cart Integration
class MenuScreen extends StatefulWidget {
  final String? orderType;

  const MenuScreen({super.key, this.orderType});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Timer? _searchDebounce;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load menu data through BLoC
    context.read<MenuBloc>().add(const LoadMenuData());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Get category names for tabs - cached to avoid recreation when categories don't change
  List<String> _getCategoryNames(List<MenuCategoryEntity> categories) {
    // Since categories don't change often, this is reasonably efficient
    // Could be further optimized with memoization if categories change frequently
    return ['all', ...categories.map((cat) => cat.name)];
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop =
        MediaQuery.of(context).size.width > AppConstants.desktopBreakpoint;

    // Extract orderType from navigation arguments - safe type checking
    final routeSettings = ModalRoute.of(context)?.settings;
    final args = routeSettings?.arguments;
    final Map<String, dynamic>? navigationArgs =
        args is Map<String, dynamic> ? args : null;
    final orderTypeString = navigationArgs?['orderType'] as String?;
    final cartBlocInstance = context.read<cart_bloc.CartBloc>();
    final cartState = cartBlocInstance.state;
    final currentOrderType =
        cartState is cart_bloc.CartLoaded ? cartState.orderType : null;

    // Convert string to OrderType enum and update cart order type
    if (orderTypeString != null && orderTypeString.isNotEmpty) {
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
        default:
          // Log invalid order type for debugging
          debugPrint('Invalid order type received: $orderTypeString');
          break;
      }

      // Update the shared CartBloc's order type if specified and valid
      if (orderType != null && orderType != currentOrderType) {
        final desiredOrderType = orderType;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          final latestState = context.read<cart_bloc.CartBloc>().state;
          if (latestState is cart_bloc.CartLoaded &&
              latestState.orderType == desiredOrderType) {
            return;
          }

          context.read<cart_bloc.CartBloc>().add(
                cart_bloc.ChangeOrderType(orderType: desiredOrderType),
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
                  // Menu content with BLoC state management
                  Expanded(
                    child: BlocListener<MenuBloc, MenuState>(
                      listener: (context, state) {
                        // Handle error states
                        if (state is MenuError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                      child: Column(
                        children: [
                          BlocBuilder<MenuBloc, MenuState>(
                            buildWhen: (previous, current) {
                              if (previous.runtimeType != current.runtimeType) {
                                return true;
                              }

                              if (previous is MenuLoaded &&
                                  current is MenuLoaded) {
                                return previous.categories !=
                                        current.categories ||
                                    previous.selectedCategory !=
                                        current.selectedCategory ||
                                    previous.searchQuery != current.searchQuery;
                              }

                              return false;
                            },
                            builder: (context, state) {
                              if (state is MenuLoaded) {
                                final categoryNames =
                                    _getCategoryNames(state.categories);
                                return _buildCategoryTabs(
                                  categoryNames,
                                  state.categories,
                                  state,
                                );
                              }

                              if (state is MenuLoading) {
                                return const SizedBox(height: 50);
                              }

                              return const SizedBox.shrink();
                            },
                          ),
                          Expanded(
                            child: BlocBuilder<MenuBloc, MenuState>(
                              buildWhen: (previous, current) {
                                if (previous.runtimeType !=
                                    current.runtimeType) {
                                  return true;
                                }

                                if (previous is MenuLoaded &&
                                    current is MenuLoaded) {
                                  return previous.items != current.items ||
                                      previous.filteredItems !=
                                          current.filteredItems;
                                }

                                return false;
                              },
                              builder: (context, state) {
                                if (state is MenuLoading) {
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }

                                if (state is MenuError) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.error_outline,
                                          size: 64,
                                          color: Colors.red,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          state.message,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            color: Colors.red,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: () {
                                            context
                                                .read<MenuBloc>()
                                                .add(const LoadMenuData());
                                          },
                                          child: const Text('Retry'),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                if (state is MenuLoaded) {
                                  final itemsToShow =
                                      state.filteredItems ?? state.items;
                                  return _buildMenuGrid(itemsToShow);
                                }

                                return const Center(
                                  child: Text('No menu data available'),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          // Demo Alert Buttons
          ElevatedButton(
            onPressed: () => _showDemoAlert(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Demo Alert',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 8),
          // Cart icon with badge (mobile/tablet)
          if (MediaQuery.of(context).size.width <=
              AppConstants.desktopBreakpoint)
            BlocBuilder<cart_bloc.CartBloc, cart_bloc.CartState>(
              buildWhen: (previous, current) {
                // Always rebuild on state type changes
                if (previous.runtimeType != current.runtimeType) {
                  return true;
                }

                // For CartLoaded state, only rebuild if item count changes
                if (previous is cart_bloc.CartLoaded &&
                    current is cart_bloc.CartLoaded) {
                  return previous.itemCount != current.itemCount;
                }

                return false;
              },
              builder: (context, state) {
                final itemCount =
                    state is cart_bloc.CartLoaded ? state.itemCount : 0;
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
        controller: _searchController,
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
          // Cancel previous debounce timer
          _searchDebounce?.cancel();

          // Sanitize input
          final sanitized = value.trim();

          // Prevent excessive queries (max 100 characters)
          if (sanitized.length > 100) {
            return;
          }

          // Debounce search - wait 300ms after user stops typing
          _searchDebounce = Timer(AppConstants.searchDebounceDelay, () {
            if (mounted) {
              context.read<MenuBloc>().add(SearchMenuItems(query: sanitized));
            }
          });
        },
      ),
    );
  }

  Widget _buildCategoryTabs(List<String> categoryNames,
      List<MenuCategoryEntity> categories, MenuLoaded state) {
    return SizedBox(
      height: 50,
      width: double.infinity, // Ensure full width is available
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categoryNames.length,
        itemBuilder: (context, index) {
          final categoryName = categoryNames[index];
          final isAll = categoryName == 'all';
          final displayName = isAll ? 'All' : categoryName;

          // Check if this category is selected
          // "All" is selected when no filters are active (no selected category and no search)
          final isAllSelected =
              (state.selectedCategory == null && state.searchQuery == null);
          final isCategorySelected =
              (state.selectedCategory?.name == categoryName);

          final isSelected = isAll ? isAllSelected : isCategorySelected;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(displayName),
              selected: isSelected,
              onSelected: (selected) {
                if (selected && !isAll) {
                  final category = categories.firstWhere(
                    (cat) => cat.name == categoryName,
                  );
                  context
                      .read<MenuBloc>()
                      .add(FilterByCategory(category: category));
                } else if (selected && isAll) {
                  context.read<MenuBloc>().add(const ClearFilters());
                }
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

  Widget _buildMenuGrid(List<MenuItemEntity> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text(
              'No menu items available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
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
    if (screenWidth > AppConstants.desktopBreakpoint * 1.4) {
      crossAxisCount = AppConstants.gridColumnsUltraWide;
      spacing = AppConstants.spacingLarge;
      childAspectRatio = 0.8; // Taller cards for more content
      maxLines = 3;
    } else if (screenWidth > AppConstants.desktopBreakpoint) {
      crossAxisCount = AppConstants.gridColumnsDesktop;
      spacing = AppConstants.spacingMedium;
      childAspectRatio = 0.8;
      maxLines = 3;
    } else if (screenWidth > AppConstants.tabletBreakpoint) {
      crossAxisCount = AppConstants.gridColumnsTablet;
      spacing = AppConstants.spacingMedium;
      maxLines = 2;
      childAspectRatio = 1.0;
    } else if (screenWidth > AppConstants.mobileBreakpoint) {
      crossAxisCount = AppConstants.gridColumnsMobile;
      spacing = AppConstants.spacingSmall * 1.5;
      maxLines = 2;
      childAspectRatio = 1.1;
    } else {
      crossAxisCount = AppConstants.gridColumnsMobile;
      spacing = AppConstants.spacingSmall * 1.5;
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
                duration: AppConstants.snackbarShortDuration,
                backgroundColor: AppColors.success,
              ),
            );
          },
        );
      },
    );
  }

  void _showCartDrawer(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  void _showDemoAlert(BuildContext context) {
    // Create a demo order
    final demoOrder = OrderEntity(
      id: 'demo-8642',
      queueNumber: '8642',
      channel: OrderChannel.app,
      orderType: OrderType.takeaway,
      paymentStatus: PaymentStatus.unpaid,
      status: OrderStatus.active,
      customerName: 'Michael Brown',
      customerPhone: '+1234567890',
      items: const [
        OrderItemEntity(
          name: 'Classic Burger',
          quantity: 2,
          price: 12.99,
        ),
        OrderItemEntity(
          name: 'French Fries',
          quantity: 1,
          price: 4.99,
        ),
        OrderItemEntity(
          name: 'Coca-Cola',
          quantity: 2,
          price: 2.99,
        ),
      ],
      subtotal: 38.94,
      tax: 3.67,
      total: 42.61,
      createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
      estimatedTime: DateTime.now().add(const Duration(minutes: 30)),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OrderAlertWidget(
        order: demoOrder,
        onAccept: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order #8642 accepted!'),
              backgroundColor: AppColors.success,
            ),
          );
        },
        onReject: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order #8642 rejected'),
              backgroundColor: AppColors.error,
            ),
          );
        },
      ),
    );
  }
}
