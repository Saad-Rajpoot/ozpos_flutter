import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/docket_designer_bloc.dart';
import '../bloc/docket_designer_event.dart';
import '../bloc/docket_designer_state.dart';
import '../models/docket_component_model.dart';

/// Center canvas area for designing the docket
class DocketDesignerCanvas extends StatefulWidget {
  final DocketDesignerLoaded state;

  const DocketDesignerCanvas({
    super.key,
    required this.state,
  });

  @override
  State<DocketDesignerCanvas> createState() => _DocketDesignerCanvasState();
}

class _DocketDesignerCanvasState extends State<DocketDesignerCanvas> {
  final GlobalKey _canvasKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9FAFB),
      child: Column(
        children: [
          // Canvas toolbar
          _buildCanvasToolbar(context),
          // Canvas area
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Transform.scale(
                    scale: widget.state.zoomLevel,
                    child: Container(
                      key: _canvasKey,
                      width: widget.state.canvasWidth.toDouble(),
                      height: widget.state.canvasHeight.toDouble(),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRect(
                        child: OverflowBox(
                          minWidth: widget.state.canvasWidth.toDouble(),
                          maxWidth: widget.state.canvasWidth.toDouble(),
                          minHeight: widget.state.canvasHeight.toDouble(),
                          maxHeight: widget.state.canvasHeight.toDouble(),
                          child: widget.state.isPreviewMode
                              ? _buildPreviewContent(context)
                              : _buildDesignContent(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesignContent(BuildContext context) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (data) => true,
      onAcceptWithDetails: (details) {
        // Calculate drop position based on drag details relative to canvas container
        final RenderBox? canvasBox =
            _canvasKey.currentContext?.findRenderObject() as RenderBox?;
        if (canvasBox != null) {
          final localPosition = canvasBox.globalToLocal(details.offset);
          // Account for zoom scale
          final dropX = (localPosition.dx / widget.state.zoomLevel).clamp(
            0.0,
            widget.state.canvasWidth.toDouble(),
          );
          final dropY = (localPosition.dy / widget.state.zoomLevel).clamp(
            0.0,
            widget.state.canvasHeight.toDouble(),
          );

          context.read<DocketDesignerBloc>().add(AddComponentEvent(
                details.data,
                x: dropX,
                y: dropY,
              ));
        } else {
          // Fallback to default position if canvasBox is null
          context
              .read<DocketDesignerBloc>()
              .add(AddComponentEvent(details.data));
        }
      },
      builder: (context, candidateData, rejectedData) {
        return SizedBox(
          width: widget.state.canvasWidth.toDouble(),
          height: widget.state.canvasHeight.toDouble(),
          child: Stack(
            children: [
              // Grid background
              CustomPaint(
                painter: _GridPainter(),
                size: Size(
                  widget.state.canvasWidth.toDouble(),
                  widget.state.canvasHeight.toDouble(),
                ),
              ),
              // Highlight drop area when dragging
              if (candidateData.isNotEmpty)
                Container(
                  width: widget.state.canvasWidth.toDouble(),
                  height: widget.state.canvasHeight.toDouble(),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    border: Border.all(
                      color: Colors.blue,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
              // Components
              ...widget.state.components.map((component) {
                return _ComponentWidget(
                  component: component,
                  isSelected: component.id == widget.state.selectedComponentId,
                  canvasWidth: widget.state.canvasWidth.toDouble(),
                  canvasHeight: widget.state.canvasHeight.toDouble(),
                  onTap: () {
                    context
                        .read<DocketDesignerBloc>()
                        .add(SelectComponentEvent(component.id));
                  },
                  onDelete: () {
                    context
                        .read<DocketDesignerBloc>()
                        .add(DeleteComponentEvent(component.id));
                  },
                  onPositionChanged: (x, y) {
                    context
                        .read<DocketDesignerBloc>()
                        .add(UpdateComponentPositionEvent(component.id, x, y));
                  },
                  onSizeChanged: (width, height) {
                    context.read<DocketDesignerBloc>().add(
                        UpdateComponentSizeEvent(component.id, width, height));
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewContent(BuildContext context) {
    return SizedBox(
      width: widget.state.canvasWidth.toDouble(),
      height: widget.state.canvasHeight.toDouble(),
      child: Stack(
        children: [
          ...widget.state.components.map((component) {
            return Positioned(
              left: component.x,
              top: component.y,
              width: component.width,
              height: component.height,
              child: _buildPreviewComponent(component),
            );
          }),
        ],
      ),
    );
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

  Color _getLineColor(dynamic colorValue) {
    if (colorValue == null) return Colors.black;
    if (colorValue is num) {
      return Color(colorValue.toInt());
    }
    if (colorValue is String) {
      final parsed = int.tryParse(colorValue);
      if (parsed != null) return Color(parsed);
      // Try hex color
      if (colorValue.startsWith('#')) {
        final hex = colorValue.substring(1);
        final parsed = int.tryParse(hex, radix: 16);
        if (parsed != null) return Color(0xFF000000 + parsed);
      }
    }
    return Colors.black;
  }

  Border? _getLineBorder(String? lineStyle, double thickness) {
    if (lineStyle == 'double') {
      return Border.symmetric(
        horizontal: BorderSide(
          color: Colors.black,
          width: thickness / 3,
        ),
      );
    }
    return null;
  }

  Widget _buildPreviewComponent(DocketComponentModel component) {
    switch (component.type) {
      case DocketComponentType.text:
        return Container(
          width: component.width,
          padding: const EdgeInsets.all(8),
          child: Text(
            component.properties['content'] ?? '',
            style: TextStyle(
              fontSize:
                  (component.properties['fontSize'] as num?)?.toDouble() ?? 14,
              fontWeight: component.properties['fontWeight'] == 'bold'
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
            textAlign: _getTextAlign(component.properties['textAlign']),
          ),
        );
      case DocketComponentType.variable:
        return Container(
          width: component.width,
          padding: const EdgeInsets.all(8),
          child: Text(
            _getVariableValue(component.properties['variable'] ?? 'restaurant'),
            style: const TextStyle(fontSize: 14),
            textAlign: _getTextAlign(component.properties['textAlign']),
          ),
        );
      case DocketComponentType.logo:
        return Container(
          width: component.width,
          height: component.height,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.image,
            size: 32,
            color: Colors.grey,
          ),
        );
      case DocketComponentType.separator:
        final thickness =
            _getNumericValue(component.properties['thickness'], 1.0);
        final lineStyle = component.properties['lineStyle'] ?? 'solid';
        return Container(
          width: component.width,
          height: component.height,
          alignment: Alignment.center,
          child: Container(
            height: thickness,
            width: component.width,
            decoration: BoxDecoration(
              color: _getLineColor(component.properties['color']),
              border: _getLineBorder(lineStyle, thickness),
            ),
          ),
        );
      case DocketComponentType.box:
        return Container(
          width: component.width,
          height: component.height,
          padding: EdgeInsets.all(
            (component.properties['padding'] as num?)?.toDouble() ?? 8,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width:
                  (component.properties['borderWidth'] as num?)?.toDouble() ??
                      1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text('Box'),
        );
      case DocketComponentType.columns:
        final columnCount =
            (component.properties['columnCount'] as num?)?.toInt() ?? 2;
        return Container(
          width: component.width,
          height: component.height,
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              columnCount,
              (index) => Expanded(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Nested components in this column
                      ...component.children
                          .where((child) =>
                              (child.properties['columnIndex'] as num?)
                                  ?.toInt() ==
                              index)
                          .map((child) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: _buildPreviewComponent(child),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      case DocketComponentType.itemTable:
        return Container(
          width: component.width,
          height: component.height,
          padding: const EdgeInsets.all(8),
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            children: [
              const TableRow(
                children: [
                  TableCell(
                      child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('Item',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
                  TableCell(
                      child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('Qty',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
                  TableCell(
                      child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('Price',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
                ],
              ),
            ],
          ),
        );
      case DocketComponentType.qrCode:
        return Container(
          width: component.width,
          height: component.height,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code, size: 48, color: Colors.grey),
              const SizedBox(height: 4),
              Text(
                'QR Code',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      case DocketComponentType.barcode:
        return Container(
          width: component.width,
          height: component.height,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_scanner, size: 32, color: Colors.grey),
              const SizedBox(height: 4),
              Text(
                'Barcode',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      case DocketComponentType.space:
        return Container(
          width: component.width,
          height: component.height,
          color: Colors.grey.shade50,
        );
      case DocketComponentType.customText:
        return Container(
          width: component.width,
          padding: const EdgeInsets.all(8),
          child: Text(
            component.properties['content'] ?? 'Custom Text',
            style: TextStyle(
              fontSize:
                  (component.properties['fontSize'] as num?)?.toDouble() ?? 14,
              fontWeight: component.properties['fontWeight'] == 'bold'
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
    }
  }

  TextAlign _getTextAlign(String? align) {
    switch (align) {
      case 'center':
        return TextAlign.center;
      case 'right':
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  String _getVariableValue(String key) {
    switch (key) {
      case 'restaurant':
        return 'Sample Restaurant';
      case 'orderid':
        return 'ORD-12345';
      case 'date':
        return DateTime.now().toString().split(' ')[0];
      case 'time':
        return DateTime.now().toString().split(' ')[1].substring(0, 5);
      case 'table':
        return 'Table 5';
      case 'server':
        return 'John Doe';
      case 'subtotal':
        return '\$45.00';
      case 'tax':
        return '\$4.50';
      case 'total':
        return '\$49.50';
      case 'payment':
        return 'Cash';
      case 'change':
        return '\$0.50';
      case 'customer':
        return 'Jane Smith';
      case 'phone':
        return '+1 234 567 8900';
      default:
        return 'Sample Value';
    }
  }

  Widget _buildCanvasToolbar(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // Printer size dropdown
          DropdownButton<String>(
            value: widget.state.printerSize,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(
                  value: '58mm Thermal', child: Text('58mm Thermal')),
              DropdownMenuItem(
                  value: '80mm Thermal', child: Text('80mm Thermal')),
              DropdownMenuItem(value: 'A4', child: Text('A4')),
              DropdownMenuItem(value: 'A5', child: Text('A5')),
              DropdownMenuItem(value: 'Letter', child: Text('Letter')),
            ],
            onChanged: (value) {
              if (value != null) {
                context
                    .read<DocketDesignerBloc>()
                    .add(UpdatePrinterSizeEvent(value));
              }
            },
          ),
          const SizedBox(width: 16),
          Text(
            '${widget.state.canvasWidth} x ${widget.state.canvasHeight}px',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${widget.state.components.length} components',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          // Zoom controls
          IconButton(
            icon: const Icon(Icons.zoom_out, size: 20),
            onPressed: () {
              final newZoom = (widget.state.zoomLevel - 0.1).clamp(0.25, 2.0);
              context.read<DocketDesignerBloc>().add(UpdateZoomEvent(newZoom));
            },
            tooltip: 'Zoom out',
          ),
          Text(
            '${(widget.state.zoomLevel * 100).toInt()}%',
            style: const TextStyle(fontSize: 12),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in, size: 20),
            onPressed: () {
              final newZoom = (widget.state.zoomLevel + 0.1).clamp(0.25, 2.0);
              context.read<DocketDesignerBloc>().add(UpdateZoomEvent(newZoom));
            },
            tooltip: 'Zoom in',
          ),
          const SizedBox(width: 16),
          // Design/Preview toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: widget.state.isPreviewMode
                  ? Colors.blue.shade50
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: widget.state.isPreviewMode
                      ? () {
                          context
                              .read<DocketDesignerBloc>()
                              .add(const TogglePreviewModeEvent());
                        }
                      : null,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Design',
                    style: TextStyle(
                      fontSize: 12,
                      color: !widget.state.isPreviewMode
                          ? Colors.blue
                          : Colors.grey.shade600,
                      fontWeight: !widget.state.isPreviewMode
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: !widget.state.isPreviewMode
                      ? () {
                          context
                              .read<DocketDesignerBloc>()
                              .add(const TogglePreviewModeEvent());
                        }
                      : null,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Preview',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.state.isPreviewMode
                          ? Colors.blue
                          : Colors.grey.shade600,
                      fontWeight: widget.state.isPreviewMode
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 0.5;

    const gridSize = 20.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ComponentWidget extends StatefulWidget {
  final DocketComponentModel component;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(double, double) onPositionChanged;
  final Function(double, double) onSizeChanged;
  final double canvasWidth;
  final double canvasHeight;

  const _ComponentWidget({
    required this.component,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onPositionChanged,
    required this.onSizeChanged,
    required this.canvasWidth,
    required this.canvasHeight,
  });

  @override
  State<_ComponentWidget> createState() => _ComponentWidgetState();
}

class _ComponentWidgetState extends State<_ComponentWidget> {
  double _getNumericValue(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed ?? defaultValue;
    }
    return defaultValue;
  }

  Color _getLineColor(dynamic colorValue) {
    if (colorValue == null) return Colors.black;
    if (colorValue is num) {
      return Color(colorValue.toInt());
    }
    if (colorValue is String) {
      final parsed = int.tryParse(colorValue);
      if (parsed != null) return Color(parsed);
      // Try hex color
      if (colorValue.startsWith('#')) {
        final hex = colorValue.substring(1);
        final parsed = int.tryParse(hex, radix: 16);
        if (parsed != null) return Color(0xFF000000 + parsed);
      }
    }
    return Colors.black;
  }

  Border? _getLineBorder(String? lineStyle, double thickness) {
    if (lineStyle == 'double') {
      return Border.symmetric(
        horizontal: BorderSide(
          color: Colors.black,
          width: thickness / 3,
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.component.x,
      top: widget.component.y,
      width: widget.component.width,
      height: widget.component.height,
      child: GestureDetector(
        onTap: widget.onTap,
        onPanStart: (details) {
          // Start dragging
        },
        onPanUpdate: (details) {
          final newX = (widget.component.x + details.delta.dx)
              .clamp(0.0, widget.canvasWidth - widget.component.width);
          final newY = (widget.component.y + details.delta.dy)
              .clamp(0.0, widget.canvasHeight - widget.component.height);

          widget.onPositionChanged(newX, newY);
        },
        onPanEnd: (details) {
          // Drag ended
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.isSelected ? Colors.blue : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              _buildComponentContent(),
              if (widget.isSelected) ..._buildResizeHandles(),
              if (widget.isSelected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Material(
                    color: Colors.red,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                    child: InkWell(
                      onTap: widget.onDelete,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildResizeHandles() {
    const handleSize = 8.0;
    const handleColor = Colors.blue;
    const handleBorderColor = Colors.white;

    return [
      // Top-left corner
      Positioned(
        left: -handleSize / 2,
        top: -handleSize / 2,
        child: GestureDetector(
          onPanUpdate: (details) {
            final newWidth = widget.component.width - details.delta.dx;
            final newHeight = widget.component.height - details.delta.dy;
            final newX = widget.component.x + details.delta.dx;
            final newY = widget.component.y + details.delta.dy;

            if (newWidth >= 50 && newX >= 0) {
              widget.onSizeChanged(newWidth, widget.component.height);
              widget.onPositionChanged(newX, widget.component.y);
            }
            if (newHeight >= 20 && newY >= 0) {
              widget.onSizeChanged(widget.component.width, newHeight);
              widget.onPositionChanged(widget.component.x, newY);
            }
          },
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              color: handleColor,
              border: Border.all(color: handleBorderColor, width: 1),
              borderRadius: BorderRadius.circular(handleSize / 2),
            ),
          ),
        ),
      ),
      // Top-right corner
      Positioned(
        right: -handleSize / 2,
        top: -handleSize / 2,
        child: GestureDetector(
          onPanUpdate: (details) {
            final newWidth = widget.component.width + details.delta.dx;
            final newHeight = widget.component.height - details.delta.dy;
            final newY = widget.component.y + details.delta.dy;

            if (newWidth >= 50 &&
                widget.component.x + newWidth <= widget.canvasWidth) {
              widget.onSizeChanged(newWidth, widget.component.height);
            }
            if (newHeight >= 20 && newY >= 0) {
              widget.onSizeChanged(widget.component.width, newHeight);
              widget.onPositionChanged(widget.component.x, newY);
            }
          },
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              color: handleColor,
              border: Border.all(color: handleBorderColor, width: 1),
              borderRadius: BorderRadius.circular(handleSize / 2),
            ),
          ),
        ),
      ),
      // Bottom-left corner
      Positioned(
        left: -handleSize / 2,
        bottom: -handleSize / 2,
        child: GestureDetector(
          onPanUpdate: (details) {
            final newWidth = widget.component.width - details.delta.dx;
            final newHeight = widget.component.height + details.delta.dy;
            final newX = widget.component.x + details.delta.dx;

            if (newWidth >= 50 && newX >= 0) {
              widget.onSizeChanged(newWidth, widget.component.height);
              widget.onPositionChanged(newX, widget.component.y);
            }
            if (newHeight >= 20 &&
                widget.component.y + newHeight <= widget.canvasHeight) {
              widget.onSizeChanged(widget.component.width, newHeight);
            }
          },
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              color: handleColor,
              border: Border.all(color: handleBorderColor, width: 1),
              borderRadius: BorderRadius.circular(handleSize / 2),
            ),
          ),
        ),
      ),
      // Bottom-right corner
      Positioned(
        right: -handleSize / 2,
        bottom: -handleSize / 2,
        child: GestureDetector(
          onPanUpdate: (details) {
            final newWidth = widget.component.width + details.delta.dx;
            final newHeight = widget.component.height + details.delta.dy;

            if (newWidth >= 50 &&
                widget.component.x + newWidth <= widget.canvasWidth) {
              widget.onSizeChanged(newWidth, widget.component.height);
            }
            if (newHeight >= 20 &&
                widget.component.y + newHeight <= widget.canvasHeight) {
              widget.onSizeChanged(widget.component.width, newHeight);
            }
          },
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              color: handleColor,
              border: Border.all(color: handleBorderColor, width: 1),
              borderRadius: BorderRadius.circular(handleSize / 2),
            ),
          ),
        ),
      ),
      // Top edge
      Positioned(
        left: widget.component.width / 2 - handleSize / 2,
        top: -handleSize / 2,
        child: GestureDetector(
          onPanUpdate: (details) {
            final newHeight = widget.component.height - details.delta.dy;
            final newY = widget.component.y + details.delta.dy;

            if (newHeight >= 20 && newY >= 0) {
              widget.onSizeChanged(widget.component.width, newHeight);
              widget.onPositionChanged(widget.component.x, newY);
            }
          },
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              color: handleColor,
              border: Border.all(color: handleBorderColor, width: 1),
              borderRadius: BorderRadius.circular(handleSize / 2),
            ),
          ),
        ),
      ),
      // Bottom edge
      Positioned(
        left: widget.component.width / 2 - handleSize / 2,
        bottom: -handleSize / 2,
        child: GestureDetector(
          onPanUpdate: (details) {
            final newHeight = widget.component.height + details.delta.dy;

            if (newHeight >= 20 &&
                widget.component.y + newHeight <= widget.canvasHeight) {
              widget.onSizeChanged(widget.component.width, newHeight);
            }
          },
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              color: handleColor,
              border: Border.all(color: handleBorderColor, width: 1),
              borderRadius: BorderRadius.circular(handleSize / 2),
            ),
          ),
        ),
      ),
      // Left edge
      Positioned(
        left: -handleSize / 2,
        top: widget.component.height / 2 - handleSize / 2,
        child: GestureDetector(
          onPanUpdate: (details) {
            final newWidth = widget.component.width - details.delta.dx;
            final newX = widget.component.x + details.delta.dx;

            if (newWidth >= 50 && newX >= 0) {
              widget.onSizeChanged(newWidth, widget.component.height);
              widget.onPositionChanged(newX, widget.component.y);
            }
          },
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              color: handleColor,
              border: Border.all(color: handleBorderColor, width: 1),
              borderRadius: BorderRadius.circular(handleSize / 2),
            ),
          ),
        ),
      ),
      // Right edge
      Positioned(
        right: -handleSize / 2,
        top: widget.component.height / 2 - handleSize / 2,
        child: GestureDetector(
          onPanUpdate: (details) {
            final newWidth = widget.component.width + details.delta.dx;

            if (newWidth >= 50 &&
                widget.component.x + newWidth <= widget.canvasWidth) {
              widget.onSizeChanged(newWidth, widget.component.height);
            }
          },
          child: Container(
            width: handleSize,
            height: handleSize,
            decoration: BoxDecoration(
              color: handleColor,
              border: Border.all(color: handleBorderColor, width: 1),
              borderRadius: BorderRadius.circular(handleSize / 2),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildComponentContent() {
    switch (widget.component.type) {
      case DocketComponentType.text:
        return Container(
          padding: const EdgeInsets.all(8),
          child: Text(
            widget.component.properties['content'] ?? 'Double click to edit',
            style: TextStyle(
              fontSize: (widget.component.properties['fontSize'] as num?)
                      ?.toDouble() ??
                  14,
              fontWeight: widget.component.properties['fontWeight'] == 'bold'
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        );
      case DocketComponentType.variable:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '{${widget.component.properties['variable'] ?? 'restaurant'}}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      case DocketComponentType.logo:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Icon(
            Icons.image,
            size: 32,
            color: Colors.grey,
          ),
        );
      case DocketComponentType.separator:
        final thickness =
            _getNumericValue(widget.component.properties['thickness'], 1.0);
        final lineStyle = widget.component.properties['lineStyle'] ?? 'solid';
        return Container(
          width: widget.component.width,
          height: widget.component.height,
          alignment: Alignment.center,
          child: Container(
            height: thickness,
            width: widget.component.width,
            decoration: BoxDecoration(
              color: _getLineColor(widget.component.properties['color']),
              border: _getLineBorder(lineStyle, thickness),
            ),
          ),
        );
      case DocketComponentType.box:
        return Container(
          padding: EdgeInsets.all(
            (widget.component.properties['padding'] as num?)?.toDouble() ?? 8,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: (widget.component.properties['borderWidth'] as num?)
                      ?.toDouble() ??
                  1,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text('Box'),
        );
      case DocketComponentType.columns:
        final columnCount =
            (widget.component.properties['columnCount'] as num?)?.toInt() ?? 2;
        final columnWidth = (widget.component.width / columnCount) - 16;

        return Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              columnCount,
              (index) => Expanded(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Column header
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text(
                            'Column ${index + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Nested components
                        ...widget.component.children
                            .where((child) =>
                                (child.properties['columnIndex'] as num?)
                                    ?.toInt() ==
                                index)
                            .map((child) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: _buildNestedComponent(child, columnWidth),
                          );
                        }),
                        // Empty state hint
                        if (widget.component.children
                            .where((child) =>
                                (child.properties['columnIndex'] as num?)
                                    ?.toInt() ==
                                index)
                            .isEmpty)
                          Container(
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: Text(
                                'Empty',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade400,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      case DocketComponentType.itemTable:
        return Container(
          padding: const EdgeInsets.all(8),
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            children: [
              const TableRow(
                children: [
                  TableCell(
                      child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('Item',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
                  TableCell(
                      child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('Qty',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
                  TableCell(
                      child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Text('Price',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  )),
                ],
              ),
            ],
          ),
        );
      case DocketComponentType.qrCode:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code, size: 48, color: Colors.grey),
              const SizedBox(height: 4),
              Text(
                'QR Code',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      case DocketComponentType.barcode:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_scanner, size: 32, color: Colors.grey),
              const SizedBox(height: 4),
              Text(
                'Barcode',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        );
      case DocketComponentType.space:
        return Container(
          color: Colors.grey.shade50,
          child: const Center(
            child: Icon(Icons.space_bar, size: 16, color: Colors.grey),
          ),
        );
      case DocketComponentType.customText:
        return Container(
          padding: const EdgeInsets.all(8),
          child: Text(
            widget.component.properties['content'] ?? 'Custom Text',
            style: TextStyle(
              fontSize: (widget.component.properties['fontSize'] as num?)
                      ?.toDouble() ??
                  14,
              fontWeight: widget.component.properties['fontWeight'] == 'bold'
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
    }
  }

  Widget _buildNestedComponent(
      DocketComponentModel component, double maxWidth) {
    switch (component.type) {
      case DocketComponentType.text:
        return Container(
          padding: const EdgeInsets.all(4),
          child: Text(
            component.properties['content'] ?? 'Text',
            style: TextStyle(
              fontSize:
                  (component.properties['fontSize'] as num?)?.toDouble() ?? 12,
              fontWeight: component.properties['fontWeight'] == 'bold'
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        );
      case DocketComponentType.variable:
        return Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '{${component.properties['variable'] ?? 'restaurant'}}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      default:
        return Container(
          padding: const EdgeInsets.all(4),
          child: Text(
            component.type.name,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        );
    }
  }
}
