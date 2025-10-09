import 'package:flutter/material.dart';
import '../../../checkout/presentation/bloc/checkout_bloc.dart';
import '../constant/checkout_constants.dart';

/// Compact summary card - shows subtotal, tax, and total
/// Designed to be sticky at the bottom of order items panel
class CompactSummaryCard extends StatelessWidget {
  final CheckoutLoaded state;

  const CompactSummaryCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(CheckoutConstants.cardPadding),
      decoration: BoxDecoration(
        color: CheckoutConstants.surface,
        border: Border(
          top: BorderSide(color: CheckoutConstants.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
            subtitle:
                '${state.itemCount} ${state.itemCount == 1 ? 'item' : 'items'}',
          ),
          const SizedBox(height: 6),

          // Tax/GST
          _buildRow('GST (10%)', state.tax),
          const SizedBox(height: 8),

          // Divider
          Container(height: 1, color: CheckoutConstants.border),
          const SizedBox(height: 8),

          // Total
          _buildRow('Total', state.grandTotal, isTotal: true),
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
                    ? CheckoutConstants.textTitle.copyWith(
                        fontWeight: CheckoutConstants.weightBold,
                      )
                    : CheckoutConstants.textLabel,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle, style: CheckoutConstants.textMutedSmall),
              ],
            ],
          ),
        ),

        // Amount
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: isTotal
              ? CheckoutConstants.textValue.copyWith(
                  fontSize: CheckoutConstants.fontSizeLarge,
                  fontWeight: CheckoutConstants.weightBold,
                  color: CheckoutConstants.success,
                )
              : CheckoutConstants.textBody.copyWith(
                  fontWeight: CheckoutConstants.weightSemiBold,
                ),
        ),
      ],
    );
  }
}
