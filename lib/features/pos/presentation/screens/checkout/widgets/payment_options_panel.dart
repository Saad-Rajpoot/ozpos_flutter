import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/checkout_bloc.dart';
import '../../../../domain/entities/payment_method.dart';
import '../checkout_tokens.dart';

/// Payment Options Panel - Right column
/// Simplified version focusing on essential features
class PaymentOptionsPanel extends StatelessWidget {
  const PaymentOptionsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        if (state is! CheckoutLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Payment method tiles
            _buildPaymentMethods(context, state),
            const SizedBox(height: CheckoutTokens.gapNormal),
            
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
      padding: const EdgeInsets.all(CheckoutTokens.cardPadding),
      decoration: BoxDecoration(
        color: CheckoutTokens.surface,
        borderRadius: BorderRadius.circular(CheckoutTokens.radiusCard),
        border: Border.all(color: CheckoutTokens.border),
        boxShadow: CheckoutTokens.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: CheckoutTokens.textTitle,
          ),
          const SizedBox(height: CheckoutTokens.gapNormal),
          
          // Payment method grid (2 rows × 2 cols)
          Wrap(
            spacing: CheckoutTokens.gapSmall,
            runSpacing: CheckoutTokens.gapSmall,
            children: PaymentMethod.values.take(4).map((method) {
              final isSelected = state.selectedMethod == method;
              return _buildMethodTile(context, method, isSelected);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodTile(BuildContext context, PaymentMethod method, bool isSelected) {
    final width = (CheckoutTokens.rightWidth - CheckoutTokens.cardPadding * 2 - CheckoutTokens.gapSmall) / 2;
    
    return GestureDetector(
      onTap: () {
        context.read<CheckoutBloc>().add(SelectPaymentMethod(method: method));
      },
      child: Container(
        width: width,
        height: CheckoutTokens.methodTileHeight,
        decoration: BoxDecoration(
          color: isSelected ? CheckoutTokens.primaryLight : CheckoutTokens.surface,
          borderRadius: BorderRadius.circular(CheckoutTokens.radiusButton),
          border: Border.all(
            color: isSelected ? CheckoutTokens.primary : CheckoutTokens.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? CheckoutTokens.shadowSelected : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              method.icon,
              size: 28,
              color: isSelected ? CheckoutTokens.primary : CheckoutTokens.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              method.label,
              style: CheckoutTokens.textBody.copyWith(
                fontWeight: isSelected ? CheckoutTokens.weightSemiBold : CheckoutTokens.weightMedium,
                color: isSelected ? CheckoutTokens.primary : CheckoutTokens.textPrimary,
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
          height: CheckoutTokens.inputHeight,
          child: ElevatedButton(
            onPressed: state.canPay
                ? () => context.read<CheckoutBloc>().add(ProcessPayment())
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: CheckoutTokens.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: CheckoutTokens.border,
              disabledForegroundColor: CheckoutTokens.textMuted,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(CheckoutTokens.radiusButton),
              ),
            ),
            child: Text(
              'PAY \$${state.grandTotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: CheckoutTokens.fontSizeTitle,
                fontWeight: CheckoutTokens.weightBold,
              ),
            ),
          ),
        ),
        const SizedBox(height: CheckoutTokens.gapSmall),
        
        // Pay Later button
        SizedBox(
          width: double.infinity,
          height: CheckoutTokens.tabHeight,
          child: OutlinedButton(
            onPressed: () => context.read<CheckoutBloc>().add(PayLater()),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: CheckoutTokens.primary),
              foregroundColor: CheckoutTokens.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(CheckoutTokens.radiusButton),
              ),
            ),
            child: const Text(
              'Pay Later',
              style: TextStyle(
                fontSize: CheckoutTokens.fontSizeBody,
                fontWeight: CheckoutTokens.weightSemiBold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
