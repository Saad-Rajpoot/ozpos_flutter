import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

class DocketDesignerScreen extends StatelessWidget {
  const DocketDesignerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Docket Designer'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: AppColors.primary),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Docket Designer Screen',
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'This screen will design receipt templates',
              style: AppTypography.body1.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
