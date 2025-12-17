import 'package:flutter/material.dart';

/// Wizard step indicator showing progress through 5 steps
class WizardStepper extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Function(int)? onStepTap;

  const WizardStepper({
    super.key,
    required this.currentStep,
    this.totalSteps = 5,
    this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final stepNumber = index + 1;
        final isCompleted = stepNumber < currentStep;
        final isCurrent = stepNumber == currentStep;
        
        return Row(
          children: [
            _buildStepCircle(stepNumber, isCompleted, isCurrent),
            if (index < totalSteps - 1) _buildConnector(isCompleted),
          ],
        );
      }),
    );
  }

  Widget _buildStepCircle(int stepNumber, bool isCompleted, bool isCurrent) {
    Color backgroundColor;
    Color textColor;
    Widget content;

    if (isCompleted) {
      backgroundColor = const Color(0xFF10B981); // Green
      textColor = Colors.white;
      content = const Icon(Icons.check, color: Colors.white, size: 16);
    } else if (isCurrent) {
      backgroundColor = const Color(0xFF2196F3); // Blue
      textColor = Colors.white;
      content = Text(
        stepNumber.toString(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      );
    } else {
      backgroundColor = const Color(0xFFE5E7EB); // Gray
      textColor = const Color(0xFF6B7280);
      content = Text(
        stepNumber.toString(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      );
    }

    return GestureDetector(
      onTap: onStepTap != null ? () => onStepTap!(stepNumber) : null,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(child: content),
      ),
    );
  }

  Widget _buildConnector(bool isCompleted) {
    return Container(
      width: 48,
      height: 2,
      color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFE5E7EB),
    );
  }
}
