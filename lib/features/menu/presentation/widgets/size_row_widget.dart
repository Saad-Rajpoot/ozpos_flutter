import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/menu_item_edit_entity.dart';
import '../../../addons/presentation/widgets/addon_rules_compact_display.dart';

/// Individual size row with expandable details
class SizeRowWidget extends StatefulWidget {
  final SizeEditEntity size;
  final String itemId; // Menu item ID for addon management
  final bool isExpanded;
  final VoidCallback onToggleExpand;
  final Function(SizeEditEntity) onUpdate;
  final VoidCallback onDelete;
  final List<AddOnCategoryEntity> availableAddOnCategories;

  const SizeRowWidget({
    super.key,
    required this.size,
    required this.itemId,
    required this.isExpanded,
    required this.onToggleExpand,
    required this.onUpdate,
    required this.onDelete,
    required this.availableAddOnCategories,
  });

  @override
  State<SizeRowWidget> createState() => _SizeRowWidgetState();
}

class _SizeRowWidgetState extends State<SizeRowWidget> {
  late TextEditingController _nameController;
  late TextEditingController _dineInController;
  late TextEditingController _takeawayController;
  late TextEditingController _deliveryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.size.name);
    _dineInController = TextEditingController(
      text: widget.size.dineInPrice > 0
          ? widget.size.dineInPrice.toStringAsFixed(2)
          : '',
    );
    _takeawayController = TextEditingController(
      text:
          (widget.size.takeawayPrice != null && widget.size.takeawayPrice! > 0)
          ? widget.size.takeawayPrice!.toStringAsFixed(2)
          : '',
    );
    _deliveryController = TextEditingController(
      text:
          (widget.size.deliveryPrice != null && widget.size.deliveryPrice! > 0)
          ? widget.size.deliveryPrice!.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dineInController.dispose();
    _takeawayController.dispose();
    _deliveryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: widget.isExpanded
              ? const Color(0xFF2196F3)
              : Colors.grey.shade300,
          width: widget.isExpanded ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Collapsed view
          InkWell(
            onTap: widget.onToggleExpand,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Drag handle
                  Icon(
                    Icons.drag_indicator,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  const SizedBox(width: 12),

                  // Size name
                  Expanded(
                    flex: 2,
                    child: Text(
                      widget.size.name.isEmpty
                          ? 'Unnamed Size'
                          : widget.size.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: widget.size.name.isEmpty
                            ? Colors.grey.shade400
                            : const Color(0xFF1F2937),
                      ),
                    ),
                  ),

                  // Price display
                  Expanded(
                    child: Text(
                      _getPriceDisplay(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                  // Add-ons count
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.size.addOnItems.length} add-ons',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Expand icon
                  Icon(
                    widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade600,
                  ),

                  // Delete button
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                    onPressed: widget.onDelete,
                    tooltip: 'Delete size',
                  ),
                ],
              ),
            ),
          ),

          // Expanded view
          if (widget.isExpanded) _buildExpandedView(),
        ],
      ),
    );
  }

  Widget _buildExpandedView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Size name
          _buildTextField(
            label: 'Size Name',
            controller: _nameController,
            hint: 'e.g., Small, Medium, Large',
            onChanged: (value) {
              widget.onUpdate(widget.size.copyWith(name: value));
            },
          ),
          const SizedBox(height: 16),

          // Pricing section
          const Text(
            'Pricing by Channel',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildPriceField(
                  label: 'Dine-In Price',
                  controller: _dineInController,
                  onChanged: (value) {
                    final price = double.tryParse(value) ?? 0.0;
                    widget.onUpdate(widget.size.copyWith(dineInPrice: price));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPriceField(
                  label: 'Takeaway Price',
                  controller: _takeawayController,
                  onChanged: (value) {
                    final price = double.tryParse(value) ?? 0.0;
                    widget.onUpdate(widget.size.copyWith(takeawayPrice: price));
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPriceField(
                  label: 'Delivery Price',
                  controller: _deliveryController,
                  onChanged: (value) {
                    final price = double.tryParse(value) ?? 0.0;
                    widget.onUpdate(widget.size.copyWith(deliveryPrice: price));
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Add-ons section
          _buildAddOnsSection(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            prefixText: '\$',
            hintText: '0.00',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddOnsSection() {
    // Generate or use existing size ID
    final sizeId = widget.size.id ?? const Uuid().v4();

    // If size doesn't have an ID yet, update it
    if (widget.size.id == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onUpdate(widget.size.copyWith(id: sizeId));
      });
    }

    return AddonRulesCompactDisplay(
      itemId: widget.itemId,
      sizeId: sizeId,
      sizeLabel: widget.size.name,
    );
  }

  String _getPriceDisplay() {
    if (widget.size.dineInPrice > 0) {
      return '\$${widget.size.dineInPrice.toStringAsFixed(2)}';
    }
    return 'No price set';
  }
}
