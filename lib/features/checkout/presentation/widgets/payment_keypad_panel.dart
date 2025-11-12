import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../checkout/presentation/bloc/checkout_bloc.dart';
import '../../domain/entities/payment_method_type.dart';
import '../constant/checkout_constants.dart';
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
          return const SizedBox.shrink();
        }

        final isCash = state.selectedMethod == PaymentMethodType.cash;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Cash display (only for cash payments)
            if (isCash) ...[
              _buildCashDisplay(state),
              const SizedBox(height: CheckoutConstants.gapNormal),
            ],

            // Keypad (only for cash)
            if (isCash) ...[
              const CompactKeypad(),
              const SizedBox(height: CheckoutConstants.gapNormal),
            ],

            // Totals card (always shown)
            _buildTotalsCard(state),
          ],
        );
      },
    );
  }

  Widget _buildCashDisplay(CheckoutLoaded state) {
    final cashText =
        state.cashReceived.isEmpty ? '0.00' : state.cashReceived.toString();
    final isSufficient = state.cashReceivedNum >= state.grandTotal;

    return Container(
      padding: const EdgeInsets.all(CheckoutConstants.cardPadding),
      decoration: BoxDecoration(
        color: CheckoutConstants.surface,
        borderRadius: BorderRadius.circular(CheckoutConstants.radiusCard),
        border: Border.all(
          color: isSufficient
              ? CheckoutConstants.success
              : CheckoutConstants.border,
          width: isSufficient ? 2 : 1,
        ),
        boxShadow: CheckoutConstants.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cash Received', style: CheckoutConstants.textLabel),
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
                  fontWeight: CheckoutConstants.weightBold,
                  color: CheckoutConstants.textPrimary,
                ),
              ),
              if (isSufficient && state.cashReceivedNum > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: CheckoutConstants.success,
                    borderRadius: BorderRadius.circular(
                      CheckoutConstants.radiusChip,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Sufficient',
                        style: CheckoutConstants.textMutedSmall.copyWith(
                          color: Colors.white,
                          fontWeight: CheckoutConstants.weightSemiBold,
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
                color: CheckoutConstants.successLight,
                borderRadius: BorderRadius.circular(
                  CheckoutConstants.radiusButton,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Change Due',
                    style: CheckoutConstants.textLabel.copyWith(
                      color: CheckoutConstants.success,
                      fontWeight: CheckoutConstants.weightSemiBold,
                    ),
                  ),
                  Text(
                    '\$${state.cashChange.toStringAsFixed(2)}',
                    style: CheckoutConstants.textValue.copyWith(
                      color: CheckoutConstants.success,
                      fontWeight: CheckoutConstants.weightBold,
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
      padding: const EdgeInsets.all(CheckoutConstants.cardPadding),
      decoration: BoxDecoration(
        color: CheckoutConstants.surface,
        borderRadius: BorderRadius.circular(CheckoutConstants.radiusCard),
        border: Border.all(color: CheckoutConstants.border),
        boxShadow: CheckoutConstants.shadowCard,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTotalRow('Subtotal', state.subtotal),
          if (state.tipAmount > 0) ...[
            const SizedBox(height: 6),
            _buildTotalRow(
              'Tip',
              state.tipAmount,
              color: CheckoutConstants.primary,
            ),
          ],
          if (state.discountAmount > 0) ...[
            const SizedBox(height: 6),
            _buildTotalRow(
              'Discount',
              -state.discountAmount,
              color: CheckoutConstants.error,
            ),
          ],
          if (state.voucherTotal > 0) ...[
            const SizedBox(height: 6),
            _buildTotalRow(
              'Vouchers',
              -state.voucherTotal,
              color: CheckoutConstants.success,
            ),
          ],
          if (state.loyaltyRedemption > 0) ...[
            const SizedBox(height: 6),
            _buildTotalRow(
              'Loyalty',
              -state.loyaltyRedemption,
              color: CheckoutConstants.warning,
            ),
          ],
          const SizedBox(height: 6),
          _buildTotalRow('Tax (10%)', state.tax),
          const SizedBox(height: 8),
          Container(height: 1, color: CheckoutConstants.border),
          const SizedBox(height: 8),
          _buildTotalRow('TOTAL', state.grandTotal, isGrandTotal: true),
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
              ? CheckoutConstants.textTitle.copyWith(
                  fontWeight: CheckoutConstants.weightBold,
                )
              : CheckoutConstants.textLabel,
        ),
        Text(
          amount < 0
              ? '-\$${(-amount).toStringAsFixed(2)}'
              : '\$${amount.toStringAsFixed(2)}',
          style: isGrandTotal
              ? CheckoutConstants.textValue.copyWith(
                  fontSize: CheckoutConstants.fontSizeLarge,
                  fontWeight: CheckoutConstants.weightBold,
                  color: CheckoutConstants.success,
                )
              : CheckoutConstants.textBody.copyWith(
                  fontWeight: CheckoutConstants.weightSemiBold,
                  color: color,
                ),
        ),
      ],
    );
  }
}
