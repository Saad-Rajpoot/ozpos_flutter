import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/menu_edit_bloc.dart';
import '../bloc/menu_edit_event.dart';
import '../bloc/menu_edit_state.dart';
import 'size_row_widget.dart';
import 'modifier_style_preview_dialog.dart';

/// Step 2: Sizes & Add-ons - Configure pricing and add-on categories
class Step2SizesAddOns extends StatefulWidget {
  const Step2SizesAddOns({super.key});

  @override
  State<Step2SizesAddOns> createState() => _Step2SizesAddOnsState();
}

class _Step2SizesAddOnsState extends State<Step2SizesAddOns> {
  int? _expandedSizeIndex;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuEditBloc, MenuEditState>(
      builder: (context, state) {
        return Container(
          constraints: const BoxConstraints(maxWidth: 1000),
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
                        'Configure different sizes and their prices per channel. Each size can have its own add-on categories.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Header with add size button
              Row(
                children: [
                  const Text(
                    'Item Sizes',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<MenuEditBloc>().add(AddSize());
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Size'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Size list
              if (state.item.sizes.isEmpty)
                _buildEmptyState()
              else
                ...state.item.sizes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final size = entry.value;
                  return SizeRowWidget(
                    key: ValueKey(index),
                    size: size,
                    itemId: state.item.id ?? 'temp_${state.item.name}',
                    isExpanded: _expandedSizeIndex == index,
                    onToggleExpand: () {
                      setState(() {
                        _expandedSizeIndex = _expandedSizeIndex == index
                            ? null
                            : index;
                      });
                    },
                    onUpdate: (updatedSize) {
                      context.read<MenuEditBloc>().add(
                        UpdateSize(index, updatedSize),
                      );
                    },
                    onDelete: () {
                      _showDeleteConfirmation(context, index);
                    },
                    availableAddOnCategories: [],
                  );
                }).toList(),

              const SizedBox(height: 24),

              // Quick actions
              if (state.item.sizes.isNotEmpty) _buildQuickActions(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.straighten, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No sizes added yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add at least one size to configure pricing',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<MenuEditBloc>().add(AddSize());
            },
            icon: const Icon(Icons.add),
            label: const Text('Add First Size'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(MenuEditState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showAddCommonSizesDialog(context),
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text('Add Common Sizes'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _copyPricesAcrossChannels(context),
                icon: const Icon(Icons.content_copy, size: 16),
                label: const Text('Copy Dine-In Price to All'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => _showModifierStylePreview(context),
                icon: const Icon(Icons.preview, size: 16),
                label: const Text('Preview Add-on Styles'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int sizeIndex) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Size?'),
        content: const Text(
          'Are you sure you want to delete this size? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<MenuEditBloc>().add(DeleteSize(sizeIndex));
              Navigator.pop(dialogContext);
              setState(() {
                if (_expandedSizeIndex == sizeIndex) {
                  _expandedSizeIndex = null;
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddCommonSizesDialog(BuildContext context) {
    final commonSizes = [
      {'name': 'Small', 'price': 0.0},
      {'name': 'Medium', 'price': 0.0},
      {'name': 'Large', 'price': 0.0},
      {'name': 'Extra Large', 'price': 0.0},
    ];
    final selectedSizes = <String>{};
    final bloc = context.read<MenuEditBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (statefulContext, setState) {
          return AlertDialog(
            title: const Text('Add Common Sizes'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: commonSizes.map((sizeData) {
                final sizeName = sizeData['name'] as String;
                return CheckboxListTile(
                  value: selectedSizes.contains(sizeName),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedSizes.add(sizeName);
                      } else {
                        selectedSizes.remove(sizeName);
                      }
                    });
                  },
                  title: Text(sizeName),
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: selectedSizes.isEmpty
                    ? null
                    : () {
                        // Add sizes with their names
                        for (final sizeName in selectedSizes) {
                          bloc.add(AddSize());
                          // Get the newly added size index
                          final currentSizes = bloc.state.item.sizes;
                          final newIndex = currentSizes.length - 1;
                          if (newIndex >= 0) {
                            final newSize = currentSizes[newIndex].copyWith(
                              name: sizeName,
                            );
                            bloc.add(UpdateSize(newIndex, newSize));
                          }
                        }
                        Navigator.pop(dialogContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added ${selectedSizes.length} sizes',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                child: const Text('Add Selected'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _copyPricesAcrossChannels(BuildContext context) {
    final bloc = context.read<MenuEditBloc>();
    final sizes = bloc.state.item.sizes;

    for (var i = 0; i < sizes.length; i++) {
      final size = sizes[i];
      if (size.dineInPrice > 0) {
        bloc.add(
          UpdateSize(
            i,
            size.copyWith(
              takeawayPrice: size.dineInPrice,
              deliveryPrice: size.dineInPrice,
            ),
          ),
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dine-in prices copied to all channels'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showModifierStylePreview(BuildContext context) async {
    final selectedStyle = await showDialog<String>(
      context: context,
      builder: (dialogContext) => const ModifierStylePreviewDialog(),
    );

    if (selectedStyle != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selected style: $selectedStyle'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}
