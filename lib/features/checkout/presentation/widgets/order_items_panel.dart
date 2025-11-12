import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../checkout/presentation/bloc/checkout_bloc.dart';
import '../constant/checkout_constants.dart';
import 'compact_order_line.dart';
import 'compact_summary_card.dart';

/// Order Items Panel - Left column in checkout
///
/// Features:
/// - Scrollable list of items
/// - Sticky summary card at bottom
/// - Empty state when no items
/// - Compact 2-row line items
class OrderItemsPanel extends StatelessWidget {
  final double width;

  const OrderItemsPanel({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        if (state is! CheckoutLoaded) {
          return _buildLoadingSkeleton();
        }

        if (state.items.isEmpty) {
          return _buildEmptyState();
        }

        return _buildItemsList(state);
      },
    );
  }

  Widget _buildItemsList(CheckoutLoaded state) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: CheckoutConstants.surface,
        borderRadius: BorderRadius.circular(CheckoutConstants.radiusCard),
        border: state.items.isEmpty
            ? null
            : Border.all(color: CheckoutConstants.border),
        boxShadow: CheckoutConstants.shadowCard,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(CheckoutConstants.cardPadding),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: CheckoutConstants.border, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order Items', style: CheckoutConstants.textTitle),
                Text(
                  '${state.items.length} ${state.items.length == 1 ? 'item' : 'items'}',
                  style: CheckoutConstants.textLabel,
                ),
              ],
            ),
          ),

          // Scrollable items list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                return CompactOrderLine(item: state.items[index]);
              },
            ),
          ),

          // Sticky summary at bottom (non-scrolling)
          CompactSummaryCard(state: state),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: CheckoutConstants.surface,
        borderRadius: BorderRadius.circular(CheckoutConstants.radiusCard),
        border: Border.all(color: CheckoutConstants.border),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 64,
                color: CheckoutConstants.textMuted.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No items in cart',
                style: CheckoutConstants.textBody.copyWith(
                  color: CheckoutConstants.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add items from the menu to continue',
                style: CheckoutConstants.textMutedSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return SizedBox(
      width: width,
      child: const SizedBox.shrink(),
    );
  }
}
