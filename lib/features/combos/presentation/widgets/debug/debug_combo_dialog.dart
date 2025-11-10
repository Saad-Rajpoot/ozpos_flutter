import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart' as di;
import '../../bloc/crud/combo_crud_bloc.dart';
import '../../bloc/crud/combo_crud_state.dart';
import '../../../domain/entities/combo_entity.dart';
import 'debug_combo_dialog_state.dart';
import 'debug_combo_dialog_content.dart';
import 'saved_combo_viewer.dart';
import 'debug_combo_utils.dart';

/// Debug dialog for combo builder
class ComboBuilderDebugDialog extends StatelessWidget {
  const ComboBuilderDebugDialog({
    required this.rootContext,
    required this.initialSavedCombo,
    required this.onSavedCombo,
    required this.onOpenBuilder,
    super.key,
  });

  final BuildContext rootContext;
  final ComboEntity? initialSavedCombo;
  final ValueChanged<ComboEntity?> onSavedCombo;
  final Future<void> Function() onOpenBuilder;

  @override
  Widget build(BuildContext context) {
    // Try to get ComboCrudBloc from rootContext if available
    final comboBloc = _getCrudBlocIfAvailable(rootContext);

    return BlocProvider(
      create: (_) => DebugDialogCubit(initialSavedCombo),
      child: comboBloc != null
          ? BlocProvider<ComboCrudBloc>.value(
              value: comboBloc,
              child: _ComboBuilderDebugDialogBody(
                rootContext: rootContext,
                onSavedCombo: onSavedCombo,
                onOpenBuilder: onOpenBuilder,
                hasComboBloc: true,
              ),
            )
          : _ComboBuilderDebugDialogBody(
              rootContext: rootContext,
              onSavedCombo: onSavedCombo,
              onOpenBuilder: onOpenBuilder,
              hasComboBloc: false,
            ),
    );
  }

  /// Safely get ComboCrudBloc if available in context
  /// Falls back to creating a new instance from DI if not in context
  ComboCrudBloc? _getCrudBlocIfAvailable(BuildContext context) {
    try {
      // Try to read from context first
      return context.read<ComboCrudBloc>();
    } catch (e) {
      // If not in context, try to get from DI
      try {
        return di.GetIt.instance<ComboCrudBloc>();
      } catch (e) {
        // If not available in DI either, return null
        // The dialog will work without the listener
        return null;
      }
    }
  }
}

class _ComboBuilderDebugDialogBody extends StatelessWidget {
  const _ComboBuilderDebugDialogBody({
    required this.rootContext,
    required this.onSavedCombo,
    required this.onOpenBuilder,
    required this.hasComboBloc,
  });

  final BuildContext rootContext;
  final ValueChanged<ComboEntity?> onSavedCombo;
  final Future<void> Function() onOpenBuilder;
  final bool hasComboBloc;

  @override
  Widget build(BuildContext context) {
    // If ComboCrudBloc is available, listen to it
    // Otherwise, just build the dialog without the listener
    Widget content = BlocBuilder<DebugDialogCubit, DebugDialogState>(
      builder: (context, dialogState) {
        final savedCombo = dialogState.savedCombo;

        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          backgroundColor: Colors.transparent,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const DebugComboDialogHeader(),
                        const SizedBox(height: 24),
                        const DebugComboCategoriesSection(),
                        const SizedBox(height: 24),
                        const DebugComboItemsSection(),
                        const SizedBox(height: 24),
                        DebugComboDialogActions(
                          onOpenBuilder: _handleOpenComboBuilder,
                          onViewSavedCombo: savedCombo != null
                              ? () => _handleViewSavedCombo(savedCombo)
                              : () {},
                          savedCombo: savedCombo,
                        ),
                        if (savedCombo != null) ...[
                          const SizedBox(height: 24),
                          SavedComboViewer(combo: savedCombo),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    // Wrap with BlocListener only if ComboCrudBloc is available
    if (hasComboBloc) {
      content = BlocListener<ComboCrudBloc, ComboCrudState>(
        listenWhen: (previous, current) =>
            previous.lastSavedCombo != current.lastSavedCombo,
        listener: (context, state) {
          final combo = state.lastSavedCombo;
          if (combo != null) {
            context.read<DebugDialogCubit>().updateSavedCombo(combo);
            onSavedCombo(combo);
            _showSaveSnackBar();
          }
        },
        child: content,
      );
    }

    return content;
  }

  Future<void> _handleOpenComboBuilder() async {
    final navigator = Navigator.of(rootContext, rootNavigator: true);
    navigator.pop();
    await Future.microtask(() {});
    await onOpenBuilder();
  }

  Future<void> _handleViewSavedCombo(ComboEntity savedCombo) async {
    debugPrint('Saved combo snapshot:');
    debugPrint(DebugComboUtils.comboToJsonString(savedCombo));

    final messenger = ScaffoldMessenger.maybeOf(rootContext);
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Saved combo details logged to console'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSaveSnackBar() {
    final messenger = ScaffoldMessenger.maybeOf(rootContext);
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Combo saved. Summary updated in debug tool.'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
