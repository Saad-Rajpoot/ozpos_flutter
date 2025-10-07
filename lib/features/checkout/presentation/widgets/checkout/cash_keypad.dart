import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/bloc/checkout_bloc.dart';

/// Cash Keypad - Numeric input with quick amount buttons
/// Matches React prototype keypad design
class CashKeypad extends StatelessWidget {
  final CheckoutLoaded state;

  const CashKeypad({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cash display
        _buildCashDisplay(context),
        const SizedBox(height: 12),

        // Quick amount buttons
        _buildQuickAmounts(context),
        const SizedBox(height: 12),

        // Numeric keypad
        _buildNumericKeypad(context),

        // Change display
        if (state.cashReceivedNum > 0) ...[
          const SizedBox(height: 12),
          _buildChangeDisplay(context),
        ],
      ],
    );
  }

  Widget _buildCashDisplay(BuildContext context) {
    final cashText = state.cashReceived.isEmpty ? '0.00' : state.cashReceived;
    final grandTotal = state.grandTotal;
    final isSufficient = state.cashReceivedNum >= grandTotal;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSufficient
              ? const Color(0xFF4CAF50)
              : const Color(0xFFE0E0E0),
          width: isSufficient ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cash Received',
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withValues(alpha: 0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$$cashText',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (isSufficient && state.cashReceivedNum > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.check, color: Colors.white, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Sufficient',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmounts(BuildContext context) {
    final amounts = [5, 10, 20, 50, 100];

    return Row(
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: const BorderSide(color: Color(0xFFE0E0E0)),
                foregroundColor: Colors.black87,
              ),
              child: Text(
                '+\$$amount',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumericKeypad(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '00'],
    ];

    return Column(
      children: [
        ...keys.map(
          (row) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: row.map((key) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildKeypadButton(context, key),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Backspace button (full width)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: _buildKeypadButton(context, '⌫', isBackspace: true),
        ),
      ],
    );
  }

  Widget _buildKeypadButton(
    BuildContext context,
    String key, {
    bool isBackspace = false,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: () {
          context.read<CheckoutBloc>().add(KeypadPress(key: key));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isBackspace ? const Color(0xFFD32F2F) : Colors.white,
          foregroundColor: isBackspace ? Colors.white : Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isBackspace
                  ? const Color(0xFFD32F2F)
                  : const Color(0xFFE0E0E0),
            ),
          ),
        ),
        child: Text(
          key,
          style: TextStyle(
            fontSize: isBackspace ? 24 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildChangeDisplay(BuildContext context) {
    final change = state.cashChange;

    if (change <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4CAF50), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Change',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4CAF50),
            ),
          ),
          Text(
            '\$${change.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4CAF50),
            ),
          ),
        ],
      ),
    );
  }
}
