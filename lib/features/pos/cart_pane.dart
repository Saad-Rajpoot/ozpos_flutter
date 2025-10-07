import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/navigation/app_router.dart';
import '../../core/navigation/navigation_service.dart';
import '../checkout/presentation/bloc/cart_bloc.dart';
import '../tables/presentation/widgets/table_selection_modal.dart';

/// Cart Pane - Right sidebar for order management
/// Width: 360px (desktop), 320px (tablet-L), drawer (mobile)
class CartPane extends StatelessWidget {
  const CartPane({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(-2, 0),
          ),
        ],
      ),
      child: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is! CartLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Header with order type and table selector
              _buildHeader(context, state),

              // Line items list (scrollable)
              Expanded(
                child: state.items.isEmpty
                    ? _buildEmptyCart()
                    : _buildLineItemsList(context, state),
              ),

              // Totals section
              if (state.items.isNotEmpty) _buildTotalsSection(state),

              // Action buttons (sticky footer)
              if (state.items.isNotEmpty) _buildActionButtons(context, state),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================================
  // HEADER
  // ==========================================================================

  Widget _buildHeader(BuildContext context, CartLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order type segmented control
          _buildOrderTypeSelector(context, state),
          const SizedBox(height: 12),

          // Table selector (only for dine-in)
          if (state.orderType == OrderType.dineIn)
            _buildTableSelector(context, state),

          // Customer search field (for takeaway/delivery)
          if (state.orderType != OrderType.dineIn) _buildCustomerField(context),
        ],
      ),
    );
  }

  Widget _buildOrderTypeSelector(BuildContext context, CartLoaded state) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: _OrderTypeButton(
              label: 'Dine-In',
              icon: Icons.restaurant,
              color: const Color(0xFF10B981), // Green
              isSelected: state.orderType == OrderType.dineIn,
              onTap: () {
                context.read<CartBloc>().add(
                  const ChangeOrderType(orderType: OrderType.dineIn),
                );
              },
            ),
          ),
          Expanded(
            child: _OrderTypeButton(
              label: 'Takeaway',
              icon: Icons.shopping_bag,
              color: const Color(0xFFF59E0B), // Orange
              isSelected: state.orderType == OrderType.takeaway,
              onTap: () {
                context.read<CartBloc>().add(
                  const ChangeOrderType(orderType: OrderType.takeaway),
                );
              },
            ),
          ),
          Expanded(
            child: _OrderTypeButton(
              label: 'Delivery',
              icon: Icons.delivery_dining,
              color: const Color(0xFF8B5CF6), // Purple
              isSelected: state.orderType == OrderType.delivery,
              onTap: () {
                context.read<CartBloc>().add(
                  const ChangeOrderType(orderType: OrderType.delivery),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableSelector(BuildContext context, CartLoaded state) {
    return InkWell(
      onTap: () => _showTableSelection(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          border: Border.all(color: const Color(0xFFD1D5DB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.table_bar, size: 20, color: Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Text(
              state.selectedTable != null
                  ? 'Table ${state.selectedTable!.number}'
                  : 'Select Table',
              style: TextStyle(
                fontSize: 14,
                color: state.selectedTable != null
                    ? const Color(0xFF111827)
                    : const Color(0xFF9CA3AF),
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_drop_down,
              size: 20,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerField(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Customer name',
            prefixIcon: const Icon(Icons.person_outline, size: 20),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
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
            fillColor: const Color(0xFFF9FAFB),
          ),
          style: const TextStyle(fontSize: 14),
          onChanged: (value) {
            context.read<CartBloc>().add(UpdateCustomer(name: value));
          },
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: 'Phone number (optional)',
            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
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
            fillColor: const Color(0xFFF9FAFB),
          ),
          style: const TextStyle(fontSize: 14),
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            context.read<CartBloc>().add(UpdateCustomer(phone: value));
          },
        ),
      ],
    );
  }

  void _showTableSelection(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CartBloc>(),
        child: const TableSelectionModal(),
      ),
    );
  }

  // ==========================================================================
  // LINE ITEMS LIST
  // ==========================================================================

  Widget _buildLineItemsList(BuildContext context, CartLoaded state) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = state.items[index];
        return _LineItemCard(lineItem: item);
      },
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Cart is empty',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items from the menu',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // TOTALS SECTION
  // ==========================================================================

  Widget _buildTotalsSection(CartLoaded state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          _buildTotalRow('Subtotal', state.subtotal, false),
          const SizedBox(height: 8),
          _buildTotalRow('GST (10%)', state.gst, false),
          const Divider(height: 24),
          _buildTotalRow('Total', state.total, true),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            color: const Color(0xFF111827),
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // ACTION BUTTONS
  // ==========================================================================

  Widget _buildActionButtons(BuildContext context, CartLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // PAY NOW button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _handlePayNow(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'PAY NOW',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // SEND TO KITCHEN button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _handleSendToKitchen(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'SEND TO KITCHEN',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Clear Cart link
          TextButton(
            onPressed: () => _handleClearCart(context),
            child: const Text(
              'Clear Cart',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handlePayNow(BuildContext context) {
    final cartState = context.read<CartBloc>().state as CartLoaded;

    debugPrint(
      '💳 Cart: Navigating to checkout with ${cartState.items.length} items',
    );
    for (var item in cartState.items) {
      debugPrint('  - ${item.menuItem.name} x${item.quantity}');
    }

    // Navigate to checkout - CartBloc is already in widget tree
    NavigationService.pushNamed(AppRouter.checkout);
  }

  void _handleSendToKitchen(BuildContext context) {
    // TODO: Send order to kitchen
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Order sent to kitchen!')));
    context.read<CartBloc>().add(ClearCart());
  }

  void _handleClearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text('Are you sure you want to remove all items?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CartBloc>().add(ClearCart());
              Navigator.pop(dialogContext);
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ORDER TYPE BUTTON
// ============================================================================

class _OrderTypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _OrderTypeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// LINE ITEM CARD
// ============================================================================

class _LineItemCard extends StatelessWidget {
  final CartLineItem lineItem;

  const _LineItemCard({required this.lineItem});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name, Qty stepper, Delete
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item name
              Expanded(
                child: Text(
                  lineItem.menuItem.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),

              // Quantity stepper
              _buildQuantityStepper(context),

              const SizedBox(width: 8),

              // Delete button
              InkWell(
                onTap: () {
                  context.read<CartBloc>().add(
                    RemoveLineItem(lineItemId: lineItem.id),
                  );
                },
                child: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Color(0xFFEF4444),
                ),
              ),
            ],
          ),

          // Modifier chips
          if (lineItem.modifierSummary.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: lineItem.modifierSummary.split(', ').map((modifier) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    modifier,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 8),

          // Price row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${lineItem.unitPrice.toStringAsFixed(2)} each',
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
              Text(
                '\$${lineItem.lineTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityStepper(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              context.read<CartBloc>().add(
                UpdateLineItemQuantity(
                  lineItemId: lineItem.id,
                  newQuantity: lineItem.quantity - 1,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.remove,
                size: 16,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${lineItem.quantity}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              context.read<CartBloc>().add(
                UpdateLineItemQuantity(
                  lineItemId: lineItem.id,
                  newQuantity: lineItem.quantity + 1,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.add, size: 16, color: Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }
}
