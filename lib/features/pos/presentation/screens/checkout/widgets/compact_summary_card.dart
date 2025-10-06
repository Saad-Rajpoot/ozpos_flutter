import 'package:flutter/material.dart';
import '../../../bloc/checkout_bloc.dart';
import '../checkout_tokens.dart';

/// Compact summary card - shows subtotal, tax, and total
/// Designed to be sticky at the bottom of order items panel
class CompactSummaryCard extends StatelessWidget {
  final CheckoutLoaded state;

  const CompactSummaryCard({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CheckoutTokens.cardPadding),
      decoration: BoxDecoration(
        color: CheckoutTokens.surface,
        border: Border(
          top: BorderSide(
            color: CheckoutTokens.border,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtotal
          _buildRow(
            'Subtotal',
            state.subtotal,
            subtitle: '${state.itemCount} ${state.itemCount == 1 ? 'item' : 'items'}',
          ),
          const SizedBox(height: 6),
          
          // Tax/GST
          _buildRow('GST (10%)', state.tax),
          const SizedBox(height: 8),
          
          // Divider
          Container(
            height: 1,
            color: CheckoutTokens.border,
          ),
          const SizedBox(height: 8),
          
          // Total
          _buildRow(
            'Total',
            state.grandTotal,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    double amount, {
    String? subtitle,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: isTotal
                    ? CheckoutTokens.textTitle.copyWith(
                        fontWeight: CheckoutTokens.weightBold,
                      )
                    : CheckoutTokens.textLabel,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: CheckoutTokens.textMutedSmall,
                ),
              ],
            ],
          ),
        ),
        
        // Amount
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: isTotal
              ? CheckoutTokens.textValue.copyWith(
                  fontSize: CheckoutTokens.fontSizeLarge,
                  fontWeight: CheckoutTokens.weightBold,
                  color: CheckoutTokens.success,
                )
              : CheckoutTokens.textBody.copyWith(
                  fontWeight: CheckoutTokens.weightSemiBold,
                ),
        ),
      ],
    );
  }
}
