import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/docket_designer_bloc.dart';
import '../bloc/docket_designer_event.dart';
import '../bloc/docket_designer_state.dart';
import 'docket_designer_components_panel.dart';
import 'docket_designer_canvas.dart';
import 'docket_designer_properties_panel.dart';

class DocketDesignerScreen extends StatelessWidget {
  const DocketDesignerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = DocketDesignerBloc();
        bloc.add(const LoadTemplateEvent());
        return bloc;
      },
      child: const DocketDesignerView(),
    );
  }
}

class DocketDesignerView extends StatelessWidget {
  const DocketDesignerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: BlocBuilder<DocketDesignerBloc, DocketDesignerState>(
        builder: (context, state) {
          if (state is DocketDesignerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DocketDesignerError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<DocketDesignerBloc>()
                          .add(const LoadTemplateEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DocketDesignerLoaded ||
              state is DocketDesignerSaving ||
              state is DocketDesignerSaved) {
            final loadedState = state is DocketDesignerLoaded
                ? state
                : const DocketDesignerLoaded(
                    templateId: '',
                    templateName: 'Untitled Template',
                    templateType: 'POS Receipt',
                    components: [],
                    zoomLevel: 1.0,
                    printerSize: '80mm Thermal',
                    canvasWidth: 300,
                    canvasHeight: 600,
                  );

            return Column(
              children: [
                _buildHeader(context, loadedState),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Row(
                        children: [
                          // Left sidebar - Components panel
                          SizedBox(
                            width: 280,
                            child: DocketDesignerComponentsPanel(
                              width: 280,
                              onComponentSelected: (componentType) {
                                context
                                    .read<DocketDesignerBloc>()
                                    .add(AddComponentEvent(componentType));
                              },
                            ),
                          ),
                          // Center - Canvas
                          Expanded(
                            child: DocketDesignerCanvas(
                              state: loadedState,
                            ),
                          ),
                          // Right sidebar - Properties panel
                          SizedBox(
                            width: 280,
                            child: DocketDesignerPropertiesPanel(
                              width: 280,
                              state: loadedState,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    DocketDesignerLoaded state,
  ) {
    return Container(
      height: 64,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back',
          ),
          const SizedBox(width: 16),
          // Template name (editable)
          Expanded(
            child: TextField(
              controller: TextEditingController(text: state.templateName),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                context
                    .read<DocketDesignerBloc>()
                    .add(UpdateTemplateNameEvent(value));
              },
            ),
          ),
          const SizedBox(width: 16),
          // Template type dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: state.templateType.isEmpty
                  ? 'POS Receipt'
                  : (['POS Receipt', 'Kitchen Docket', 'Invoice']
                          .contains(state.templateType)
                      ? state.templateType
                      : 'POS Receipt'),
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(
                    value: 'POS Receipt', child: Text('POS Receipt')),
                DropdownMenuItem(
                    value: 'Kitchen Docket', child: Text('Kitchen Docket')),
                DropdownMenuItem(value: 'Invoice', child: Text('Invoice')),
              ],
              onChanged: (value) {
                if (value != null) {
                  context
                      .read<DocketDesignerBloc>()
                      .add(UpdateTemplateTypeEvent(value));
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          // Action buttons
          BlocBuilder<DocketDesignerBloc, DocketDesignerState>(
            builder: (context, blocState) {
              final canUndo = blocState is DocketDesignerLoaded &&
                  blocState.historyStack.isNotEmpty &&
                  blocState.historyIndex > 0;
              final canRedo = blocState is DocketDesignerLoaded &&
                  blocState.historyStack.isNotEmpty &&
                  blocState.historyIndex < blocState.historyStack.length - 1;

              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.undo),
                    onPressed: canUndo
                        ? () {
                            context
                                .read<DocketDesignerBloc>()
                                .add(const UndoEvent());
                          }
                        : null,
                    tooltip: 'Undo',
                    color: canUndo ? null : Colors.grey,
                  ),
                  IconButton(
                    icon: const Icon(Icons.redo),
                    onPressed: canRedo
                        ? () {
                            context
                                .read<DocketDesignerBloc>()
                                .add(const RedoEvent());
                          }
                        : null,
                    tooltip: 'Redo',
                    color: canRedo ? null : Colors.grey,
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.preview, size: 18),
            label: const Text('Preview'),
            onPressed: () {
              context
                  .read<DocketDesignerBloc>()
                  .add(const TogglePreviewModeEvent());
            },
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.print, size: 18),
            label: const Text('Test Print'),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Test print functionality coming soon')),
              );
            },
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Save Template'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onPressed: () {
              context.read<DocketDesignerBloc>().add(const SaveTemplateEvent());
            },
          ),
        ],
      ),
    );
  }
}
