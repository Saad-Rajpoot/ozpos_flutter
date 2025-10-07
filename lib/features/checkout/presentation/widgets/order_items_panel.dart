import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../checkout/presentation/bloc/checkout_bloc.dart';
import '../checkout_tokens.dart';
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
        color: CheckoutTokens.surface,
        borderRadius: BorderRadius.circular(CheckoutTokens.radiusCard),
        border: Border.all(color: CheckoutTokens.border),
        boxShadow: CheckoutTokens.shadowCard,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(CheckoutTokens.cardPadding),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: CheckoutTokens.border, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order Items', style: CheckoutTokens.textTitle),
                Text(
                  '${state.items.length} ${state.items.length == 1 ? 'item' : 'items'}',
                  style: CheckoutTokens.textLabel,
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
        color: CheckoutTokens.surface,
        borderRadius: BorderRadius.circular(CheckoutTokens.radiusCard),
        border: Border.all(color: CheckoutTokens.border),
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
                color: CheckoutTokens.textMuted.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No items in cart',
                style: CheckoutTokens.textBody.copyWith(
                  color: CheckoutTokens.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add items from the menu to continue',
                style: CheckoutTokens.textMutedSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: CheckoutTokens.surface,
        borderRadius: BorderRadius.circular(CheckoutTokens.radiusCard),
        border: Border.all(color: CheckoutTokens.border),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}
