import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/editor/combo_editor_bloc.dart';
import '../../bloc/editor/combo_editor_event.dart';
import '../../bloc/editor/combo_editor_state.dart';
import '../../../domain/entities/combo_slot_entity.dart';
import 'add_item_dialog.dart';

class ItemsTab extends StatefulWidget {
  const ItemsTab({super.key});

  @override
  State<ItemsTab> createState() => _ItemsTabState();
}

class _ItemsTabState extends State<ItemsTab> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ComboEditorBloc, ComboEditorState>(
      buildWhen: (previous, current) {
        // Only rebuild if editing combo changes
        return previous.draft != current.draft;
      },
      builder: (context, state) {
        final combo = state.draft;
        if (combo == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Text(
                    'Combo Items',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () => _showAddItemDialog(context),
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('Add Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Configure items and categories for this combo deal',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 32),

              // Existing slots
              if (combo.slots.isNotEmpty)
                ...combo.slots.asMap().entries.map((entry) {
                  final index = entry.key;
                  final slot = entry.value;
                  return _buildSlotCard(context, slot, index);
                }),

              // Empty state or add first item
              if (combo.slots.isEmpty) _buildEmptyState(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSlotCard(BuildContext context, ComboSlotEntity slot, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slot Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: slot.required
                      ? const Color(0xFFEF4444)
                      : const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  slot.required ? 'REQUIRED' : 'OPTIONAL',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (slot.defaultIncluded)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'DEFAULT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              const Spacer(),
              PopupMenuButton(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _editSlot(context, slot, index);
                      break;
                    case 'duplicate':
                      _duplicateSlot(context, slot);
                      break;
                    case 'delete':
                      _deleteSlot(context, slot);
                      break;
                  }
                },
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                      value: 'edit', child: Text('Edit')),
                  const PopupMenuItem<String>(
                      value: 'duplicate', child: Text('Duplicate')),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Slot Details
          Text(
            slot.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            slot.displayName,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),

          // Slot Configuration
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip('Max: ${slot.maxQuantity}'),
              _buildInfoChip('\$${slot.defaultPrice.toStringAsFixed(2)}'),
              if (slot.allowedSizeIds.isNotEmpty)
                _buildInfoChip('${slot.allowedSizeIds.length} sizes'),
              if (slot.modifierGroupAllowed.isNotEmpty)
                _buildInfoChip('${slot.modifierGroupAllowed.length} modifiers'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          style: BorderStyle.solid,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_menu,
              color: Color(0xFF8B5CF6),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No items added yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add items or categories to create your combo deal',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _showAddItemDialog(context),
            icon: const Icon(Icons.add),
            label: const Text('Add First Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddItemDialog(),
    );
  }

  void _editSlot(BuildContext context, ComboSlotEntity slot, int index) {
    // For now, show the same dialog as add - in real implementation this would be an edit dialog
    showDialog(
      context: context,
      builder: (context) => const AddItemDialog(),
    );
  }

  void _duplicateSlot(BuildContext context, ComboSlotEntity slot) {
    context.read<ComboEditorBloc>().add(
          ComboSlotDuplicated(slotId: slot.id),
        );
  }

  void _deleteSlot(BuildContext context, ComboSlotEntity slot) {
    context.read<ComboEditorBloc>().add(
          ComboSlotRemoved(slotId: slot.id),
        );
  }
}
