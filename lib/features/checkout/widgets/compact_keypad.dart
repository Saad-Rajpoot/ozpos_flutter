import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../pos/presentation/bloc/checkout_bloc.dart';
import '../checkout_tokens.dart';

/// Compact Keypad - Fixed-height grid for cash input
///
/// Features:
/// - Quick amount chips in single row
/// - 4 rows × 3 columns keypad (64dp keys)
/// - Fixed total height: ~300dp (no scrolling)
/// - Backspace key with danger color
class CompactKeypad extends StatelessWidget {
  const CompactKeypad({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Quick amounts row
        _buildQuickAmounts(context),
        const SizedBox(height: CheckoutTokens.gapNormal),

        // Keypad grid
        _buildKeypadGrid(context),
      ],
    );
  }

  Widget _buildQuickAmounts(BuildContext context) {
    final amounts = [5, 10, 20, 50, 100];

    return SizedBox(
      height: CheckoutTokens.quickAmountHeight,
      child: Row(
        children: amounts.map((amount) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: OutlinedButton(
                onPressed: () {
                  context.read<CheckoutBloc>().add(
                    QuickAmountPress(amount: amount),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      CheckoutTokens.radiusButton,
                    ),
                  ),
                  side: BorderSide(color: CheckoutTokens.border),
                  foregroundColor: CheckoutTokens.textPrimary,
                ),
                child: Text(
                  '+\$$amount',
                  style: CheckoutTokens.textBody.copyWith(
                    fontWeight: CheckoutTokens.weightSemiBold,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeypadGrid(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '⌫'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: CheckoutTokens.keypadGap),
          child: Row(
            children: row.map((key) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _buildKey(context, key),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKey(BuildContext context, String key) {
    final isBackspace = key == '⌫';

    return SizedBox(
      height: CheckoutTokens.keySize,
      child: ElevatedButton(
        onPressed: () {
          context.read<CheckoutBloc>().add(KeypadPress(key: key));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isBackspace
              ? CheckoutTokens.error
              : CheckoutTokens.surface,
          foregroundColor: isBackspace
              ? Colors.white
              : CheckoutTokens.textPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CheckoutTokens.radiusButton),
            side: BorderSide(
              color: isBackspace ? CheckoutTokens.error : CheckoutTokens.border,
              width: 1,
            ),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Text(
          key,
          style: TextStyle(
            fontSize: isBackspace ? 24 : 20,
            fontWeight: CheckoutTokens.weightSemiBold,
          ),
        ),
      ),
    );
  }
}
