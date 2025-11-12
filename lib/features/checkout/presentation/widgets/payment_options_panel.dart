import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../checkout/presentation/bloc/checkout_bloc.dart';
import '../../domain/entities/payment_method_type.dart';
import '../constant/checkout_constants.dart';

/// Payment Options Panel - Right column
/// Simplified version focusing on essential features
class PaymentOptionsPanel extends StatelessWidget {
  const PaymentOptionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        if (state is! CheckoutLoaded) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            // Payment method tiles
            _buildPaymentMethods(context, state),
            const SizedBox(height: CheckoutConstants.gapNormal),

            // Spacer to push actions to bottom
            const Spacer(),

            // Action buttons (sticky at bottom)
            _buildActionButtons(context, state),
          ],
        );
      },
    );
  }

  Widget _buildPaymentMethods(BuildContext context, CheckoutLoaded state) {
    return Container(
      padding: const EdgeInsets.all(CheckoutConstants.cardPadding),
      decoration: BoxDecoration(
        color: CheckoutConstants.surface,
        borderRadius: BorderRadius.circular(CheckoutConstants.radiusCard),
        border: Border.all(color: CheckoutConstants.border),
        boxShadow: CheckoutConstants.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Payment Method', style: CheckoutConstants.textTitle),
          const SizedBox(height: CheckoutConstants.gapNormal),

          // Payment method grid (2 rows × 2 cols)
          Wrap(
            spacing: CheckoutConstants.gapSmall,
            runSpacing: CheckoutConstants.gapSmall,
            children: PaymentMethodType.values.take(4).map((method) {
              final isSelected = state.selectedMethod == method;
              return _buildMethodTile(context, method, isSelected);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTile(
    BuildContext context,
    PaymentMethodType method,
    bool isSelected,
  ) {
    final width = (CheckoutConstants.rightWidth -
            CheckoutConstants.cardPadding * 2 -
            CheckoutConstants.gapSmall) /
        2;

    return GestureDetector(
      onTap: () {
        context.read<CheckoutBloc>().add(SelectPaymentMethod(method: method));
      },
      child: Container(
        width: width,
        height: CheckoutConstants.methodTileHeight,
        decoration: BoxDecoration(
          color: isSelected
              ? CheckoutConstants.primaryLight
              : CheckoutConstants.surface,
          borderRadius: BorderRadius.circular(CheckoutConstants.radiusButton),
          border: Border.all(
            color: isSelected
                ? CheckoutConstants.primary
                : CheckoutConstants.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? CheckoutConstants.shadowSelected : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.payments,
              size: 28,
              color: isSelected
                  ? CheckoutConstants.primary
                  : CheckoutConstants.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              method.value,
              style: CheckoutConstants.textBody.copyWith(
                fontWeight: isSelected
                    ? CheckoutConstants.weightSemiBold
                    : CheckoutConstants.weightMedium,
                color: isSelected
                    ? CheckoutConstants.primary
                    : CheckoutConstants.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CheckoutLoaded state) {
    return Column(
      children: [
        // PAY button
        SizedBox(
          width: double.infinity,
          height: CheckoutConstants.inputHeight,
          child: ElevatedButton(
            onPressed: state.canPay
                ? () => context.read<CheckoutBloc>().add(ProcessPayment())
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: CheckoutConstants.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: CheckoutConstants.border,
              disabledForegroundColor: CheckoutConstants.textMuted,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  CheckoutConstants.radiusButton,
                ),
              ),
            ),
            child: Text(
              'PAY \$${state.grandTotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: CheckoutConstants.fontSizeTitle,
                fontWeight: CheckoutConstants.weightBold,
              ),
            ),
          ),
        ),
        const SizedBox(height: CheckoutConstants.gapSmall),

        // Pay Later button
        SizedBox(
          width: double.infinity,
          height: CheckoutConstants.tabHeight,
          child: OutlinedButton(
            onPressed: () => context.read<CheckoutBloc>().add(PayLater()),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: CheckoutConstants.primary),
              foregroundColor: CheckoutConstants.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  CheckoutConstants.radiusButton,
                ),
              ),
            ),
            child: const Text(
              'Pay Later',
              style: TextStyle(
                fontSize: CheckoutConstants.fontSizeBody,
                fontWeight: CheckoutConstants.weightSemiBold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
