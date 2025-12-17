import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Reusable gradient button with loading state
class GradientButton extends StatelessWidget {
  const GradientButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _GradientButtonCubit(),
      child: BlocBuilder<_GradientButtonCubit, bool>(
        builder: (context, working) {
          return SizedBox(
            height: 44,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: working ? null : () => _handlePressed(context),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: working
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handlePressed(BuildContext context) async {
    final cubit = context.read<_GradientButtonCubit>();
    cubit.setWorking(true);
    try {
      await onPressed();
    } finally {
      if (!cubit.isClosed) {
        cubit.setWorking(false);
      }
    }
  }
}

class _GradientButtonCubit extends Cubit<bool> {
  _GradientButtonCubit() : super(false);

  void setWorking(bool value) => emit(value);
}

