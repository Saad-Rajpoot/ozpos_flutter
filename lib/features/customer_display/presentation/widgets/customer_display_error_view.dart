import 'package:flutter/material.dart';

class CustomerDisplayErrorView extends StatelessWidget {
  const CustomerDisplayErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFef4444), Color(0xFFb91c1c)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 96),
              const SizedBox(height: 24),
              const Text(
                'Display Unavailable',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                message ?? 'Something went wrong.',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white.withOpacity(0.15),
                  side: const BorderSide(color: Colors.white24),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 26),
                label: const Text('Retry Display'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
