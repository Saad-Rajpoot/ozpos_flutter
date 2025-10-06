import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/combo_management_bloc.dart';
import '../bloc/combo_management_event.dart';
import '../bloc/combo_management_state.dart';
import 'combo_builder_tabs/details_tab.dart';
import 'combo_builder_tabs/items_tab.dart';
import 'combo_builder_tabs/pricing_tab.dart';
import 'combo_builder_tabs/availability_tab.dart';
import 'combo_builder_tabs/advanced_tab.dart';

class ComboBuilderModal extends StatelessWidget {
  const ComboBuilderModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: BlocBuilder<ComboManagementBloc, ComboManagementState>(
        builder: (context, state) {
          if (!state.isBuilderOpen || state.editingCombo == null) {
            return const SizedBox.shrink();
          }

          return Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildHeader(context, state),
                _buildTabBar(context, state),
                Expanded(
                  child: _buildTabContent(context, state),
                ),
                _buildFooter(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ComboManagementState state) {
    final isEditing = state.editMode == ComboEditMode.edit;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Combo Meal' : 'Edit Combo Meal',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Build a meal deal with custom items and special pricing',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Close button
          IconButton(
            onPressed: () => _onClose(context),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 24,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context, ComboManagementState state) {
    const tabs = [
      {'id': 'details', 'icon': Icons.info_outline, 'label': 'Details'},
      {'id': 'items', 'icon': Icons.add, 'label': 'Items'},
      {'id': 'pricing', 'icon': Icons.attach_money, 'label': 'Pricing'},
      {'id': 'availability', 'icon': Icons.schedule, 'label': 'Availability'},
      {'id': 'advanced', 'icon': Icons.tune, 'label': 'Advanced'},
    ];

    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      child: Row(
        children: tabs.map((tab) {
          final isSelected = state.selectedTab == tab['id'];
          final hasErrors = _tabHasErrors(tab['id'] as String, state);

          return Expanded(
            child: InkWell(
              onTap: () => context.read<ComboManagementBloc>().add(
                SelectTab(tabId: tab['id'] as String),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? const Color(0xFF8B5CF6) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  color: isSelected ? const Color(0xFF8B5CF6).withValues(alpha: 0.05) : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          tab['icon'] as IconData,
                          size: 20,
                          color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF6B7280),
                        ),
                        if (hasErrors)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEF4444),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tab['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? const Color(0xFF8B5CF6) : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, ComboManagementState state) {
    switch (state.selectedTab) {
      case 'items':
        return const ItemsTab();
      case 'pricing':
        return const PricingTab();
      case 'availability':
        return const AvailabilityTab();
      case 'advanced':
        return const AdvancedTab();
      case 'details':
      default:
        return const DetailsTab();
    }
  }

  Widget _buildFooter(BuildContext context, ComboManagementState state) {
    final combo = state.editingCombo!;
    final hasErrors = state.validationErrors.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
        border: Border(
          top: BorderSide(color: Color(0xFFE5E7EB)),
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Item count and savings info
          Expanded(
            child: Row(
              children: [
                Text(
                  '${combo.slots.length} item(s)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
                if (combo.computedSavings > 0) ...[
                  const SizedBox(width: 8),
                  const Text('•', style: TextStyle(color: Color(0xFF6B7280))),
                  const SizedBox(width: 8),
                  Text(
                    'Saves \$${combo.computedSavings.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Action buttons
          TextButton(
            onPressed: () => _onClose(context),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: state.isSaving || hasErrors ? null : () => _onSave(context),
            icon: state.isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.save, size: 18),
            label: Text(state.isSaving ? 'Saving...' : 'Save Combo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasErrors ? Colors.grey[400] : const Color(0xFF8B5CF6),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _tabHasErrors(String tabId, ComboManagementState state) {
    if (state.validationErrors.isEmpty) return false;
    
    // Define which validation errors belong to which tabs
    final tabErrorKeywords = {
      'details': ['name', 'description'],
      'items': ['slot', 'item', 'component'],
      'pricing': ['price', 'pricing', 'discount'],
      'availability': ['availability', 'time', 'date'],
      'advanced': ['limit', 'restriction', 'stack'],
    };

    final keywords = tabErrorKeywords[tabId] ?? [];
    return state.validationErrors.any((error) =>
        keywords.any((keyword) => error.toLowerCase().contains(keyword)));
  }

  void _onSave(BuildContext context) {
    context.read<ComboManagementBloc>().add(
      const SaveComboChanges(exitAfterSave: true),
    );
  }

  void _onClose(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to close without saving?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue Editing'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close modal
              context.read<ComboManagementBloc>().add(const CancelComboEdit());
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard Changes'),
          ),
        ],
      ),
    );
  }
}