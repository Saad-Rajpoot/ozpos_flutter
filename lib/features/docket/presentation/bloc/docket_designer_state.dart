import 'package:equatable/equatable.dart';
import '../models/docket_component_model.dart';

/// States for Docket Designer
abstract class DocketDesignerState extends Equatable {
  const DocketDesignerState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DocketDesignerInitial extends DocketDesignerState {
  const DocketDesignerInitial();
}

/// Loading state
class DocketDesignerLoading extends DocketDesignerState {
  const DocketDesignerLoading();
}

/// Loaded state with template data
class DocketDesignerLoaded extends DocketDesignerState {
  final String templateId;
  final String templateName;
  final String templateType;
  final List<DocketComponentModel> components;
  final String? selectedComponentId;
  final bool isPreviewMode;
  final List<DocketDesignerState> historyStack;
  final int historyIndex;
  final double zoomLevel;
  final String printerSize;
  final int canvasWidth;
  final int canvasHeight;

  const DocketDesignerLoaded({
    required this.templateId,
    required this.templateName,
    required this.templateType,
    required this.components,
    this.selectedComponentId,
    this.isPreviewMode = false,
    this.historyStack = const [],
    this.historyIndex = -1,
    this.zoomLevel = 1.0,
    this.printerSize = '80mm Thermal',
    this.canvasWidth = 300,
    this.canvasHeight = 600,
  });

  DocketDesignerLoaded copyWith({
    String? templateId,
    String? templateName,
    String? templateType,
    List<DocketComponentModel>? components,
    String? selectedComponentId,
    bool? isPreviewMode,
    List<DocketDesignerState>? historyStack,
    int? historyIndex,
    double? zoomLevel,
    String? printerSize,
    int? canvasWidth,
    int? canvasHeight,
    bool clearSelection = false,
  }) {
    return DocketDesignerLoaded(
      templateId: templateId ?? this.templateId,
      templateName: templateName ?? this.templateName,
      templateType: templateType ?? this.templateType,
      components: components ?? this.components,
      selectedComponentId: clearSelection
          ? null
          : (selectedComponentId ?? this.selectedComponentId),
      isPreviewMode: isPreviewMode ?? this.isPreviewMode,
      historyStack: historyStack ?? this.historyStack,
      historyIndex: historyIndex ?? this.historyIndex,
      zoomLevel: zoomLevel ?? this.zoomLevel,
      printerSize: printerSize ?? this.printerSize,
      canvasWidth: canvasWidth ?? this.canvasWidth,
      canvasHeight: canvasHeight ?? this.canvasHeight,
    );
  }

  @override
  List<Object?> get props => [
        templateId,
        templateName,
        templateType,
        components,
        selectedComponentId,
        isPreviewMode,
        historyIndex,
        zoomLevel,
        printerSize,
        canvasWidth,
        canvasHeight,
      ];
}

/// Error state
class DocketDesignerError extends DocketDesignerState {
  final String message;

  const DocketDesignerError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Saving state
class DocketDesignerSaving extends DocketDesignerState {
  const DocketDesignerSaving();
}

/// Saved state
class DocketDesignerSaved extends DocketDesignerState {
  const DocketDesignerSaved();
}


