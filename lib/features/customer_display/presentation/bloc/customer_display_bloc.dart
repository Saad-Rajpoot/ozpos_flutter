import 'dart:async';

import '../../../../core/base/base_bloc.dart';
import '../../../../core/base/base_usecase.dart';
import '../../domain/entities/customer_display_entity.dart';
import '../../domain/entities/customer_display_mode.dart';
import '../../domain/usecases/get_customer_display.dart';
import 'customer_display_event.dart';
import 'customer_display_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomerDisplayBloc
    extends BaseBloc<CustomerDisplayEvent, CustomerDisplayState> {
  final GetCustomerDisplay getCustomerDisplay;

  Timer? _modeTimer;
  Timer? _slideTimer;

  CustomerDisplayBloc({required this.getCustomerDisplay})
      : super(const CustomerDisplayState()) {
    on<CustomerDisplayOpened>(_onOpened);
    on<CustomerDisplayModeAdvanced>(_onModeAdvanced);
    on<CustomerDisplaySlideAdvanced>(_onSlideAdvanced);
    on<CustomerDisplayModeSelected>(_onModeSelected);
    on<CustomerDisplayClosed>(_onClosed);
    on<CustomerDisplayRetryRequested>(_onRetryRequested);
  }

  Future<void> _onOpened(
    CustomerDisplayOpened event,
    Emitter<CustomerDisplayState> emit,
  ) async {
    if (state.content != null) {
      _restartDisplay(emit, state.content!);
      return;
    }

    await _fetchContent(emit);
  }

  Future<void> _fetchContent(
    Emitter<CustomerDisplayState> emit,
  ) async {
    emit(
      state.copyWith(
        status: CustomerDisplayStatus.loading,
        isOverlayVisible: true,
        clearError: true,
      ),
    );

    final result = await getCustomerDisplay(const NoParams());

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: CustomerDisplayStatus.error,
            errorMessage: failure.message,
            isOverlayVisible: true,
          ),
        );
      },
      (display) {
        emit(
          state.copyWith(
            status: CustomerDisplayStatus.ready,
            content: display,
            currentModeIndex: 0,
            currentSlideIndex: 0,
            isOverlayVisible: true,
            clearError: true,
          ),
        );
        _startModeTimer(display);
        _startSlideTimerIfNeeded(display, display.initialMode);
      },
    );
  }

  void _restartDisplay(
    Emitter<CustomerDisplayState> emit,
    CustomerDisplayEntity display,
  ) {
    _cancelTimers();
    emit(
      state.copyWith(
        status: CustomerDisplayStatus.ready,
        currentModeIndex: 0,
        currentSlideIndex: 0,
        isOverlayVisible: true,
        clearError: true,
      ),
    );
    _startModeTimer(display);
    _startSlideTimerIfNeeded(display, display.initialMode);
  }

  void _onModeAdvanced(
    CustomerDisplayModeAdvanced event,
    Emitter<CustomerDisplayState> emit,
  ) {
    final display = state.content;
    if (display == null || display.demoSequence.isEmpty) {
      return;
    }

    final nextIndex =
        (state.currentModeIndex + 1) % display.demoSequence.length;
    final nextMode = display.demoSequence[nextIndex];
    emit(
      state.copyWith(
        currentModeIndex: nextIndex,
        currentSlideIndex:
            nextMode.showsPromoSlides ? 0 : state.currentSlideIndex,
      ),
    );
    _startSlideTimerIfNeeded(display, nextMode);
  }

  void _onSlideAdvanced(
    CustomerDisplaySlideAdvanced event,
    Emitter<CustomerDisplayState> emit,
  ) {
    final display = state.content;
    if (display == null || display.promoSlides.isEmpty) {
      return;
    }
    if (!state.currentMode.showsPromoSlides) {
      return;
    }

    final nextSlide =
        (state.currentSlideIndex + 1) % display.promoSlides.length;
    emit(state.copyWith(currentSlideIndex: nextSlide));
  }

  void _onModeSelected(
    CustomerDisplayModeSelected event,
    Emitter<CustomerDisplayState> emit,
  ) {
    final display = state.content;
    if (display == null) {
      return;
    }

    final targetIndex = display.demoSequence.indexOf(event.mode);
    if (targetIndex == -1) {
      return;
    }

    emit(
      state.copyWith(
        currentModeIndex: targetIndex,
        currentSlideIndex:
            event.mode.showsPromoSlides ? 0 : state.currentSlideIndex,
      ),
    );
    _startSlideTimerIfNeeded(display, event.mode);
  }

  Future<void> _onRetryRequested(
    CustomerDisplayRetryRequested event,
    Emitter<CustomerDisplayState> emit,
  ) async {
    await _fetchContent(emit);
  }

  void _onClosed(
    CustomerDisplayClosed event,
    Emitter<CustomerDisplayState> emit,
  ) {
    _cancelTimers();
    emit(
      state.copyWith(
        status: CustomerDisplayStatus.closed,
        isOverlayVisible: false,
      ),
    );
  }

  void _startModeTimer(CustomerDisplayEntity display) {
    _modeTimer?.cancel();
    if (display.demoSequence.length <= 1 || display.modeIntervalSeconds <= 0) {
      return;
    }
    _modeTimer = Timer.periodic(
      Duration(seconds: display.modeIntervalSeconds),
      (_) => add(const CustomerDisplayModeAdvanced()),
    );
  }

  void _startSlideTimerIfNeeded(
    CustomerDisplayEntity display,
    CustomerDisplayMode mode,
  ) {
    _slideTimer?.cancel();
    if (!mode.showsPromoSlides ||
        display.slideIntervalSeconds <= 0 ||
        display.promoSlides.isEmpty) {
      return;
    }

    _slideTimer = Timer.periodic(
      Duration(seconds: display.slideIntervalSeconds),
      (_) => add(const CustomerDisplaySlideAdvanced()),
    );
  }

  void _cancelTimers() {
    _modeTimer?.cancel();
    _modeTimer = null;
    _slideTimer?.cancel();
    _slideTimer = null;
  }

  @override
  Future<void> close() {
    _cancelTimers();
    return super.close();
  }
}
