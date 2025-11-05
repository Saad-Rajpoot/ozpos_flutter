import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/base/base_bloc.dart';
import 'docket_designer_event.dart';
import 'docket_designer_state.dart';
import '../models/docket_component_model.dart';

class DocketDesignerBloc
    extends BaseBloc<DocketDesignerEvent, DocketDesignerState> {
  final Uuid _uuid = const Uuid();

  DocketDesignerBloc()
      : super(const DocketDesignerLoaded(
          templateId: '',
          templateName: 'Untitled Template',
          templateType: 'POS Receipt',
          components: [],
          zoomLevel: 1.0,
          printerSize: '80mm Thermal',
          canvasWidth: 300,
          canvasHeight: 600,
        )) {
    on<LoadTemplateEvent>(_onLoadTemplate);
    on<AddComponentEvent>(_onAddComponent);
    on<SelectComponentEvent>(_onSelectComponent);
    on<UpdateComponentPropertiesEvent>(_onUpdateComponentProperties);
    on<DeleteComponentEvent>(_onDeleteComponent);
    on<UndoEvent>(_onUndo);
    on<RedoEvent>(_onRedo);
    on<TogglePreviewModeEvent>(_onTogglePreviewMode);
    on<UpdateTemplateNameEvent>(_onUpdateTemplateName);
    on<UpdateTemplateTypeEvent>(_onUpdateTemplateType);
    on<SaveTemplateEvent>(_onSaveTemplate);
    on<ClearSelectionEvent>(_onClearSelection);
    on<UpdateZoomEvent>(_onUpdateZoom);
    on<UpdateComponentPositionEvent>(_onUpdateComponentPosition);
    on<UpdatePrinterSizeEvent>(_onUpdatePrinterSize);
    on<AddChildComponentEvent>(_onAddChildComponent);
    on<UpdateComponentSizeEvent>(_onUpdateComponentSize);
  }

  void _onLoadTemplate(
    LoadTemplateEvent event,
    Emitter<DocketDesignerState> emit,
  ) {
    emit(const DocketDesignerLoading());

    // For now, load empty template
    emit(const DocketDesignerLoaded(
      templateId: '',
      templateName: 'Untitled Template',
      templateType: 'POS Receipt',
      components: [],
      zoomLevel: 1.0,
      printerSize: '80mm Thermal',
      canvasWidth: 300,
      canvasHeight: 600,
    ));
  }

  void _onAddComponent(
    AddComponentEvent event,
    Emitter<DocketDesignerState> emit,
  ) {
    if (state is! DocketDesignerLoaded) return;

    final currentState = state as DocketDesignerLoaded;
    final componentType = _getComponentType(event.componentType);

    // Calculate position for new component (use provided position or stack vertically)
    final x = event.x ?? 0.0;
    final y = event.y ??
        (currentState.components.isEmpty
            ? 10.0
            : currentState.components.map((c) => c.y + c.height).reduce(
                      (a, b) => a > b ? a : b,
                    ) +
                10);

    final defaultHeight = _getDefaultHeight(componentType);
    final newComponent = DocketComponentModel(
      id: _uuid.v4(),
      type: componentType,
      properties: _getDefaultProperties(componentType),
      x: x.clamp(0.0, currentState.canvasWidth.toDouble()),
      y: y.clamp(0.0, currentState.canvasHeight.toDouble()),
      width: currentState.canvasWidth.toDouble(),
      height: defaultHeight,
    );

    final updatedComponents = [...currentState.components, newComponent];

    // Save to history BEFORE making changes
    final history = _prepareHistory(currentState);

    final newState = currentState.copyWith(
      components: updatedComponents,
      selectedComponentId: newComponent.id,
      historyStack: history['stack'] as List<DocketDesignerState>,
      historyIndex: history['index'] as int,
    );

    emit(newState);
  }

  void _onSelectComponent(
    SelectComponentEvent event,
    Emitter<DocketDesignerState> emit,
  ) {
    if (state is! DocketDesignerLoaded) return;

    final currentState = state as DocketDesignerLoaded;

    emit(currentState.copyWith(
      selectedComponentId: event.componentId,
    ));
  }

  void _onUpdateComponentProperties(
    UpdateComponentPropertiesEvent event,
    Emitter<DocketDesignerState> emit,
  ) {
    if (state is! DocketDesignerLoaded) return;

    final currentState = state as DocketDesignerLoaded;

    final componentIndex =
        currentState.components.indexWhere((c) => c.id == event.componentId);

    if (componentIndex == -1) return;

    final component = currentState.components[componentIndex];
    final updatedProperties = {
      ...component.properties,
      ...event.properties,
    };
    // Remove the drag marker
    updatedProperties.remove('_isDragUpdate');

    final updatedComponent = component.copyWith(properties: updatedProperties);
    final updatedComponents = List<DocketComponentModel>.from(
      currentState.components,
    );
    updatedComponents[componentIndex] = updatedComponent;

    // Save to history only for significant changes (not during drag)
    Map<String, dynamic> history = {
      'stack': currentState.historyStack,
      'index': currentState.historyIndex
    };
    if (!event.properties.containsKey('_isDragUpdate')) {
      history = _prepareHistory(currentState);
    }

    final newState = currentState.copyWith(
      components: updatedComponents,
      historyStack: history['stack'] as List<DocketDesignerState>,
      historyIndex: history['index'] as int,
    );

    emit(newState);
  }

  void _onDeleteComponent(
    DeleteComponentEvent event,
    Emitter<DocketDesignerState> emit,
  ) {
    if (state is! DocketDesignerLoaded) return;

    final currentState = state as DocketDesignerLoaded;

    final updatedComponents = currentState.components
        .where((c) => c.id != event.componentId)
        .toList();

    // Save to history BEFORE making changes
    final history = _prepareHistory(currentState);

    final newState = currentState.copyWith(
      components: updatedComponents,
      selectedComponentId: currentState.selectedComponentId == event.componentId
          ? null
          : currentState.selectedComponentId,
      clearSelection: currentState.selectedComponentId == event.componentId,
      historyStack: history['stack'] as List<DocketDesignerState>,
      historyIndex: history['index'] as int,
    );

    emit(newState);
  }

  void _onUndo(UndoEvent event, Emitter<DocketDesignerState> emit) {
    if (state is! DocketDesignerLoaded) return;

    final currentState = state as DocketDesignerLoaded;
    if (currentState.historyStack.isNotEmpty &&
        currentState.historyIndex >= 0) {
      if (currentState.historyIndex > 0) {
        final newIndex = currentState.historyIndex - 1;
        final previousState = currentState.historyStack[newIndex];
        if (previousState is DocketDesignerLoaded) {
          // Create a new state from history but preserve current history stack
          emit(DocketDesignerLoaded(
            templateId: previousState.templateId,
            templateName: previousState.templateName,
            templateType: previousState.templateType,
            components: previousState.components,
            selectedComponentId: previousState.selectedComponentId,
            isPreviewMode: previousState.isPreviewMode,
            historyStack: currentState.historyStack,
            historyIndex: newIndex,
            zoomLevel: previousState.zoomLevel,
            printerSize: previousState.printerSize,
            canvasWidth: previousState.canvasWidth,
            canvasHeight: previousState.canvasHeight,
          ));
        }
      }
    }
  }

  void _onRedo(RedoEvent event, Emitter<DocketDesignerState> emit) {
    if (state is! DocketDesignerLoaded) return;

    final currentState = state as DocketDesignerLoaded;
    if (currentState.historyStack.isNotEmpty &&
        currentState.historyIndex < currentState.historyStack.length - 1) {
      final newIndex = currentState.historyIndex + 1;
      final nextState = currentState.historyStack[newIndex];
      if (nextState is DocketDesignerLoaded) {
        // Create a new state from history but preserve current history stack
        emit(DocketDesignerLoaded(
          templateId: nextState.templateId,
          templateName: nextState.templateName,
          templateType: nextState.templateType,
          components: nextState.components,
          selectedComponentId: nextState.selectedComponentId,
          isPreviewMode: nextState.isPreviewMode,
          historyStack: currentState.historyStack,
          historyIndex: newIndex,
          zoomLevel: nextState.zoomLevel,
          printerSize: nextState.printerSize,
          canvasWidth: nextState.canvasWidth,
          canvasHeight: nextState.canvasHeight,
        ));
      }
    }
  }

  void _onTogglePreviewMode(
    TogglePreviewModeEvent event,
    Emitter<DocketDesignerState> emit,
  ) {
    if (state is! DocketDesignerLoaded) return;

    final currentState = state as DocketDesignerLoaded;
    emit(currentState.copyWith(
      isPreviewMode: !currentState.isPreviewMode,
    ));
  }

  void _onUpdateTemplateName(
    UpdateTemplateNameEvent event,
    Emitter<DocketDesignerState> emit,
  ) {
    if (state is! DocketDesignerLoaded) return;

    final currentState = state as DocketDesignerLoaded;
    emit(currentState.copyWith(templateName: event.name));
  }

  void _onUpdateTemplateType(
    UpdateTemplateTypeEvent event,
    Emitter<DocketDesignerState> emit,
  ) {
    if (state is! DocketDesignerLoaded) return;

    final currentState = state as DocketDesignerLoaded;
    emit(currentState.copyWith(templateType: event.type));
  }

  void _onSaveTemplate(
    SaveTemplateEvent event,
    Emitter<DocketDesignerState> emit,
  ) {
    emit(const DocketDesignerSaving());

    // For now, just show saved state
    Future.delayed(const Duration(milliseconds: 500), () {
      emit(const DocketDesignerSaved());
      // Return to loaded state after showing saved message
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (state is DocketDesignerSaved) {
          if (state is DocketDesignerLoaded) {
            // Keep current state
          }
        }
      });
    });
  }

  void _onClearSelection(
    ClearSelectionEvent event,
    Emitter<DocketDesignerState> emit,
  ) {
    if (state is! DocketDesignerLoaded) return;

    final currentState = state as DocketDesignerLoaded;
    emit(currentState.copyWith(clearSelection: true));
  }

  void _onUpdateZoom(
    UpdateZoomEvent event,
    Emitter<DocketDesignerState> emit,
  ) {
    if (state is! DocketDesignerLoaded) return;

    final currentState = state as DocketDesignerLoaded;
    // Clamp zoom between 0.25 and 2.0
    final clampedZoom = event.zoomLevel.clamp(0.25, 2.0);
    emit(currentState.copyWith(zoomLevel: clampedZoom));
  }

  void _onUpdateComponentPosition(
    UpdateComponentPositionEvent event,
    Emitter<DocketDesignerState> emit,
  ) {
    if (state is! DocketDesignerLoaded) return;

    final currentState = state as DocketDesignerLoaded;
    final componentIndex =
        currentState.components.indexWhere((c) => c.id == event.componentId);

    if (componentIndex == -1) return;

    final component = currentState.components[componentIndex];
    final updatedComponent = component.copyWith(
      x: event.x.clamp(0.0, currentState.canvasWidth - component.width),
      y: event.y.clamp(0.0, currentState.canvasHeight - component.height),
    );

    final updatedComponents = List<DocketComponentModel>.from(
      currentState.components,
    );
    updatedComponents[componentIndex] = updatedComponent;

    final history = _prepareHistory(currentState);

    emit(currentState.copyWith(
      components: updatedComponents,
      historyStack: history['stack'] as List<DocketDesignerState>,
      historyIndex: history['index'] as int,
    ));
  }

  void _onUpdateComponentSize(
    UpdateComponentSizeEvent event,
    Emitter<DocketDesignerState> emit,
  ) {
    if (state is! DocketDesignerLoaded) return;

    final currentState = state as DocketDesignerLoaded;
    final componentIndex =
        currentState.components.indexWhere((c) => c.id == event.componentId);

    if (componentIndex == -1) return;

    final component = currentState.components[componentIndex];
    // Ensure size is within canvas bounds and minimum size
    final minWidth = 50.0;
    final minHeight = 20.0;
    final newWidth = event.width.clamp(
      minWidth,
      currentState.canvasWidth - component.x,
    );
    final newHeight = event.height.clamp(
      minHeight,
      currentState.canvasHeight - component.y,
    );

    final updatedComponent = component.copyWith(
      width: newWidth,
      height: newHeight,
    );

    final updatedComponents = List<DocketComponentModel>.from(
      currentState.components,
    );
    updatedComponents[componentIndex] = updatedComponent;

    final history = _prepareHistory(currentState);

    emit(currentState.copyWith(
      components: updatedComponents,
      historyStack: history['stack'] as List<DocketDesignerState>,
      historyIndex: history['index'] as int,
    ));
  }

  void _onUpdatePrinterSize(
    UpdatePrinterSizeEvent event,
    Emitter<DocketDesignerState> emit,
  ) {
    if (state is! DocketDesignerLoaded) return;

    final currentState = state as DocketDesignerLoaded;
    final printerConfig = _getPrinterConfig(event.printerSize);

    emit(currentState.copyWith(
      printerSize: event.printerSize,
      canvasWidth: printerConfig['width'] as int,
      canvasHeight: printerConfig['height'] as int,
    ));
  }

  Map<String, dynamic> _prepareHistory(DocketDesignerLoaded state) {
    // Create a deep copy of current state for history (deep copy components and children)
    final componentsCopy = state.components.map((comp) {
      return DocketComponentModel(
        id: comp.id,
        type: comp.type,
        properties: Map<String, dynamic>.from(comp.properties),
        x: comp.x,
        y: comp.y,
        width: comp.width,
        height: comp.height,
        children: comp.children.map((child) {
          return DocketComponentModel(
            id: child.id,
            type: child.type,
            properties: Map<String, dynamic>.from(child.properties),
            x: child.x,
            y: child.y,
            width: child.width,
            height: child.height,
            children: const [], // Don't nest deeper than one level
          );
        }).toList(),
      );
    }).toList();

    final stateCopy = DocketDesignerLoaded(
      templateId: state.templateId,
      templateName: state.templateName,
      templateType: state.templateType,
      components: componentsCopy,
      selectedComponentId: state.selectedComponentId,
      isPreviewMode: state.isPreviewMode,
      historyStack: const [],
      historyIndex: -1,
      zoomLevel: state.zoomLevel,
      printerSize: state.printerSize,
      canvasWidth: state.canvasWidth,
      canvasHeight: state.canvasHeight,
    );

    // Limit history to 50 entries
    final history = List<DocketDesignerState>.from(state.historyStack);

    // Remove future history when new action is done
    if (state.historyIndex >= 0 && state.historyIndex < history.length - 1) {
      history.removeRange(state.historyIndex + 1, history.length);
    }

    // Add current state to history (but don't include history in the copy)
    history.add(stateCopy);

    // Limit history size
    if (history.length > 50) {
      history.removeAt(0);
    }

    return {
      'stack': history,
      'index': history.length - 1,
    };
  }

  void _onAddChildComponent(
    AddChildComponentEvent event,
    Emitter<DocketDesignerState> emit,
  ) {
    if (state is! DocketDesignerLoaded) return;

    final currentState = state as DocketDesignerLoaded;
    final componentType = _getComponentType(event.componentType);

    // Find parent component (should be columns)
    final parentIndex = currentState.components
        .indexWhere((c) => c.id == event.parentComponentId);

    if (parentIndex == -1) return;

    final parentComponent = currentState.components[parentIndex];

    // Save to history BEFORE making changes
    final history = _prepareHistory(currentState);

    // Calculate column width
    final columnCount =
        (parentComponent.properties['columnCount'] as num?)?.toInt() ?? 2;
    final columnWidth =
        (parentComponent.width / columnCount) - 16; // 16 for padding

    // Create new child component
    final childProps = _getDefaultProperties(componentType);
    childProps['columnIndex'] = event.columnIndex ?? 0;

    final newChild = DocketComponentModel(
      id: _uuid.v4(),
      type: componentType,
      properties: childProps,
      x: 0,
      y: 0,
      width: columnWidth,
      height: _getDefaultHeight(componentType),
    );

    // Add to parent's children
    final updatedChildren = [...parentComponent.children, newChild];
    final updatedParent = parentComponent.copyWith(children: updatedChildren);

    // Update components list
    final updatedComponents = List<DocketComponentModel>.from(
      currentState.components,
    );
    updatedComponents[parentIndex] = updatedParent;

    emit(currentState.copyWith(
      components: updatedComponents,
      selectedComponentId: newChild.id,
      historyStack: history['stack'] as List<DocketDesignerState>,
      historyIndex: history['index'] as int,
    ));
  }

  Map<String, dynamic> _getPrinterConfig(String printerSize) {
    switch (printerSize) {
      case '58mm Thermal':
        return {'width': 220, 'height': 400};
      case '80mm Thermal':
        return {'width': 300, 'height': 600};
      case 'A4':
        return {'width': 595, 'height': 842};
      case 'A5':
        return {'width': 420, 'height': 595};
      case 'Letter':
        return {'width': 612, 'height': 792};
      default:
        return {'width': 300, 'height': 600};
    }
  }

  // Helper methods
  DocketComponentType _getComponentType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'text':
        return DocketComponentType.text;
      case 'variable':
        return DocketComponentType.variable;
      case 'logo':
      case 'image':
        return DocketComponentType.logo;
      case 'separator':
      case 'line':
        return DocketComponentType.separator;
      case 'box':
        return DocketComponentType.box;
      case 'columns':
        return DocketComponentType.columns;
      case 'itemtable':
      case 'item_table':
        return DocketComponentType.itemTable;
      case 'qrcode':
      case 'qr_code':
        return DocketComponentType.qrCode;
      case 'barcode':
        return DocketComponentType.barcode;
      case 'space':
        return DocketComponentType.space;
      case 'customtext':
      case 'custom_text':
        return DocketComponentType.customText;
      default:
        return DocketComponentType.text;
    }
  }

  Map<String, dynamic> _getDefaultProperties(DocketComponentType type) {
    switch (type) {
      case DocketComponentType.text:
        return {
          'content': 'Double click to edit',
          'fontSize': 14,
          'fontWeight': 'normal',
          'textAlign': 'left',
        };
      case DocketComponentType.variable:
        return {
          'variable': 'restaurant',
        };
      case DocketComponentType.logo:
        return {
          'imageUrl': '',
          'height': 60,
        };
      case DocketComponentType.separator:
        return {
          'thickness': 1,
          'color': '#E5E7EB',
        };
      case DocketComponentType.box:
        return {
          'borderWidth': 1,
          'borderColor': '#000000',
          'padding': 8,
        };
      case DocketComponentType.columns:
        return {
          'columnCount': 2,
          'columnWidths': [150, 150],
        };
      case DocketComponentType.itemTable:
        return {
          'showHeaders': true,
          'columns': ['Item', 'Qty', 'Price'],
        };
      case DocketComponentType.qrCode:
        return {
          'data': 'https://example.com',
          'size': 100,
        };
      case DocketComponentType.barcode:
        return {
          'data': '1234567890123',
          'format': 'CODE128',
          'height': 50,
        };
      case DocketComponentType.space:
        return {
          'height': 20,
        };
      case DocketComponentType.customText:
        return {
          'content': 'Custom Text',
          'fontSize': 14,
          'fontWeight': 'normal',
          'textAlign': 'left',
        };
    }
  }

  double _getDefaultHeight(DocketComponentType type) {
    switch (type) {
      case DocketComponentType.text:
        return 30;
      case DocketComponentType.variable:
        return 30;
      case DocketComponentType.logo:
        return 60;
      case DocketComponentType.separator:
        return 2;
      case DocketComponentType.box:
        return 50;
      case DocketComponentType.columns:
        return 50;
      case DocketComponentType.itemTable:
        return 100;
      case DocketComponentType.qrCode:
        return 100;
      case DocketComponentType.barcode:
        return 60;
      case DocketComponentType.space:
        return 20;
      case DocketComponentType.customText:
        return 30;
    }
  }
}
