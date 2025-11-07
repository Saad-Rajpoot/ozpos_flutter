import 'package:flutter/material.dart';
import '../../../domain/entities/combo_entity.dart';
import 'debug_combo_utils.dart';

/// Widget to display saved combo summary
class SavedComboViewer extends StatelessWidget {
  const SavedComboViewer({
    required this.combo,
    super.key,
  });

  final ComboEntity combo;

  @override
  Widget build(BuildContext context) {
    final availability = combo.availability;
    final pricing = combo.pricing;
    final orderTypes = availability.orderTypes
        .map(DebugComboUtils.formatOrderType)
        .toList(growable: false);
    final displayLocations = <String>[];
    if (availability.posSystem) displayLocations.add('POS System');
    if (availability.onlineMenu) displayLocations.add('Online Menu');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '✅ Combo Saved Successfully!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF047857),
            ),
          ),
          const SizedBox(height: 12),
          _buildSummaryRow(
            'Combo Name',
            combo.name.isEmpty ? 'Untitled combo' : combo.name,
          ),
          _buildSummaryRow('Items Count', '${combo.slots.length} item(s)'),
          _buildSummaryRow(
            'Combo Price',
            '\$${pricing.finalPrice.toStringAsFixed(2)}',
          ),
          _buildSummaryRow(
            'Savings',
            pricing.savings > 0
                ? '\$${pricing.savings.toStringAsFixed(2)}'
                : 'No savings applied',
          ),
          if (displayLocations.isNotEmpty)
            _buildSummaryRow('Display Locations', displayLocations.join(', ')),
          if (orderTypes.isNotEmpty)
            _buildSummaryRow('Order Types', orderTypes.join(', ')),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF065F46),
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF065F46),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

