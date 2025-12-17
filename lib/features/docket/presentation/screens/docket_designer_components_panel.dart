import 'package:flutter/material.dart';

/// Left sidebar panel showing available components
class DocketDesignerComponentsPanel extends StatelessWidget {
  final double width;
  final Function(String) onComponentSelected;

  const DocketDesignerComponentsPanel({
    super.key,
    required this.width,
    required this.onComponentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: const Text(
              'Components',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Components list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                _ComponentCard(
                  icon: Icons.text_fields,
                  title: 'Text',
                  description: 'Static text block',
                  componentType: 'text',
                  onTap: () => onComponentSelected('text'),
                ),
                const SizedBox(height: 8),
                _ComponentCard(
                  icon: Icons.code,
                  title: 'Variable',
                  description: 'Dynamic data field',
                  componentType: 'variable',
                  onTap: () => onComponentSelected('variable'),
                ),
                const SizedBox(height: 8),
                _ComponentCard(
                  icon: Icons.image,
                  title: 'Logo/Image',
                  description: 'Upload image or logo',
                  componentType: 'logo',
                  onTap: () => onComponentSelected('logo'),
                ),
                const SizedBox(height: 8),
                _ComponentCard(
                  icon: Icons.minimize,
                  title: 'Line Separator',
                  description: 'Horizontal divider',
                  componentType: 'separator',
                  onTap: () => onComponentSelected('separator'),
                ),
                const SizedBox(height: 8),
                _ComponentCard(
                  icon: Icons.crop_free,
                  title: 'Box',
                  description: 'Container with border',
                  componentType: 'box',
                  onTap: () => onComponentSelected('box'),
                ),
                const SizedBox(height: 8),
                _ComponentCard(
                  icon: Icons.view_column,
                  title: 'Columns',
                  description: '2 or 3 column layout',
                  componentType: 'columns',
                  onTap: () => onComponentSelected('columns'),
                ),
                const SizedBox(height: 8),
                _ComponentCard(
                  icon: Icons.table_chart,
                  title: 'Item Table',
                  description: 'Repeating items list',
                  componentType: 'itemtable',
                  onTap: () => onComponentSelected('itemtable'),
                ),
                const SizedBox(height: 8),
                _ComponentCard(
                  icon: Icons.qr_code,
                  title: 'QR Code',
                  description: 'QR code generator',
                  componentType: 'qrcode',
                  onTap: () => onComponentSelected('qrcode'),
                ),
                const SizedBox(height: 8),
                _ComponentCard(
                  icon: Icons.qr_code_scanner,
                  title: 'Barcode',
                  description: 'Barcode generator',
                  componentType: 'barcode',
                  onTap: () => onComponentSelected('barcode'),
                ),
                const SizedBox(height: 8),
                _ComponentCard(
                  icon: Icons.space_bar,
                  title: 'Space',
                  description: 'Vertical spacing',
                  componentType: 'space',
                  onTap: () => onComponentSelected('space'),
                ),
                const SizedBox(height: 8),
                _ComponentCard(
                  icon: Icons.title,
                  title: 'Custom Text',
                  description: 'Custom formatted text',
                  componentType: 'customtext',
                  onTap: () => onComponentSelected('customtext'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComponentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String componentType;
  final VoidCallback onTap;

  const _ComponentCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.componentType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: componentType,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.blue, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 24, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 24, color: Colors.grey.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 24, color: Colors.grey.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
