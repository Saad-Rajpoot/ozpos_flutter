import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/customer_display_entity.dart';

class CustomerDisplayChangeDueView extends StatelessWidget {
  const CustomerDisplayChangeDueView({super.key, required this.content});

  final CustomerDisplayEntity content;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: r'$');
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF0EA5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '💵',
                        style: TextStyle(fontSize: 120),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Your Change',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 72,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currency.format(content.totals.changeDue),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 96,
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 8),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _ChangeBreakdown(content: content),
                      const SizedBox(height: 28),
                      const Text(
                        'Thank you for your order!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Order #${content.orderNumber}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChangeBreakdown extends StatelessWidget {
  const _ChangeBreakdown({required this.content});

  final CustomerDisplayEntity content;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: r'$');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        children: [
          _infoRow('Cash Received', currency.format(content.totals.cashReceived)),
          const SizedBox(height: 12),
          _infoRow('Total Due', currency.format(content.totals.total)),
          const Divider(color: Colors.white30, thickness: 1, height: 32),
          _infoRow(
            'Change Due',
            currency.format(content.totals.changeDue),
            isEmphasis: true,
          ),
        ],
      ),
    );
  }

  static Widget _infoRow(String label, String value,
      {bool isEmphasis = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isEmphasis ? 26 : 22,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: isEmphasis ? 36 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
