import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart' as di;
import '../../domain/entities/customer_display_entity.dart';
import '../../domain/entities/customer_display_mode.dart';
import '../bloc/customer_display_bloc.dart';
import '../bloc/customer_display_event.dart';
import '../bloc/customer_display_state.dart';
import '../widgets/customer_display_approved_view.dart';
import '../widgets/customer_display_change_due_view.dart';
import '../widgets/customer_display_idle_view.dart';
import '../widgets/customer_display_order_layout.dart'
    show CustomerDisplayOrderLayout, CustomerDisplayOrderSummary,
        CustomerDisplayPaymentPanel;
import '../widgets/customer_display_payment_declined_view.dart';

/// Demo/mock customer display shown when the user taps "Customer Display" on the dashboard.
/// Loads content from the mock data source and cycles through modes (idle, order, payment, etc.).
class CustomerDisplayDemoScreen extends StatelessWidget {
  const CustomerDisplayDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CustomerDisplayBloc>(
      create: (_) =>
          di.sl<CustomerDisplayBloc>()..add(const CustomerDisplayOpened()),
      child: const _CustomerDisplayDemoView(),
    );
  }
}

class _CustomerDisplayDemoView extends StatelessWidget {
  const _CustomerDisplayDemoView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          BlocBuilder<CustomerDisplayBloc, CustomerDisplayState>(
            builder: (context, state) {
              if (state.status == CustomerDisplayStatus.loading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (state.status == CustomerDisplayStatus.error) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.errorMessage ?? 'Failed to load demo',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton.icon(
                          onPressed: () => context
                              .read<CustomerDisplayBloc>()
                              .add(const CustomerDisplayRetryRequested()),
                          icon: const Icon(Icons.refresh, color: Colors.white),
                          label: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (state.status != CustomerDisplayStatus.ready ||
                  state.content == null) {
                return const SizedBox.shrink();
              }
              return _buildFromMode(
                context,
                state.currentMode,
                state.content!,
                state,
              );
            },
          ),
          // Overlay: Close and Next (demo step) buttons
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                    tooltip: 'Close demo',
                  ),
                  BlocBuilder<CustomerDisplayBloc, CustomerDisplayState>(
                    buildWhen: (a, b) =>
                        a.currentModeIndex != b.currentModeIndex ||
                        a.content != b.content,
                    builder: (context, state) {
                      if (state.content == null ||
                          state.content!.demoSequence.length <= 1) {
                        return const SizedBox.shrink();
                      }
                      return TextButton.icon(
                        onPressed: () => context.read<CustomerDisplayBloc>().add(
                              const CustomerDisplayModeAdvanced(),
                            ),
                        icon: const Icon(
                          Icons.skip_next,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          'Next step',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFromMode(
    BuildContext context,
    CustomerDisplayMode mode,
    CustomerDisplayEntity content,
    CustomerDisplayState state,
  ) {
    switch (mode) {
      case CustomerDisplayMode.idle:
        final slides = content.promoSlides;
        final index = state.currentSlideIndex % (slides.isEmpty ? 1 : slides.length);
        return CustomerDisplayIdleView(
          slide: slides.isEmpty ? null : slides[index],
          totalSlides: slides.isEmpty ? 1 : slides.length,
          activeIndex: index,
        );
      case CustomerDisplayMode.order:
        return CustomerDisplayOrderLayout(
          content: content,
          rightPanel: CustomerDisplayOrderSummary(content: content),
        );
      case CustomerDisplayMode.paymentCard:
        return CustomerDisplayOrderLayout(
          content: content,
          rightPanel: CustomerDisplayPaymentPanel(
            content: content,
            mode: CustomerDisplayMode.paymentCard,
          ),
        );
      case CustomerDisplayMode.paymentCash:
        return CustomerDisplayOrderLayout(
          content: content,
          rightPanel: CustomerDisplayPaymentPanel(
            content: content,
            mode: CustomerDisplayMode.paymentCash,
          ),
        );
      case CustomerDisplayMode.approved:
        return CustomerDisplayApprovedView(content: content);
      case CustomerDisplayMode.changeDue:
        return CustomerDisplayChangeDueView(content: content);
      case CustomerDisplayMode.error:
        return const CustomerDisplayPaymentDeclinedView();
    }
  }
}
