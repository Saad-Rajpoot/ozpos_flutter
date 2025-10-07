import 'package:flutter/material.dart';
import '../../../presentation/bloc/checkout_bloc.dart';

/// Order Summary Card - Shows complete breakdown of order totals
class OrderSummaryCard extends StatelessWidget {
  final CheckoutLoaded state;

  const OrderSummaryCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
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
              'Order Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Subtotal
            _buildSummaryRow(
              'Subtotal',
              state.subtotal,
              subtitle: '${state.itemCount} items',
            ),

            // Tips
            if (state.tipAmount > 0) ...[
              const SizedBox(height: 8),
              _buildSummaryRow(
                state.tipPercent > 0 ? 'Tip (${state.tipPercent}%)' : 'Tip',
                state.tipAmount,
                color: const Color(0xFF2196F3),
              ),
            ],

            // Discounts
            if (state.discountAmount > 0) ...[
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Discount (${state.discountPercent}%)',
                -state.discountAmount,
                color: const Color(0xFFD32F2F),
              ),
            ],

            // Vouchers
            if (state.voucherTotal > 0) ...[
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Vouchers',
                -state.voucherTotal,
                subtitle: '${state.appliedVouchers.length} applied',
                color: const Color(0xFF4CAF50),
              ),
            ],

            // Loyalty
            if (state.loyaltyRedemption > 0) ...[
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Loyalty Points',
                -state.loyaltyRedemption,
                color: const Color(0xFFFF9800),
              ),
            ],

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Tax
            _buildSummaryRow('GST (10%)', state.tax, isImportant: true),

            const SizedBox(height: 12),
            const Divider(thickness: 2),
            const SizedBox(height: 12),

            // Grand Total
            _buildSummaryRow('TOTAL', state.grandTotal, isGrandTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    String? subtitle,
    Color? color,
    bool isImportant = false,
    bool isGrandTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: isGrandTotal ? 18 : (isImportant ? 15 : 14),
                  fontWeight: isGrandTotal
                      ? FontWeight.w700
                      : (isImportant ? FontWeight.w600 : FontWeight.w500),
                  color:
                      color ?? (isGrandTotal ? Colors.black87 : Colors.black87),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          amount < 0
              ? '-\$${(-amount).toStringAsFixed(2)}'
              : '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isGrandTotal ? 22 : (isImportant ? 16 : 15),
            fontWeight: isGrandTotal
                ? FontWeight.w700
                : (isImportant ? FontWeight.w600 : FontWeight.w600),
            color:
                color ??
                (isGrandTotal ? const Color(0xFF2196F3) : Colors.black87),
          ),
        ),
      ],
    );
  }
}
