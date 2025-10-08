import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../checkout/domain/entities/payment_method.dart';
import '../bloc/checkout_bloc.dart';

/// Payment Method Selector - Matches React prototype design
/// Shows four payment options: Cash, Card, Wallet, BNPL
class PaymentMethodSelector extends StatelessWidget {
  final CheckoutLoaded state;

  const PaymentMethodSelector({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: PaymentMethod.values.map((method) {
        final isSelected = state.selectedMethod == method;

        return GestureDetector(
          onTap: () {
            context.read<CheckoutBloc>().add(
              SelectPaymentMethod(method: method),
            );
          },
          child: Container(
            width: (MediaQuery.of(context).size.width >= 768) ? 160 : 140,
            height: 100,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2196F3).withValues(alpha: 0.08)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF2196F3)
                    : const Color(0xFFE0E0E0),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  method.icon,
                  size: 32,
                  color: isSelected ? const Color(0xFF2196F3) : Colors.black54,
                ),
                const SizedBox(height: 8),
                Text(
                  method.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? const Color(0xFF2196F3)
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
