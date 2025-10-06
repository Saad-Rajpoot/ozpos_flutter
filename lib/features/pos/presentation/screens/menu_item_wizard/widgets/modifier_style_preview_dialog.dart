import 'package:flutter/material.dart';

/// Dialog to preview how add-on items will appear in different display styles
class ModifierStylePreviewDialog extends StatefulWidget {
  const ModifierStylePreviewDialog({super.key});

  @override
  State<ModifierStylePreviewDialog> createState() => _ModifierStylePreviewDialogState();
}

class _ModifierStylePreviewDialogState extends State<ModifierStylePreviewDialog> {
  String _selectedStyle = 'list';
  
  // Sample add-on items for preview
  final _sampleAddOns = [
    {'name': 'Extra Cheese', 'price': 2.50, 'selected': true},
    {'name': 'Pepperoni', 'price': 3.00, 'selected': false},
    {'name': 'Mushrooms', 'price': 1.50, 'selected': false},
    {'name': 'Olives', 'price': 1.50, 'selected': false},
    {'name': 'Bell Peppers', 'price': 1.75, 'selected': false},
    {'name': 'Onions', 'price': 1.25, 'selected': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.preview, color: Color(0xFF2196F3)),
                const SizedBox(width: 12),
                const Text(
                  'Add-on Display Style Preview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose how add-on items will be displayed to customers',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 24),

            // Style selector
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildStyleChip('list', 'List View', Icons.list),
                _buildStyleChip('grid', 'Grid View', Icons.grid_view),
                _buildStyleChip('chips', 'Chips', Icons.label),
                _buildStyleChip('compact', 'Compact', Icons.view_compact),
              ],
            ),
            const SizedBox(height: 24),

            // Preview area
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Preview',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getStyleDisplayName(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildPreview(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Footer buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedStyle);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Apply Style'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleChip(String style, String label, IconData icon) {
    final isSelected = _selectedStyle == style;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedStyle = style;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStyleDisplayName() {
    switch (_selectedStyle) {
      case 'list':
        return 'LIST VIEW';
      case 'grid':
        return 'GRID VIEW';
      case 'chips':
        return 'CHIPS';
      case 'compact':
        return 'COMPACT';
      default:
        return 'UNKNOWN';
    }
  }

  Widget _buildPreview() {
    switch (_selectedStyle) {
      case 'list':
        return _buildListView();
      case 'grid':
        return _buildGridView();
      case 'chips':
        return _buildChipsView();
      case 'compact':
        return _buildCompactView();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildListView() {
    return Column(
      children: _sampleAddOns.map((addon) {
        final isSelected = addon['selected'] as bool;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: ListTile(
            leading: Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade400,
            ),
            title: Text(
              addon['name'] as String,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            trailing: Text(
              '+\$${(addon['price'] as double).toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF059669),
              ),
            ),
            onTap: () {
              setState(() {
                addon['selected'] = !isSelected;
              });
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: _sampleAddOns.length,
      itemBuilder: (context, index) {
        final addon = _sampleAddOns[index];
        final isSelected = addon['selected'] as bool;
        return InkWell(
          onTap: () {
            setState(() {
              addon['selected'] = !isSelected;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        addon['name'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade400,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '+\$${(addon['price'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChipsView() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _sampleAddOns.map((addon) {
        final isSelected = addon['selected'] as bool;
        return InkWell(
          onTap: () {
            setState(() {
              addon['selected'] = !isSelected;
            });
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2196F3) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected) ...[
                  const Icon(Icons.check, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                ],
                Text(
                  addon['name'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '+\$${(addon['price'] as double).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCompactView() {
    return Column(
      children: _sampleAddOns.map((addon) {
        final isSelected = addon['selected'] as bool;
        return InkWell(
          onTap: () {
            setState(() {
              addon['selected'] = !isSelected;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            margin: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
              border: Border(
                left: BorderSide(
                  color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
                  width: 3,
                ),
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                  color: isSelected ? const Color(0xFF2196F3) : Colors.grey.shade400,
                  size: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    addon['name'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '+\$${(addon['price'] as double).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
