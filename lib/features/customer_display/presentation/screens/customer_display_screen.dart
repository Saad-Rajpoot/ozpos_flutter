import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/customer_display_bloc.dart';
import '../bloc/customer_display_event.dart';
import '../bloc/customer_display_state.dart';
import '../widgets/customer_display_approved_view.dart';
import '../widgets/customer_display_change_due_view.dart';
import '../widgets/customer_display_close_button.dart';
import '../widgets/customer_display_error_view.dart';
import '../widgets/customer_display_idle_view.dart';
import '../widgets/customer_display_order_layout.dart';
import '../widgets/customer_display_payment_declined_view.dart';
import '../widgets/customer_display_progress_indicator.dart';
import '../../domain/entities/customer_display_entity.dart';
import '../../domain/entities/customer_display_mode.dart';

class CustomerDisplayScreen extends StatefulWidget {
  const CustomerDisplayScreen({super.key});

  @override
  State<CustomerDisplayScreen> createState() => _CustomerDisplayScreenState();
}

class _CustomerDisplayScreenState extends State<CustomerDisplayScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CustomerDisplayBloc>().add(const CustomerDisplayOpened());
    });
  }

  @override
  Widget build(BuildContext context) {
    return const _CustomerDisplayView();
  }
}

class _CustomerDisplayView extends StatelessWidget {
  const _CustomerDisplayView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerDisplayBloc, CustomerDisplayState>(
      listenWhen: (previous, current) =>
          previous.status != current.status ||
          previous.isOverlayVisible != current.isOverlayVisible,
      listener: (context, state) {
        if (state.status == CustomerDisplayStatus.closed ||
            !state.isOverlayVisible) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              return;
            }
            context.read<CustomerDisplayBloc>().add(
                  const CustomerDisplayClosed(),
                );
          },
          child: Scaffold(
            backgroundColor: Colors.black,
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _buildBody(context, state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, CustomerDisplayState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (state.hasError) {
      return CustomerDisplayErrorView(
        message: state.errorMessage,
        onRetry: () => context
            .read<CustomerDisplayBloc>()
            .add(const CustomerDisplayRetryRequested()),
      );
    }

    final content = state.content;
    if (!state.isReady || content == null) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Positioned.fill(
          child: _buildModeContent(context, state, content),
        ),
        CustomerDisplayCloseButton(
          onClose: () => context
              .read<CustomerDisplayBloc>()
              .add(const CustomerDisplayClosed()),
        ),
        if (content.totalSteps > 0)
          CustomerDisplayProgressIndicator(
            modeLabel: state.currentMode.displayLabel,
            currentStep: state.currentModeIndex + 1,
            totalSteps: content.totalSteps,
          ),
      ],
    );
  }

  Widget _buildModeContent(
    BuildContext context,
    CustomerDisplayState state,
    CustomerDisplayEntity content,
  ) {
    final mode = state.currentMode;
    switch (mode) {
      case CustomerDisplayMode.idle:
        return CustomerDisplayIdleView(
          slide: content.promoSlides.isEmpty
              ? null
              : content.promoSlides[
                  state.currentSlideIndex % content.promoSlides.length],
          totalSlides: content.promoSlides.length,
          activeIndex: state.currentSlideIndex,
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
