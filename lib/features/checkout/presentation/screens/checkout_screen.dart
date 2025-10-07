import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/sidebar_nav.dart';
import '../../../checkout/presentation/widgets/order_items_panel.dart';
import '../../../checkout/presentation/widgets/payment_keypad_panel.dart';
import '../../../checkout/presentation/widgets/payment_options_panel.dart';
import '../../../pos/presentation/bloc/cart_bloc.dart';
import '../../../pos/presentation/bloc/checkout_bloc.dart';
import '../checkout_tokens.dart';

/// Checkout Screen - Compact layout matching React prototype
///
/// Features:
/// - Fixed three-column layout (no outer scroll)
/// - Text scale clamped to 1.0-1.1
/// - Reads from shared CartBloc (shows existing items)
/// - Responsive: drawer for <900dp, inline for ≥900dp
/// - No scrolling at 1366×768
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Clamp text scaling (1.0 - 1.1)
    final scaler = MediaQuery.textScalerOf(
      context,
    ).clamp(minScaleFactor: 1.0, maxScaleFactor: 1.1);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: scaler),
      child: const _CheckoutScreenContent(),
    );
  }
}

class _CheckoutScreenContent extends StatelessWidget {
  const _CheckoutScreenContent();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = CheckoutTokens.isCompact(screenWidth);

    // Get cart items from shared CartBloc using BlocBuilder for proper state access
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        // Extract cart items
        List<CartLineItem> items = [];
        if (cartState is CartLoaded) {
          items = cartState.items;
          debugPrint('✅ Checkout: Loaded ${items.length} items from CartBloc');
        } else {
          debugPrint(
            '⚠️ Checkout: CartBloc state is not CartLoaded, state type: ${cartState.runtimeType}',
          );
        }

        return BlocProvider(
          create: (context) =>
              CheckoutBloc()..add(InitializeCheckout(items: items)),
          child: Scaffold(
            backgroundColor: CheckoutTokens.background,
            appBar: isCompact ? _buildCompactAppBar(context) : null,
            endDrawer: isCompact ? _buildOrderDrawer(context) : null,
            body: Row(
              children: [
                // Sidebar navigation (only on desktop)
                if (!isCompact)
                  const SidebarNav(activeRoute: AppRouter.checkout),

                // Main content
                Expanded(
                  child: isCompact
                      ? _buildCompactLayout(context)
                      : _buildDesktopLayout(context, screenWidth),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================================
  // DESKTOP LAYOUT (≥900dp) - Three columns, NO outer scroll
  // ============================================================================
  Widget _buildDesktopLayout(BuildContext context, double screenWidth) {
    final leftWidth = CheckoutTokens.getLeftWidth(screenWidth);
    final gap = CheckoutTokens.getGap(screenWidth);

    return Column(
      children: [
        // Header with back button
        _buildDesktopHeader(context),

        // Main content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              left: CheckoutTokens.pageHorizontal,
              right: CheckoutTokens.pageHorizontal,
              top: CheckoutTokens.pageHorizontal,
              bottom: CheckoutTokens.pageHorizontal,
            ),
            child: Row(
              // NO SingleChildScrollView wrapper!
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left column: Order Items (scrolls internally)
                Flexible(
                  flex: 0,
                  child: SizedBox(
                    width: leftWidth,
                    child: OrderItemsPanel(width: leftWidth),
                  ),
                ),
                SizedBox(width: gap),

                // Middle column: Payment Keypad (fixed height, no scroll)
                Expanded(child: PaymentKeypadPanel()),
                SizedBox(width: gap),

                // Right column: Payment Options (actions sticky at bottom)
                Flexible(
                  flex: 0,
                  child: SizedBox(
                    width: CheckoutTokens.rightWidth,
                    child: PaymentOptionsPanel(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // COMPACT LAYOUT (<900dp) - Keypad + Options only, items in drawer
  // ============================================================================
  Widget _buildCompactLayout(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(CheckoutTokens.pageHorizontal),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Middle column: Payment Keypad
          Expanded(flex: 3, child: PaymentKeypadPanel()),
          const SizedBox(width: CheckoutTokens.gapNormal),

          // Right column: Payment Options
          Expanded(flex: 2, child: PaymentOptionsPanel()),
        ],
      ),
    );
  }

  // ============================================================================
  // COMPACT APP BAR (with cart badge)
  // ============================================================================
  AppBar _buildCompactAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: CheckoutTokens.surface,
      elevation: 0,
      title: Text(
        'Checkout',
        style: CheckoutTokens.textTitle.copyWith(
          fontSize: CheckoutTokens.fontSizeValue,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        // Cart icon with badge
        BlocBuilder<CheckoutBloc, CheckoutState>(
          builder: (context, state) {
            final itemCount = state is CheckoutLoaded ? state.items.length : 0;

            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  onPressed: () {
                    Scaffold.of(context).openEndDrawer();
                  },
                ),
                if (itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CheckoutTokens.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '$itemCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: CheckoutTokens.weightBold,
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
    );
  }

  // ============================================================================
  // DESKTOP HEADER (with back button)
  // ============================================================================
  Widget _buildDesktopHeader(BuildContext context) {
    return Container(
      height: 64, // Fixed height to prevent overflow
      padding: const EdgeInsets.symmetric(
        horizontal: CheckoutTokens.pageHorizontal,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: CheckoutTokens.surface,
        border: Border(
          bottom: BorderSide(color: CheckoutTokens.border, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 24),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back to Menu',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),

          // Title
          Flexible(
            child: Text(
              'Checkout',
              style: CheckoutTokens.textTitle.copyWith(
                fontSize: 20,
                fontWeight: CheckoutTokens.weightBold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 16),

          // Item count badge
          BlocBuilder<CheckoutBloc, CheckoutState>(
            builder: (context, state) {
              if (state is! CheckoutLoaded) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: CheckoutTokens.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${state.items.length} ${state.items.length == 1 ? 'item' : 'items'}',
                  style: CheckoutTokens.textBody.copyWith(
                    color: CheckoutTokens.primary,
                    fontWeight: CheckoutTokens.weightSemiBold,
                    fontSize: 14,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // ORDER DRAWER (compact mode)
  // ============================================================================
  Widget _buildOrderDrawer(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = screenWidth * 0.85;

    return Drawer(
      width: drawerWidth,
      child: OrderItemsPanel(width: drawerWidth),
    );
  }
}
