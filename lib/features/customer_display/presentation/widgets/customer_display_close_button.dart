import 'package:flutter/material.dart';

class CustomerDisplayCloseButton extends StatelessWidget {
  const CustomerDisplayCloseButton({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(top: 16, right: 16),
          child: GestureDetector(
            onTap: onClose,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white24, width: 1.5),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    offset: Offset(0, 3),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}
