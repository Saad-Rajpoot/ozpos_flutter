import 'package:flutter/material.dart';
import '../../bloc/menu_edit_state.dart';

/// Validation banner widget showing success or error state
class ValidationBanner extends StatelessWidget {
  final MenuEditState state;

  const ValidationBanner({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    if (state.validation.isValid) {
      return _buildSuccessBanner();
    } else {
      return _buildErrorBanner();
    }
  }

  Widget _buildSuccessBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF10B981)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: Color(0xFF10B981),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ready to Save!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF065F46),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'All required information has been provided. Review the details below and click "Save & Finish" to complete.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEF4444)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error,
            color: Color(0xFFEF4444),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Action Required',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF991B1B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Please fix the following issues before saving:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.red.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                ...state.validation.errors.map((error) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            error,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF991B1B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
