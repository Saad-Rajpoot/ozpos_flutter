import 'package:equatable/equatable.dart';

/// Events for Docket Designer
abstract class DocketDesignerEvent extends Equatable {
  const DocketDesignerEvent();

  @override
  List<Object?> get props => [];
}

/// Load template
class LoadTemplateEvent extends DocketDesignerEvent {
  final String? templateId;

  const LoadTemplateEvent({this.templateId});

  @override
  List<Object?> get props => [templateId];
}

/// Add component to canvas
class AddComponentEvent extends DocketDesignerEvent {
  final String componentType;
  final double? x;
  final double? y;

  const AddComponentEvent(this.componentType, {this.x, this.y});

  @override
  List<Object?> get props => [componentType, x, y];
}

/// Select component
class SelectComponentEvent extends DocketDesignerEvent {
  final String componentId;

  const SelectComponentEvent(this.componentId);

  @override
  List<Object?> get props => [componentId];
}

/// Update component properties
class UpdateComponentPropertiesEvent extends DocketDesignerEvent {
  final String componentId;
  final Map<String, dynamic> properties;

  const UpdateComponentPropertiesEvent(this.componentId, this.properties);

  @override
  List<Object?> get props => [componentId, properties];
}

/// Delete component
class DeleteComponentEvent extends DocketDesignerEvent {
  final String componentId;

  const DeleteComponentEvent(this.componentId);

  @override
  List<Object?> get props => [componentId];
}

/// Undo action
class UndoEvent extends DocketDesignerEvent {
  const UndoEvent();
}

/// Redo action
class RedoEvent extends DocketDesignerEvent {
  const RedoEvent();
}

/// Toggle preview mode
class TogglePreviewModeEvent extends DocketDesignerEvent {
  const TogglePreviewModeEvent();
}

/// Update template name
class UpdateTemplateNameEvent extends DocketDesignerEvent {
  final String name;

  const UpdateTemplateNameEvent(this.name);

  @override
  List<Object?> get props => [name];
}

/// Update template type
class UpdateTemplateTypeEvent extends DocketDesignerEvent {
  final String type;

  const UpdateTemplateTypeEvent(this.type);

  @override
  List<Object?> get props => [type];
}

/// Save template
class SaveTemplateEvent extends DocketDesignerEvent {
  const SaveTemplateEvent();
}

/// Clear selection
class ClearSelectionEvent extends DocketDesignerEvent {
  const ClearSelectionEvent();
}

/// Update zoom level
class UpdateZoomEvent extends DocketDesignerEvent {
  final double zoomLevel;

  const UpdateZoomEvent(this.zoomLevel);

  @override
  List<Object?> get props => [zoomLevel];
}

/// Update component position
class UpdateComponentPositionEvent extends DocketDesignerEvent {
  final String componentId;
  final double x;
  final double y;

  const UpdateComponentPositionEvent(this.componentId, this.x, this.y);

  @override
  List<Object?> get props => [componentId, x, y];
}

/// Update printer size
class UpdatePrinterSizeEvent extends DocketDesignerEvent {
  final String printerSize;

  const UpdatePrinterSizeEvent(this.printerSize);

  @override
  List<Object?> get props => [printerSize];
}

/// Add component to parent (for nested components in columns)
class AddChildComponentEvent extends DocketDesignerEvent {
  final String parentComponentId;
  final String componentType;
  final int? columnIndex;

  const AddChildComponentEvent(this.parentComponentId, this.componentType, {this.columnIndex});

  @override
  List<Object?> get props => [parentComponentId, componentType, columnIndex];
}

/// Update component size (width and height)
class UpdateComponentSizeEvent extends DocketDesignerEvent {
  final String componentId;
  final double width;
  final double height;

  const UpdateComponentSizeEvent(this.componentId, this.width, this.height);

  @override
  List<Object?> get props => [componentId, width, height];
}


