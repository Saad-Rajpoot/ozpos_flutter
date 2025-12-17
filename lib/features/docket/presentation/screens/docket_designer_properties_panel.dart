import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/docket_designer_bloc.dart';
import '../bloc/docket_designer_event.dart';
import '../bloc/docket_designer_state.dart';
import '../models/docket_component_model.dart';
import '../models/docket_component_model.dart' as models;

/// Right sidebar panel showing component properties
class DocketDesignerPropertiesPanel extends StatelessWidget {
  final double width;
  final DocketDesignerLoaded state;

  const DocketDesignerPropertiesPanel({
    super.key,
    required this.width,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final selectedComponent = state.selectedComponentId != null
        ? state.components
            .where((c) => c.id == state.selectedComponentId)
            .firstOrNull
        : null;

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
              'Properties',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Properties content
          Expanded(
            child: selectedComponent == null
                ? const Center(
                    child: Text(
                      'Select a component to edit properties',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildComponentType(selectedComponent),
                      const SizedBox(height: 24),
                      _buildSizeProperties(context, selectedComponent),
                      const SizedBox(height: 24),
                      _buildProperties(context, selectedComponent),
                      const SizedBox(height: 24),
                      _buildRemoveButton(context, selectedComponent.id),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentType(DocketComponentModel component) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            _getComponentIcon(component.type),
            size: 20,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Component Type: ${_getComponentTypeName(component.type)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeProperties(
    BuildContext context,
    DocketComponentModel component,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Size',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Width',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: component.width.toInt().toString(),
                    ),
                    onChanged: (value) {
                      final width = double.tryParse(value);
                      if (width != null &&
                          width >= 50 &&
                          width <= state.canvasWidth) {
                        context.read<DocketDesignerBloc>().add(
                              UpdateComponentSizeEvent(
                                component.id,
                                width,
                                component.height,
                              ),
                            );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Height',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: component.height.toInt().toString(),
                    ),
                    onChanged: (value) {
                      final height = double.tryParse(value);
                      if (height != null &&
                          height >= 20 &&
                          height <= state.canvasHeight) {
                        context.read<DocketDesignerBloc>().add(
                              UpdateComponentSizeEvent(
                                component.id,
                                component.width,
                                height,
                              ),
                            );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'X Position',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: component.x.toInt().toString(),
                    ),
                    onChanged: (value) {
                      final x = double.tryParse(value);
                      if (x != null &&
                          x >= 0 &&
                          x + component.width <= state.canvasWidth) {
                        context.read<DocketDesignerBloc>().add(
                              UpdateComponentPositionEvent(
                                  component.id, x, component.y),
                            );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Y Position',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.all(8),
                    ),
                    keyboardType: TextInputType.number,
                    controller: TextEditingController(
                      text: component.y.toInt().toString(),
                    ),
                    onChanged: (value) {
                      final y = double.tryParse(value);
                      if (y != null &&
                          y >= 0 &&
                          y + component.height <= state.canvasHeight) {
                        context.read<DocketDesignerBloc>().add(
                              UpdateComponentPositionEvent(
                                  component.id, component.x, y),
                            );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProperties(
    BuildContext context,
    DocketComponentModel component,
  ) {
    switch (component.type) {
      case DocketComponentType.text:
        return _buildTextProperties(context, component);
      case DocketComponentType.variable:
        return _buildVariableProperties(context, component);
      case DocketComponentType.logo:
        return _buildLogoProperties(context, component);
      case DocketComponentType.separator:
        return _buildSeparatorProperties(context, component);
      case DocketComponentType.box:
        return _buildBoxProperties(context, component);
      case DocketComponentType.columns:
        return _buildColumnsProperties(context, component);
      case DocketComponentType.itemTable:
        return _buildItemTableProperties(context, component);
      case DocketComponentType.qrCode:
        return _buildQRCodeProperties(context, component);
      case DocketComponentType.barcode:
        return _buildBarcodeProperties(context, component);
      case DocketComponentType.space:
        return _buildSpaceProperties(context, component);
      case DocketComponentType.customText:
        return _buildTextProperties(context, component);
    }
  }

  Widget _buildTextProperties(
    BuildContext context,
    DocketComponentModel component,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Font Size',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Slider(
          value: _getNumericValue(component.properties['fontSize'], 14),
          min: 8,
          max: 32,
          divisions: 24,
          label: '${_getIntValue(component.properties['fontSize'], 14)}',
          onChanged: (value) {
            context.read<DocketDesignerBloc>().add(
                  UpdateComponentPropertiesEvent(
                    component.id,
                    {'fontSize': value.toInt()},
                  ),
                );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Font Weight',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        DropdownButton<String>(
          value: component.properties['fontWeight'] ?? 'normal',
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'normal', child: Text('Normal')),
            DropdownMenuItem(value: 'bold', child: Text('Bold')),
          ],
          onChanged: (value) {
            if (value != null) {
              context.read<DocketDesignerBloc>().add(
                    UpdateComponentPropertiesEvent(
                      component.id,
                      {'fontWeight': value},
                    ),
                  );
            }
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Text Align',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        DropdownButton<String>(
          value: component.properties['textAlign'] ?? 'left',
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'left', child: Text('Left')),
            DropdownMenuItem(value: 'center', child: Text('Center')),
            DropdownMenuItem(value: 'right', child: Text('Right')),
          ],
          onChanged: (value) {
            if (value != null) {
              context.read<DocketDesignerBloc>().add(
                    UpdateComponentPropertiesEvent(
                      component.id,
                      {'textAlign': value},
                    ),
                  );
            }
          },
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Content',
            border: OutlineInputBorder(),
          ),
          controller: TextEditingController(
            text: component.properties['content'] ?? 'Double click to edit',
          ),
          onChanged: (value) {
            context.read<DocketDesignerBloc>().add(
                  UpdateComponentPropertiesEvent(
                    component.id,
                    {'content': value},
                  ),
                );
          },
        ),
      ],
    );
  }

  Widget _buildVariableProperties(
    BuildContext context,
    DocketComponentModel component,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Variable',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        DropdownButton<String>(
          value: component.properties['variable'] ?? 'restaurant',
          isExpanded: true,
          items: models.DocketVariables.available.map((varData) {
            return DropdownMenuItem<String>(
              value: varData['key'],
              child: Text(varData['label'] ?? varData['key'] ?? ''),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              context.read<DocketDesignerBloc>().add(
                    UpdateComponentPropertiesEvent(
                      component.id,
                      {'variable': value},
                    ),
                  );
            }
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Text Format',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        DropdownButton<String>(
          value: component.properties['textAlign'] ?? 'left',
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'left', child: Text('Left Align')),
            DropdownMenuItem(value: 'center', child: Text('Center Align')),
            DropdownMenuItem(value: 'right', child: Text('Right Align')),
          ],
          onChanged: (value) {
            if (value != null) {
              context.read<DocketDesignerBloc>().add(
                    UpdateComponentPropertiesEvent(
                      component.id,
                      {'textAlign': value},
                    ),
                  );
            }
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Font Size',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Slider(
          value: _getNumericValue(component.properties['fontSize'], 14),
          min: 8,
          max: 32,
          divisions: 24,
          label: '${_getIntValue(component.properties['fontSize'], 14)}',
          onChanged: (value) {
            context.read<DocketDesignerBloc>().add(
                  UpdateComponentPropertiesEvent(
                    component.id,
                    {'fontSize': value.toInt()},
                  ),
                );
          },
        ),
      ],
    );
  }

  Widget _buildLogoProperties(
    BuildContext context,
    DocketComponentModel component,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Image Height',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Slider(
          value: _getNumericValue(component.properties['height'], 60),
          min: 30,
          max: 200,
          divisions: 17,
          label: '${_getIntValue(component.properties['height'], 60)}',
          onChanged: (value) {
            context.read<DocketDesignerBloc>().add(
                  UpdateComponentPropertiesEvent(
                    component.id,
                    {'height': value.toInt()},
                  ),
                );
          },
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.upload_file, size: 18),
          label: const Text('Upload Image'),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image upload coming soon')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSeparatorProperties(
    BuildContext context,
    DocketComponentModel component,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Line Thickness',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Slider(
          value: _getThicknessValue(component.properties['thickness']),
          min: 1,
          max: 10,
          divisions: 9,
          label:
              '${_getThicknessValue(component.properties['thickness']).toInt()}px',
          onChanged: (value) {
            context.read<DocketDesignerBloc>().add(
                  UpdateComponentPropertiesEvent(
                    component.id,
                    {'thickness': value.toInt()},
                  ),
                );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Line Style',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        DropdownButton<String>(
          value: component.properties['lineStyle'] ?? 'solid',
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 'solid', child: Text('Solid')),
            DropdownMenuItem(value: 'dashed', child: Text('Dashed')),
            DropdownMenuItem(value: 'dotted', child: Text('Dotted')),
            DropdownMenuItem(value: 'double', child: Text('Double')),
          ],
          onChanged: (value) {
            if (value != null) {
              context.read<DocketDesignerBloc>().add(
                    UpdateComponentPropertiesEvent(
                      component.id,
                      {'lineStyle': value},
                    ),
                  );
            }
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Line Color',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Color(_getIntValue(
                      component.properties['color'], Colors.black.value)),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Color picker coming soon')),
                );
              },
              child: const Text('Change'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBoxProperties(
    BuildContext context,
    DocketComponentModel component,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Border Width',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Slider(
          value: _getNumericValue(component.properties['borderWidth'], 1),
          min: 1,
          max: 5,
          divisions: 4,
          label: '${_getIntValue(component.properties['borderWidth'], 1)}',
          onChanged: (value) {
            context.read<DocketDesignerBloc>().add(
                  UpdateComponentPropertiesEvent(
                    component.id,
                    {'borderWidth': value.toInt()},
                  ),
                );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Padding',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Slider(
          value: _getNumericValue(component.properties['padding'], 8),
          min: 0,
          max: 20,
          divisions: 20,
          label: '${_getIntValue(component.properties['padding'], 8)}',
          onChanged: (value) {
            context.read<DocketDesignerBloc>().add(
                  UpdateComponentPropertiesEvent(
                    component.id,
                    {'padding': value.toInt()},
                  ),
                );
          },
        ),
      ],
    );
  }

  Widget _buildColumnsProperties(
    BuildContext context,
    DocketComponentModel component,
  ) {
    final columnCount = _getIntValue(component.properties['columnCount'], 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Column Count',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        DropdownButton<int>(
          value: columnCount,
          isExpanded: true,
          items: const [
            DropdownMenuItem(value: 2, child: Text('2 Columns')),
            DropdownMenuItem(value: 3, child: Text('3 Columns')),
          ],
          onChanged: (value) {
            if (value != null) {
              context.read<DocketDesignerBloc>().add(
                    UpdateComponentPropertiesEvent(
                      component.id,
                      {'columnCount': value},
                    ),
                  );
            }
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Add Component to Column',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        // Column buttons
        ...List.generate(columnCount, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: Text('Add to Column ${index + 1}'),
              onPressed: () {
                // Show dialog to select component type
                _showAddToColumnDialog(context, component.id, index);
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        // Show existing children
        if (component.children.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nested Components',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ...component.children.map((child) {
                final columnIndex =
                    _getIntValue(child.properties['columnIndex'], 0);
                return Card(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    dense: true,
                    title: Text(
                      _getComponentTypeName(child.type),
                      style: const TextStyle(fontSize: 12),
                    ),
                    subtitle: Text(
                      'Column ${columnIndex + 1}',
                      style:
                          TextStyle(fontSize: 10, color: Colors.grey.shade600),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, size: 16),
                      color: Colors.red,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Delete nested component coming soon')),
                        );
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
      ],
    );
  }

  void _showAddToColumnDialog(
      BuildContext context, String parentId, int columnIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Component to Column'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Text'),
              onTap: () {
                Navigator.pop(context);
                context.read<DocketDesignerBloc>().add(
                      AddChildComponentEvent(
                        parentId,
                        'text',
                        columnIndex: columnIndex,
                      ),
                    );
              },
            ),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('Variable'),
              onTap: () {
                Navigator.pop(context);
                context.read<DocketDesignerBloc>().add(
                      AddChildComponentEvent(
                        parentId,
                        'variable',
                        columnIndex: columnIndex,
                      ),
                    );
              },
            ),
            ListTile(
              leading: const Icon(Icons.minimize),
              title: const Text('Separator'),
              onTap: () {
                Navigator.pop(context);
                context.read<DocketDesignerBloc>().add(
                      AddChildComponentEvent(
                        parentId,
                        'separator',
                        columnIndex: columnIndex,
                      ),
                    );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTableProperties(
    BuildContext context,
    DocketComponentModel component,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Show Headers'),
          value: component.properties['showHeaders'] ?? true,
          onChanged: (value) {
            context.read<DocketDesignerBloc>().add(
                  UpdateComponentPropertiesEvent(
                    component.id,
                    {'showHeaders': value},
                  ),
                );
          },
        ),
      ],
    );
  }

  Widget _buildRemoveButton(BuildContext context, String componentId) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.delete_outline, size: 18),
        label: const Text('Remove Component'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () {
          context
              .read<DocketDesignerBloc>()
              .add(DeleteComponentEvent(componentId));
        },
      ),
    );
  }

  IconData _getComponentIcon(DocketComponentType type) {
    switch (type) {
      case DocketComponentType.text:
        return Icons.text_fields;
      case DocketComponentType.variable:
        return Icons.code;
      case DocketComponentType.logo:
        return Icons.image;
      case DocketComponentType.separator:
        return Icons.minimize;
      case DocketComponentType.box:
        return Icons.crop_free;
      case DocketComponentType.columns:
        return Icons.view_column;
      case DocketComponentType.itemTable:
        return Icons.table_chart;
      case DocketComponentType.qrCode:
        return Icons.qr_code;
      case DocketComponentType.barcode:
        return Icons.qr_code_scanner;
      case DocketComponentType.space:
        return Icons.space_bar;
      case DocketComponentType.customText:
        return Icons.title;
    }
  }

  String _getComponentTypeName(DocketComponentType type) {
    switch (type) {
      case DocketComponentType.text:
        return 'Text';
      case DocketComponentType.variable:
        return 'Variable';
      case DocketComponentType.logo:
        return 'Logo/Image';
      case DocketComponentType.separator:
        return 'Line Separator';
      case DocketComponentType.box:
        return 'Box';
      case DocketComponentType.columns:
        return 'Columns';
      case DocketComponentType.itemTable:
        return 'Item Table';
      case DocketComponentType.qrCode:
        return 'QR Code';
      case DocketComponentType.barcode:
        return 'Barcode';
      case DocketComponentType.space:
        return 'Space';
      case DocketComponentType.customText:
        return 'Custom Text';
    }
  }

  Widget _buildQRCodeProperties(
    BuildContext context,
    DocketComponentModel component,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QR Code Data',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Data',
            border: OutlineInputBorder(),
            hintText: 'Enter URL or text',
          ),
          controller: TextEditingController(
            text: component.properties['data'] ?? 'https://example.com',
          ),
          onChanged: (value) {
            context.read<DocketDesignerBloc>().add(
                  UpdateComponentPropertiesEvent(
                    component.id,
                    {'data': value},
                  ),
                );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Size',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Slider(
          value: _getNumericValue(component.properties['size'], 100),
          min: 50,
          max: 200,
          divisions: 15,
          label: '${_getIntValue(component.properties['size'], 100)}',
          onChanged: (value) {
            context.read<DocketDesignerBloc>().add(
                  UpdateComponentPropertiesEvent(
                    component.id,
                    {'size': value.toInt()},
                  ),
                );
          },
        ),
      ],
    );
  }

  Widget _buildBarcodeProperties(
    BuildContext context,
    DocketComponentModel component,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Barcode Data',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Data',
            border: OutlineInputBorder(),
            hintText: 'Enter barcode number',
          ),
          controller: TextEditingController(
            text: component.properties['data'] ?? '1234567890123',
          ),
          onChanged: (value) {
            context.read<DocketDesignerBloc>().add(
                  UpdateComponentPropertiesEvent(
                    component.id,
                    {'data': value},
                  ),
                );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Height',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Slider(
          value: _getNumericValue(component.properties['height'], 50),
          min: 30,
          max: 100,
          divisions: 7,
          label: '${_getIntValue(component.properties['height'], 50)}',
          onChanged: (value) {
            context.read<DocketDesignerBloc>().add(
                  UpdateComponentPropertiesEvent(
                    component.id,
                    {'height': value.toInt()},
                  ),
                );
          },
        ),
      ],
    );
  }

  Widget _buildSpaceProperties(
    BuildContext context,
    DocketComponentModel component,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Space Height',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        Slider(
          value: _getNumericValue(component.properties['height'], 20),
          min: 5,
          max: 100,
          divisions: 19,
          label: '${_getIntValue(component.properties['height'], 20)}',
          onChanged: (value) {
            context.read<DocketDesignerBloc>().add(
                  UpdateComponentPropertiesEvent(
                    component.id,
                    {'height': value.toInt()},
                  ),
                );
          },
        ),
      ],
    );
  }

  double _getThicknessValue(dynamic value) {
    if (value == null) return 1.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? 1.0;
    }
    return 1.0;
  }

  double _getNumericValue(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? defaultValue;
    }
    return defaultValue;
  }

  int _getIntValue(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed ?? defaultValue;
    }
    return defaultValue;
  }
}

extension on Iterable<DocketComponentModel> {
  DocketComponentModel? get firstOrNull => isEmpty ? null : first;
}
