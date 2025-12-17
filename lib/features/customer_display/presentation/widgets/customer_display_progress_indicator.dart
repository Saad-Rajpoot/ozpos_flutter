import 'package:flutter/material.dart';

class CustomerDisplayProgressIndicator extends StatelessWidget {
  const CustomerDisplayProgressIndicator({
    super.key,
    required this.modeLabel,
    required this.currentStep,
    required this.totalSteps,
  });

  final String modeLabel;
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 28),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white24),
          ),
          child: Text(
            'Demo Mode: $modeLabel ($currentStep/$totalSteps)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
