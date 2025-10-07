import 'package:flutter/material.dart';
import '../bloc/menu_edit_state.dart';

/// Right sidebar showing item summary and validation
class SummarySidebar extends StatelessWidget {
  final MenuEditState state;

  const SummarySidebar({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: state.item.dineInAvailable
                        ? const Color(0xFF10B981).withValues(alpha: 0.1)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    state.item.dineInAvailable ? 'Active' : 'Inactive',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: state.item.dineInAvailable
                          ? const Color(0xFF10B981)
                          : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Availability Section
            _buildSection(
              title: 'Availability',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusRow('Dine-In', state.item.dineInAvailable),
                  const SizedBox(height: 8),
                  _buildStatusRow('Takeaway', state.item.takeawayAvailable),
                  const SizedBox(height: 8),
                  _buildStatusRow('Delivery', state.item.deliveryAvailable),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Prices Section
            _buildSection(
              title: 'Prices',
              child: Text(
                state.priceDisplay,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Add-on Items Section
            _buildSection(
              title: 'Add-on Items',
              child: Text(
                '${state.totalAddOnItems} items configured',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 24),

            // Validation Section
            _buildSection(
              title: 'Validation',
              child: Row(
                children: [
                  Icon(
                    state.validation.isValid ? Icons.check_circle : Icons.error,
                    size: 20,
                    color: state.validation.isValid
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.validation.isValid
                        ? '0 issues'
                        : '${state.validation.errors.length} to fix',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: state.validation.isValid
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ),

            // Show errors if any
            if (!state.validation.isValid) ...[
              const SizedBox(height: 12),
              ...state.validation.errors.map(
                (error) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          error,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Show warnings if any
            if (state.validation.warnings.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Suggestions',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...state.validation.warnings.map(
                (warning) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Color(0xFFF59E0B),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          warning,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildStatusRow(String label, bool isEnabled) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isEnabled ? const Color(0xFF10B981) : Colors.grey.shade400,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ${isEnabled ? "On" : "Off"}',
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }
}
