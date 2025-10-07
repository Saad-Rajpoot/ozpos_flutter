import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../checkout/domain/entities/payment_method.dart';
import '../../../../checkout/domain/entities/tender_entity.dart';
import '../../../presentation/bloc/checkout_bloc.dart';

/// Split Payment Section - Manage multiple tenders and split evenly
class SplitPaymentSection extends StatelessWidget {
  final CheckoutLoaded state;

  const SplitPaymentSection({super.key, required this.state});

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
              'Split Payment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Split evenly buttons
            Row(
              children: [
                const Text(
                  'Split Evenly:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(width: 12),
                ...[
                  [2, '2'],
                  [3, '3'],
                  [4, '4'],
                ].map((pair) {
                  final ways = pair[0] as int;
                  final label = pair[1] as String;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<CheckoutBloc>().add(
                            SplitEvenly(ways: ways),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(color: Color(0xFFE0E0E0)),
                          foregroundColor: Colors.black87,
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 16),

            // Remaining amount
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: state.splitRemaining > 0
                    ? const Color(0xFFFF9800).withValues(alpha: 0.1)
                    : const Color(0xFF4CAF50).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: state.splitRemaining > 0
                      ? const Color(0xFFFF9800)
                      : const Color(0xFF4CAF50),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    state.splitRemaining > 0 ? 'Remaining' : 'Fully Paid',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: state.splitRemaining > 0
                          ? const Color(0xFFFF9800)
                          : const Color(0xFF4CAF50),
                    ),
                  ),
                  Text(
                    '\$${state.splitRemaining.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: state.splitRemaining > 0
                          ? const Color(0xFFFF9800)
                          : const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Tenders list
            if (state.tenders.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.payment,
                        size: 48,
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No tenders added yet',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Column(
                children: state.tenders.map((tender) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildTenderCard(context, tender),
                  );
                }).toList(),
              ),

            const SizedBox(height: 16),

            // Add tender button
            if (state.splitRemaining > 0)
              OutlinedButton.icon(
                onPressed: () => _showAddTenderDialog(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Tender'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  side: const BorderSide(color: Color(0xFF2196F3)),
                  foregroundColor: const Color(0xFF2196F3),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTenderCard(BuildContext context, TenderEntity tender) {
    final statusColor = tender.status.color;
    final statusIcon = tender.status.icon;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(tender.method.icon, size: 20, color: statusColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tender.method.label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(statusIcon, size: 12, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      tender.status.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '\$${tender.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              context.read<CheckoutBloc>().add(RemoveTender(id: tender.id));
            },
            color: Colors.black54,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showAddTenderDialog(BuildContext context) {
    PaymentMethod selectedMethod = PaymentMethod.cash;
    final amountController = TextEditingController(
      text: state.splitRemaining.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (statefulContext, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Add Tender'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PaymentMethod.values.map((method) {
                  final isSelected = selectedMethod == method;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedMethod = method;
                      });
                    },
                    child: Container(
                      width: 80,
                      height: 70,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2196F3).withValues(alpha: 0.08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
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
                            size: 24,
                            color: isSelected
                                ? const Color(0xFF2196F3)
                                : Colors.black54,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            method.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
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
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                if (amount > 0) {
                  context.read<CheckoutBloc>().add(
                    AddTender(method: selectedMethod, amount: amount),
                  );
                  Navigator.of(dialogContext).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}
