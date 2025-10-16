import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/checkout_bloc.dart';

/// Tip Section - Percentage buttons (0%, 5%, 10%, 15%) and custom tip input
class TipSection extends StatelessWidget {
  final CheckoutLoaded state;

  const TipSection({super.key, required this.state});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tip',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (state.tipAmount > 0)
                  Text(
                    '\$${state.tipAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2196F3),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Percentage buttons
            Row(
              children: [0, 5, 10, 15].map((percent) {
                final isSelected = state.tipPercent == percent &&
                    state.customTipAmount.isEmpty;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<CheckoutBloc>().add(
                              SelectTipPercent(percent: percent),
                            );
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected
                            ? const Color(0xFF2196F3).withOpacity(0.08)
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF2196F3)
                              : const Color(0xFFE0E0E0),
                          width: isSelected ? 2 : 1,
                        ),
                        foregroundColor: isSelected
                            ? const Color(0xFF2196F3)
                            : Colors.black87,
                      ),
                      child: Text(
                        '$percent%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 12),

            // Custom tip input
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Custom Tip Amount',
                prefixText: '\$',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                context.read<CheckoutBloc>().add(SetCustomTip(amount: value));
              },
            ),
          ],
        ),
      ),
    );
  }
}
