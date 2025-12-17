import 'package:flutter/material.dart';

import '../../../../core/navigation/app_router.dart';

class CustomerDisplayButton extends StatelessWidget {
  const CustomerDisplayButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.of(context).pushNamed(AppRouter.customerDisplay);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF7C3AED),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        shadowColor: const Color(0x66000000),
      ),
      icon: const Text(
        '📺',
        style: TextStyle(fontSize: 22),
      ),
      label: const Text('Customer Display'),
    );
  }
}
