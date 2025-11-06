import 'package:flutter/material.dart';
import '../../bloc/menu_edit_state.dart';

/// Dietary flags widget displaying dietary preferences
class DietaryFlagsWidget extends StatelessWidget {
  final MenuEditState state;

  const DietaryFlagsWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final flags = _buildFlagsList();

    if (flags.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dietary',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: flags.map((flag) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Text(
                  flag,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF065F46),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  List<String> _buildFlagsList() {
    final flags = <String>[];
    if (state.item.isVegetarian) flags.add('Vegetarian');
    if (state.item.isVegan) flags.add('Vegan');
    if (state.item.isGlutenFree) flags.add('Gluten-Free');
    if (state.item.isDairyFree) flags.add('Dairy-Free');
    if (!state.item.isNutFree) flags.add('Contains Nuts');
    if (state.item.isHalal) flags.add('Halal');
    return flags;
  }
}

