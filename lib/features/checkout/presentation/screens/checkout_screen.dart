import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/app_router.dart';
import '../../../../core/widgets/sidebar_nav.dart';
import '../../../checkout/presentation/widgets/order_items_panel.dart';
import '../../../checkout/presentation/widgets/payment_keypad_panel.dart';
import '../../../checkout/presentation/widgets/payment_options_panel.dart';
import '../../../checkout/presentation/bloc/cart_bloc.dart';
import '../../../checkout/presentation/bloc/checkout_bloc.dart';
import '../constant/checkout_constants.dart';

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
    final isCompact = CheckoutConstants.isCompact(screenWidth);

    // Get cart items from shared CartBloc using BlocBuilder for proper state access
    return MultiBlocListener(
      listeners: [
        BlocListener<CartBloc, CartState>(
          listenWhen: (previous, current) =>
              previous != current && current is CartLoaded,
          listener: (context, cartState) {
            if (cartState is! CartLoaded) return;
            final checkoutBloc = context.read<CheckoutBloc>();
            final checkoutState = checkoutBloc.state;

            if (checkoutState.viewState == null) {
              return;
            }

            if (kDebugMode) {
              debugPrint(
                '✅ Checkout: Syncing ${cartState.items.length} items from CartBloc to CheckoutBloc',
              );
            }

            checkoutBloc.add(SyncCartItems(items: cartState.items));
          },
        ),
        BlocListener<CheckoutBloc, CheckoutState>(
          listenWhen: (previous, current) => current is CheckoutSuccess,
          listener: (context, checkoutState) {
            context.read<CartBloc>().add(ClearCart());
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRouter.dashboard,
              (route) => false,
            );
          },
        ),
      ],
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, cartState) {
          // Extract cart items
          List<CartLineItem> items = [];
          if (cartState is CartLoaded) {
            items = cartState.items;
            final checkoutState = context.read<CheckoutBloc>().state;
            final needsInitialSync = checkoutState is CheckoutInitial ||
                checkoutState is CheckoutError;

            if (needsInitialSync) {
              final itemsSnapshot = List<CartLineItem>.from(items);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;

                final currentCheckoutState = context.read<CheckoutBloc>().state;
                final isAlreadySynced =
                    currentCheckoutState is CheckoutLoaded ||
                        currentCheckoutState is CheckoutProcessing ||
                        currentCheckoutState is CheckoutSuccess;

                if (isAlreadySynced) return;

                if (kDebugMode) {
                  debugPrint(
                    '✅ Checkout: Initial sync with ${itemsSnapshot.length} cart items',
                  );
                }
                context
                    .read<CheckoutBloc>()
                    .add(InitializeCheckout(items: itemsSnapshot));
              });
            }
          } else {
            if (kDebugMode) {
              debugPrint(
                '⚠️ Checkout: CartBloc state is not CartLoaded, state type: ${cartState.runtimeType}',
              );
            }
          }

          return Scaffold(
            backgroundColor: CheckoutConstants.background,
            appBar: isCompact ? _buildCompactAppBar(context) : null,
            endDrawer: isCompact ? _buildOrderDrawer(context) : null,
            body: BlocBuilder<CheckoutBloc, CheckoutState>(
              builder: (context, checkoutState) {
                final showBlockingOverlay =
                    checkoutState is CheckoutProcessing ||
                        checkoutState is CheckoutInitial ||
                        checkoutState is CheckoutSuccess;
                final checkoutError =
                    checkoutState is CheckoutError ? checkoutState : null;

                return Stack(
                  children: [
                    Positioned.fill(
                      child: Row(
                        children: [
                          if (!isCompact)
                            const SidebarNav(activeRoute: AppRouter.checkout),
                          Expanded(
                            child: isCompact
                                ? _buildCompactLayout(context)
                                : _buildDesktopLayout(context, screenWidth),
                          ),
                        ],
                      ),
                    ),
                    if (checkoutError != null)
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: CheckoutConstants.pageHorizontal,
                              vertical: CheckoutConstants.gapNormal,
                            ),
                            child: _CheckoutErrorBanner(error: checkoutError),
                          ),
                        ),
                      ),
                    if (showBlockingOverlay)
                      Positioned.fill(
                        child: AbsorbPointer(
                          absorbing: true,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ============================================================================
  // DESKTOP LAYOUT (≥900dp) - Three columns, NO outer scroll
  // ============================================================================
  Widget _buildDesktopLayout(BuildContext context, double screenWidth) {
    final leftWidth = CheckoutConstants.getLeftWidth(screenWidth);
    final gap = CheckoutConstants.getGap(screenWidth);

    return Column(
      children: [
        // Header with back button
        _buildDesktopHeader(context),

        // Main content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(
              left: CheckoutConstants.pageHorizontal,
              right: CheckoutConstants.pageHorizontal,
              top: CheckoutConstants.pageHorizontal,
              bottom: CheckoutConstants.pageHorizontal,
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
                    width: CheckoutConstants.rightWidth,
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
      padding: const EdgeInsets.all(CheckoutConstants.pageHorizontal),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Middle column: Payment Keypad
          Expanded(flex: 3, child: PaymentKeypadPanel()),
          const SizedBox(width: CheckoutConstants.gapNormal),

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
      backgroundColor: CheckoutConstants.surface,
      elevation: 0,
      title: Text(
        'Checkout',
        style: CheckoutConstants.textTitle.copyWith(
          fontSize: CheckoutConstants.fontSizeValue,
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
            final itemCount = state.viewState?.items.length ?? 0;

            return Stack(
              children: [
                Builder(
                  builder: (buttonContext) => IconButton(
                    icon: const Icon(Icons.shopping_bag_outlined),
                    onPressed: () {
                      Scaffold.of(buttonContext).openEndDrawer();
                    },
                  ),
                ),
                if (itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: CheckoutConstants.error,
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
                          fontWeight: CheckoutConstants.weightBold,
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
        horizontal: CheckoutConstants.pageHorizontal,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: CheckoutConstants.surface,
        border: Border(
          bottom: BorderSide(color: CheckoutConstants.border, width: 1),
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
              style: CheckoutConstants.textTitle.copyWith(
                fontSize: 20,
                fontWeight: CheckoutConstants.weightBold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 16),

          // Item count badge
          BlocBuilder<CheckoutBloc, CheckoutState>(
            builder: (context, state) {
              final loaded = state.viewState;
              if (loaded == null) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: CheckoutConstants.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${loaded.items.length} ${loaded.items.length == 1 ? 'item' : 'items'}',
                  style: CheckoutConstants.textBody.copyWith(
                    color: CheckoutConstants.primary,
                    fontWeight: CheckoutConstants.weightSemiBold,
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

class _CheckoutErrorBanner extends StatelessWidget {
  const _CheckoutErrorBanner({required this.error});

  final CheckoutError error;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      color: CheckoutConstants.errorLight,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CheckoutConstants.cardPadding,
          vertical: CheckoutConstants.gapSmall,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: CheckoutConstants.error,
            ),
            const SizedBox(width: CheckoutConstants.gapSmall),
            Expanded(
              child: Text(
                error.message,
                style: CheckoutConstants.textBody.copyWith(
                  color: CheckoutConstants.error,
                  fontWeight: CheckoutConstants.weightSemiBold,
                ),
              ),
            ),
            if (error.canDismiss)
              TextButton(
                onPressed: () =>
                    context.read<CheckoutBloc>().add(DismissError()),
                child: const Text('Dismiss'),
              ),
          ],
        ),
      ),
    );
  }
}
