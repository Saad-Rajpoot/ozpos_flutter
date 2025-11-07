import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart' as di;
import '../bloc/combo_management_bloc.dart';
import '../bloc/combo_management_event.dart';
import '../../domain/entities/combo_entity.dart';
import 'combo_builder_modal.dart';
import 'debug/debug_combo_dialog.dart';
import 'debug/debug_combo_dialog_state.dart';

/// Debug button for opening combo builder with mock data
class DebugComboBuilderButton extends StatelessWidget {
  const DebugComboBuilderButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DebugComboButtonCubit(),
      child: const _DebugComboBuilderButtonView(),
    );
  }
}

class _DebugComboBuilderButtonView extends StatelessWidget {
  const _DebugComboBuilderButtonView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DebugComboButtonCubit, DebugComboButtonState>(
      builder: (context, state) {
        final gradientColors = state.isHovering
            ? const [Color(0xFF16A34A), Color(0xFF047857)]
            : const [Color(0xFF22C55E), Color(0xFF10B981)];

        return MouseRegion(
          onEnter: (_) =>
              context.read<DebugComboButtonCubit>().setHovering(true),
          onExit: (_) =>
              context.read<DebugComboButtonCubit>().setHovering(false),
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: state.isHovering
                    ? [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _showDebugDialog(context, state.savedCombo),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    '🔧 Debug Combo Builder',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDebugDialog(BuildContext rootContext, ComboEntity? savedCombo) {
    showDialog<void>(
      context: rootContext,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) {
        return ComboBuilderDebugDialog(
          rootContext: rootContext,
          initialSavedCombo: savedCombo,
          onSavedCombo: (combo) {
            rootContext.read<DebugComboButtonCubit>().updateSavedCombo(combo);
          },
          onOpenBuilder: () => _openComboBuilder(rootContext),
        );
      },
    );
  }

  Future<void> _openComboBuilder(BuildContext rootContext) async {
    // Try to get ComboManagementBloc from context, fall back to DI
    ComboManagementBloc? comboBloc;
    try {
      comboBloc = rootContext.read<ComboManagementBloc>();
    } catch (e) {
      // If not in context, get from DI
      try {
        comboBloc = di.GetIt.instance<ComboManagementBloc>();
      } catch (e) {
        // If not available, show error or create a new instance
        if (rootContext.mounted) {
          ScaffoldMessenger.of(rootContext).showSnackBar(
            const SnackBar(
              content: Text('Combo builder is not available in this context'),
            ),
          );
        }
        return;
      }
    }

    comboBloc.add(const StartComboEdit());

    await showDialog<void>(
      context: rootContext,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider<ComboManagementBloc>.value(
        value: comboBloc!,
        child: const ComboBuilderModal(),
      ),
    );
  }
}
