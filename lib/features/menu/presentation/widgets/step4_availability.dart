import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/menu_edit_bloc.dart';
import '../bloc/menu_edit_event.dart';
import '../bloc/menu_edit_state.dart';

/// Step 4: Availability & Settings - Channel availability and options
class Step4Availability extends StatelessWidget {
  const Step4Availability({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuEditBloc, MenuEditState>(
      builder: (context, state) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Control where this item appears and configure additional settings.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Channel Availability
              _buildChannelAvailability(context, state),
              const SizedBox(height: 32),

              // Kitchen & Operations
              _buildKitchenSettings(context, state),
              const SizedBox(height: 32),

              // Dietary & Preferences
              _buildDietarySettings(context, state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChannelAvailability(BuildContext context, MenuEditState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.store, size: 24, color: const Color(0xFF2196F3)),
              const SizedBox(width: 12),
              const Text(
                'Channel Availability',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Choose where this item should be available for ordering',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),

          // Dine-In
          _buildChannelToggle(
            context,
            icon: Icons.point_of_sale,
            title: 'Dine-In (POS)',
            description:
                'Available for dine-in orders at the physical location',
            value: state.item.dineInAvailable,
            onChanged: (value) {
              context.read<MenuEditBloc>().add(
                UpdateChannelAvailability(dineInAvailable: value),
              );
            },
          ),
          const Divider(height: 32),

          // Takeaway
          _buildChannelToggle(
            context,
            icon: Icons.language,
            title: 'Takeaway',
            description: 'Available for takeaway orders through website/app',
            value: state.item.takeawayAvailable,
            onChanged: (value) {
              context.read<MenuEditBloc>().add(
                UpdateChannelAvailability(takeawayAvailable: value),
              );
            },
          ),
          const Divider(height: 32),

          // Delivery
          _buildChannelToggle(
            context,
            icon: Icons.delivery_dining,
            title: 'Delivery',
            description: 'Available for delivery orders',
            value: state.item.deliveryAvailable,
            onChanged: (value) {
              context.read<MenuEditBloc>().add(
                UpdateChannelAvailability(deliveryAvailable: value),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChannelToggle(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: value
                ? const Color(0xFF2196F3).withValues(alpha: 0.1)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 24,
            color: value ? const Color(0xFF2196F3) : Colors.grey.shade400,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: const Color(0xFF2196F3),
        ),
      ],
    );
  }

  Widget _buildKitchenSettings(BuildContext context, MenuEditState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.kitchen, size: 24, color: const Color(0xFF2196F3)),
              const SizedBox(width: 12),
              const Text(
                'Kitchen & Operations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Prep Time
          _buildNumberField(
            label: 'Preparation Time (minutes)',
            hint: 'e.g., 15',
            value: state.item.prepTimeMinutes ?? 0,
            onChanged: (value) {
              final prepTime = int.tryParse(value) ?? 0;
              context.read<MenuEditBloc>().add(
                UpdateKitchenSettings(prepTimeMinutes: prepTime),
              );
            },
          ),
          const SizedBox(height: 20),

          // Kitchen Station
          _buildDropdownField(
            label: 'Kitchen Station',
            hint: 'Select station',
            value: state.item.kitchenStation ?? '',
            items: const [
              'grill',
              'fryer',
              'salad',
              'dessert',
              'bar',
              'pizza-oven',
            ],
            itemLabels: const [
              'Grill',
              'Fryer',
              'Salad',
              'Dessert',
              'Bar',
              'Pizza Oven',
            ],
            onChanged: (value) {
              context.read<MenuEditBloc>().add(
                UpdateKitchenSettings(kitchenStation: value),
              );
            },
          ),
          const SizedBox(height: 20),

          // Tax Category
          _buildDropdownField(
            label: 'Tax Category',
            hint: 'Select tax category',
            value: state.item.taxCategory,
            items: const ['standard', 'food', 'alcohol', 'tax-free'],
            itemLabels: const ['Standard', 'Food', 'Alcohol', 'Tax-Free'],
            onChanged: (value) {
              context.read<MenuEditBloc>().add(UpdateTaxCategory(value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDietarySettings(BuildContext context, MenuEditState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 24,
                color: const Color(0xFF2196F3),
              ),
              const SizedBox(width: 12),
              const Text(
                'Dietary & Preferences',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Dietary flags
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildCheckboxChip(
                label: 'Vegetarian',
                value: state.item.isVegetarian,
                onChanged: (value) {
                  context.read<MenuEditBloc>().add(
                    UpdateDietaryPreferences(isVegetarian: value),
                  );
                },
              ),
              _buildCheckboxChip(
                label: 'Vegan',
                value: state.item.isVegan,
                onChanged: (value) {
                  context.read<MenuEditBloc>().add(
                    UpdateDietaryPreferences(isVegan: value),
                  );
                },
              ),
              _buildCheckboxChip(
                label: 'Gluten-Free',
                value: state.item.isGlutenFree,
                onChanged: (value) {
                  context.read<MenuEditBloc>().add(
                    UpdateDietaryPreferences(isGlutenFree: value),
                  );
                },
              ),
              _buildCheckboxChip(
                label: 'Dairy-Free',
                value: state.item.isDairyFree,
                onChanged: (value) {
                  context.read<MenuEditBloc>().add(
                    UpdateDietaryPreferences(isDairyFree: value),
                  );
                },
              ),
              _buildCheckboxChip(
                label: 'Nut-Free',
                value: state.item.isNutFree,
                onChanged: (value) {
                  context.read<MenuEditBloc>().add(
                    UpdateDietaryPreferences(isNutFree: value),
                  );
                },
              ),
              _buildCheckboxChip(
                label: 'Halal',
                value: state.item.isHalal,
                onChanged: (value) {
                  context.read<MenuEditBloc>().add(
                    UpdateDietaryPreferences(isHalal: value),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberField({
    required String label,
    required String hint,
    required int value,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(
            text: value > 0 ? value.toString() : '',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required String value,
    required List<String> items,
    List<String>? itemLabels,
    required Function(String) onChanged,
  }) {
    // Use provided labels or items as labels
    final labels = itemLabels ?? items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value.isEmpty ? null : value,
          hint: Text(hint),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
            ),
          ),
          items: List.generate(items.length, (index) {
            return DropdownMenuItem(
              value: items[index],
              child: Text(labels[index]),
            );
          }),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCheckboxChip({
    required String label,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return FilterChip(
      label: Text(label),
      selected: value,
      onSelected: onChanged,
      selectedColor: const Color(0xFF2196F3).withValues(alpha: 0.2),
      checkmarkColor: const Color(0xFF2196F3),
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        color: value ? const Color(0xFF2196F3) : Colors.grey.shade700,
        fontWeight: value ? FontWeight.w600 : FontWeight.w400,
      ),
    );
  }
}
