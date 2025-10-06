import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/checkout_bloc.dart';
import '../../../../domain/entities/payment_method.dart';
import '../checkout_tokens.dart';
import 'compact_keypad.dart';

/// Payment Keypad Panel - Middle column
/// 
/// Features:
/// - Cash amount display (if Cash selected)
/// - Compact keypad (fixed height)
/// - Totals breakdown
/// - NO scrolling (everything fits)
class PaymentKeypadPanel extends StatelessWidget {
  const PaymentKeypadPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        if (state is! CheckoutLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final isCash = state.selectedMethod == PaymentMethod.cash;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cash display (only for cash payments)
            if (isCash) ...[
              _buildCashDisplay(state),
              const SizedBox(height: CheckoutTokens.gapNormal),
            ],
            
            // Keypad (only for cash)
            if (isCash) ...[
              const CompactKeypad(),
              const SizedBox(height: CheckoutTokens.gapNormal),
            ],
            
            // Totals card (always shown)
            _buildTotalsCard(state),
          ],
        );
      },
    );
  }

  Widget _buildCashDisplay(CheckoutLoaded state) {
    final cashText = state.cashReceived.isEmpty ? '0.00' : state.cashReceived;
    final isSufficient = state.cashReceivedNum >= state.grandTotal;

    return Container(
      padding: const EdgeInsets.all(CheckoutTokens.cardPadding),
      decoration: BoxDecoration(
        color: CheckoutTokens.surface,
        borderRadius: BorderRadius.circular(CheckoutTokens.radiusCard),
        border: Border.all(
          color: isSufficient ? CheckoutTokens.success : CheckoutTokens.border,
          width: isSufficient ? 2 : 1,
        ),
        boxShadow: CheckoutTokens.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cash Received',
            style: CheckoutTokens.textLabel,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '\$$cashText',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: CheckoutTokens.weightBold,
                  color: CheckoutTokens.textPrimary,
                ),
              ),
              if (isSufficient && state.cashReceivedNum > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: CheckoutTokens.success,
                    borderRadius: BorderRadius.circular(CheckoutTokens.radiusChip),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Sufficient',
                        style: CheckoutTokens.textMutedSmall.copyWith(
                          color: Colors.white,
                          fontWeight: CheckoutTokens.weightSemiBold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          // Change due
          if (state.cashChange > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: CheckoutTokens.successLight,
                borderRadius: BorderRadius.circular(CheckoutTokens.radiusButton),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Change Due',
                    style: CheckoutTokens.textLabel.copyWith(
                      color: CheckoutTokens.success,
                      fontWeight: CheckoutTokens.weightSemiBold,
                    ),
                  ),
                  Text(
                    '\$${state.cashChange.toStringAsFixed(2)}',
                    style: CheckoutTokens.textValue.copyWith(
                      color: CheckoutTokens.success,
                      fontWeight: CheckoutTokens.weightBold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalsCard(CheckoutLoaded state) {
    return Container(
      padding: const EdgeInsets.all(CheckoutTokens.cardPadding),
      decoration: BoxDecoration(
        color: CheckoutTokens.surface,
        borderRadius: BorderRadius.circular(CheckoutTokens.radiusCard),
        border: Border.all(color: CheckoutTokens.border),
        boxShadow: CheckoutTokens.shadowCard,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTotalRow('Subtotal', state.subtotal),
          if (state.tipAmount > 0) ...[
            const SizedBox(height: 6),
            _buildTotalRow('Tip', state.tipAmount, color: CheckoutTokens.primary),
          ],
          if (state.discountAmount > 0) ...[
            const SizedBox(height: 6),
            _buildTotalRow('Discount', -state.discountAmount, color: CheckoutTokens.error),
          ],
          if (state.voucherTotal > 0) ...[
            const SizedBox(height: 6),
            _buildTotalRow('Vouchers', -state.voucherTotal, color: CheckoutTokens.success),
          ],
          if (state.loyaltyRedemption > 0) ...[
            const SizedBox(height: 6),
            _buildTotalRow('Loyalty', -state.loyaltyRedemption, color: CheckoutTokens.warning),
          ],
          const SizedBox(height: 6),
          _buildTotalRow('Tax (10%)', state.tax),
          const SizedBox(height: 8),
          Container(
            height: 1,
            color: CheckoutTokens.border,
          ),
          const SizedBox(height: 8),
          _buildTotalRow(
            'TOTAL',
            state.grandTotal,
            isGrandTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount, {
    Color? color,
    bool isGrandTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isGrandTotal
              ? CheckoutTokens.textTitle.copyWith(
                  fontWeight: CheckoutTokens.weightBold,
                )
              : CheckoutTokens.textLabel,
        ),
        Text(
          amount < 0
              ? '-\$${(-amount).toStringAsFixed(2)}'
              : '\$${amount.toStringAsFixed(2)}',
          style: isGrandTotal
              ? CheckoutTokens.textValue.copyWith(
                  fontSize: CheckoutTokens.fontSizeLarge,
                  fontWeight: CheckoutTokens.weightBold,
                  color: CheckoutTokens.success,
                )
              : CheckoutTokens.textBody.copyWith(
                  fontWeight: CheckoutTokens.weightSemiBold,
                  color: color,
                ),
        ),
      ],
    );
  }
}
