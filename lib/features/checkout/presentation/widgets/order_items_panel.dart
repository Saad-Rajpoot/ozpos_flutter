import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../checkout/presentation/bloc/cart_bloc.dart';
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
      buildWhen: _shouldRebuildShell,
      builder: (context, state) {
        final viewState = state.viewState;
        if (viewState == null) {
          return _buildLoadingSkeleton();
        }

        if (viewState.items.isEmpty) {
          return _buildEmptyState();
        }

        return _OrderItemsContent(width: width);
      },
    );
  }

  bool _shouldRebuildShell(CheckoutState previous, CheckoutState current) {
    final previousLoaded = previous.viewState;
    final currentLoaded = current.viewState;

    if (previousLoaded == null && currentLoaded == null) {
      return previous.runtimeType != current.runtimeType;
    }

    if (previousLoaded == null || currentLoaded == null) {
      return true;
    }

    return previousLoaded.items.isNotEmpty != currentLoaded.items.isNotEmpty;
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

class _OrderItemsContent extends StatelessWidget {
  final double width;

  const _OrderItemsContent({required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: CheckoutConstants.surface,
        borderRadius: BorderRadius.circular(CheckoutConstants.radiusCard),
        border: Border.all(color: CheckoutConstants.border),
        boxShadow: CheckoutConstants.shadowCard,
      ),
      child: const Column(
        children: [
          _OrderItemsHeader(),
          Expanded(child: _OrderItemsList()),
          _OrderItemsSummary(),
        ],
      ),
    );
  }
}

class _OrderItemsHeader extends StatelessWidget {
  const _OrderItemsHeader();

  @override
  Widget build(BuildContext context) {
    final itemCount = context.select<CheckoutBloc, int>(
      (bloc) => bloc.state.viewState?.items.length ?? 0,
    );

    return Container(
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
            '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
            style: CheckoutConstants.textLabel,
          ),
        ],
      ),
    );
  }
}

class _OrderItemsList extends StatelessWidget {
  const _OrderItemsList();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CheckoutBloc, CheckoutState, List<CartLineItem>>(
      selector: (state) => state.viewState?.items ?? const <CartLineItem>[],
      builder: (context, items) {
        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: items.length,
          itemBuilder: (context, index) {
            return CompactOrderLine(item: items[index]);
          },
        );
      },
    );
  }
}

class _OrderItemsSummary extends StatelessWidget {
  const _OrderItemsSummary();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<CheckoutBloc, CheckoutState, CheckoutLoaded?>(
      selector: (state) => state.viewState,
      builder: (context, checkoutState) {
        if (checkoutState == null) {
          return const SizedBox.shrink();
        }
        return CompactSummaryCard(state: checkoutState);
      },
    );
  }
}
