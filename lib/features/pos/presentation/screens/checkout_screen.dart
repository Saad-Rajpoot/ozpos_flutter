import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../bloc/checkout_bloc.dart';
import '../bloc/cart_bloc.dart';
import '../widgets/checkout/payment_method_selector.dart';
import '../widgets/checkout/cash_keypad.dart';
import '../widgets/checkout/tip_section.dart';
import '../widgets/checkout/discount_section.dart';
import '../widgets/checkout/order_summary_card.dart';
import '../widgets/checkout/split_payment_section.dart';
import '../widgets/checkout/checkout_item_list.dart';
import '../../domain/entities/payment_method.dart';

/// Checkout Screen - Pixel-perfect implementation matching React prototype
/// 
/// Responsive breakpoints:
/// - Mobile: < 768px (single column, scrollable)
/// - Tablet: 768px - 1024px (two column)
/// - Desktop: > 1024px (three column with sidebar)
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _CheckoutScreenWrapper();
  }
}

class _CheckoutScreenWrapper extends StatelessWidget {
  const _CheckoutScreenWrapper();

  @override
  Widget build(BuildContext context) {
    // Try to get cart items from existing CartBloc, or use empty list
    List<CartLineItem> items = [];
    
    try {
      final cartBloc = Provider.of<CartBloc>(context, listen: false);
      final cartState = cartBloc.state;
      items = cartState is CartLoaded ? cartState.items : [];
    } catch (e) {
      // CartBloc not available in tree, that's okay - use empty cart for demo
      print('CartBloc not found, starting with empty cart for demo');
    }
    
    return BlocProvider(
      create: (context) => CheckoutBloc()..add(InitializeCheckout(items: items)),
      child: const _CheckoutScreenContent(),
    );
  }
}

class _CheckoutScreenContent extends StatelessWidget {
  const _CheckoutScreenContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CheckoutBloc, CheckoutState>(
      listener: (context, state) {
        if (state is CheckoutSuccess) {
          _showSuccessDialog(context, state);
        } else if (state is CheckoutError) {
          _showErrorSnackBar(context, state.message);
        }
      },
      builder: (context, state) {
        if (state is! CheckoutLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return _buildResponsiveLayout(context, state);
      },
    );
  }

  Widget _buildResponsiveLayout(BuildContext context, CheckoutLoaded state) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Responsive breakpoints matching React prototype
    if (screenWidth >= 1024) {
      return _buildDesktopLayout(context, state);
    } else if (screenWidth >= 768) {
      return _buildTabletLayout(context, state);
    } else {
      return _buildMobileLayout(context, state);
    }
  }

  // ============================================================================
  // DESKTOP LAYOUT (>= 1024px) - Three columns with sidebar
  // ============================================================================
  Widget _buildDesktopLayout(BuildContext context, CheckoutLoaded state) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildAppBar(context, state),
          Expanded(
            child: Row(
              children: [
                // Left Column - Items & Summary
                Expanded(
                  flex: 2,
                  child: _buildLeftColumn(context, state),
                ),
                
                // Middle Column - Payment & Tips
                Expanded(
                  flex: 3,
                  child: _buildMiddleColumn(context, state),
                ),
                
                // Right Column - Actions
                SizedBox(
                  width: 320,
                  child: _buildRightColumn(context, state),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // TABLET LAYOUT (768px - 1024px) - Two columns, no sidebar
  // ============================================================================
  Widget _buildTabletLayout(BuildContext context, CheckoutLoaded state) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Row(
        children: [
          // Left Column - Items, Summary, Payment
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CheckoutItemList(items: state.items),
                  const SizedBox(height: 16),
                  OrderSummaryCard(state: state),
                  const SizedBox(height: 16),
                  _buildPaymentSection(context, state),
                ],
              ),
            ),
          ),
          
          // Right Column - Tips, Discounts, Actions
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: _buildRightColumn(context, state),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // MOBILE LAYOUT (< 768px) - Single column, scrollable
  // ============================================================================
  Widget _buildMobileLayout(BuildContext context, CheckoutLoaded state) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CheckoutItemList(items: state.items),
            const SizedBox(height: 16),
            OrderSummaryCard(state: state),
            const SizedBox(height: 16),
            TipSection(state: state),
            const SizedBox(height: 16),
            DiscountSection(state: state),
            const SizedBox(height: 16),
            _buildPaymentSection(context, state),
            const SizedBox(height: 16),
            _buildActionButtons(context, state),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // COLUMN BUILDERS
  // ============================================================================

  Widget _buildLeftColumn(BuildContext context, CheckoutLoaded state) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CheckoutItemList(items: state.items),
                  const SizedBox(height: 16),
                  OrderSummaryCard(state: state),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiddleColumn(BuildContext context, CheckoutLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPaymentSection(context, state),
          const SizedBox(height: 16),
          TipSection(state: state),
          const SizedBox(height: 16),
          DiscountSection(state: state),
        ],
      ),
    );
  }

  Widget _buildRightColumn(BuildContext context, CheckoutLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Expanded(child: Container()), // Spacer
        _buildActionButtons(context, state),
        const SizedBox(height: 16),
      ],
    );
  }

  // ============================================================================
  // APP BAR
  // ============================================================================

  Widget _buildAppBar(BuildContext context, CheckoutLoaded state) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          const Text(
            'Checkout',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          // Mode toggle
          _buildModeToggle(context, state),
        ],
      ),
    );
  }

  Widget _buildModeToggle(BuildContext context, CheckoutLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildModeButton(
            context,
            'Single',
            !state.isSplitMode,
            () => context.read<CheckoutBloc>().add(ToggleSplitMode()),
          ),
          _buildModeButton(
            context,
            'Split',
            state.isSplitMode,
            () => context.read<CheckoutBloc>().add(ToggleSplitMode()),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: isActive ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.black87 : Colors.black54,
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // PAYMENT SECTION
  // ============================================================================

  Widget _buildPaymentSection(BuildContext context, CheckoutLoaded state) {
    if (state.isSplitMode) {
      return SplitPaymentSection(state: state);
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            PaymentMethodSelector(state: state),
            
            // Show keypad for cash
            if (state.selectedMethod == PaymentMethod.cash) ...[
              const SizedBox(height: 16),
              CashKeypad(state: state),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================================
  // ACTION BUTTONS
  // ============================================================================

  Widget _buildActionButtons(BuildContext context, CheckoutLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Pay Now Button
        ElevatedButton(
          onPressed: state.canPay
              ? () => context.read<CheckoutBloc>().add(ProcessPayment())
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
            disabledBackgroundColor: const Color(0xFFE0E0E0),
            disabledForegroundColor: Colors.black38,
          ),
          child: Text(
            state.isSplitMode
                ? 'Complete Split Payment'
                : 'Pay ${_formatCurrency(state.grandTotal)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Pay Later Button
        OutlinedButton(
          onPressed: () => context.read<CheckoutBloc>().add(PayLater()),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            side: const BorderSide(color: Color(0xFF2196F3)),
            foregroundColor: const Color(0xFF2196F3),
          ),
          child: const Text(
            'Pay Later',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================================
  // DIALOGS & SNACKBARS
  // ============================================================================

  void _showSuccessDialog(BuildContext context, CheckoutSuccess state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 32),
            ),
            const SizedBox(width: 12),
            const Text('Payment Success'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${state.orderId}'),
            const SizedBox(height: 8),
            Text(
              state.paidAmount > 0
                  ? 'Amount Paid: ${_formatCurrency(state.paidAmount)}'
                  : 'Order saved as unpaid',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }
}
