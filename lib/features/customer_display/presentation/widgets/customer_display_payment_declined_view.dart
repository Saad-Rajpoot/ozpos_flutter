import 'package:flutter/material.dart';

class CustomerDisplayPaymentDeclinedView extends StatelessWidget {
  const CustomerDisplayPaymentDeclinedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                _DeclinedIcon(),
                SizedBox(height: 32),
                Text(
                  'Payment Declined',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Please try another payment method',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'or ask staff for assistance',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeclinedIcon extends StatelessWidget {
  const _DeclinedIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.close,
        color: Color(0xFFDC2626),
        size: 120,
      ),
    );
  }
}
