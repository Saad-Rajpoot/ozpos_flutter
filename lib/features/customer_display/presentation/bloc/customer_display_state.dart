import '../../../../core/base/base_bloc.dart';
import '../../domain/entities/customer_display_entity.dart';
import '../../domain/entities/customer_display_mode.dart';

enum CustomerDisplayStatus { initial, loading, ready, error, closed }

class CustomerDisplayState extends BaseState {
  final CustomerDisplayStatus status;
  final CustomerDisplayEntity? content;
  final int currentModeIndex;
  final int currentSlideIndex;
  final bool isOverlayVisible;
  final String? errorMessage;

  const CustomerDisplayState({
    this.status = CustomerDisplayStatus.initial,
    this.content,
    this.currentModeIndex = 0,
    this.currentSlideIndex = 0,
    this.isOverlayVisible = false,
    this.errorMessage,
  });

  CustomerDisplayMode get currentMode {
    final sequence = content?.demoSequence ?? const [];
    if (sequence.isEmpty) {
      return CustomerDisplayMode.idle;
    }
    final safeIndex = currentModeIndex % sequence.length;
    return sequence[safeIndex];
  }

  int get totalSteps => content?.totalSteps ?? 0;

  bool get isLoading => status == CustomerDisplayStatus.loading;

  bool get hasError => status == CustomerDisplayStatus.error;

  bool get isReady => status == CustomerDisplayStatus.ready;

  bool get shouldShowSlides =>
      isReady &&
      currentMode.showsPromoSlides &&
      (content?.promoSlides.isNotEmpty ?? false);

  CustomerDisplayState copyWith({
    CustomerDisplayStatus? status,
    CustomerDisplayEntity? content,
    int? currentModeIndex,
    int? currentSlideIndex,
    bool? isOverlayVisible,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CustomerDisplayState(
      status: status ?? this.status,
      content: content ?? this.content,
      currentModeIndex: currentModeIndex ?? this.currentModeIndex,
      currentSlideIndex: currentSlideIndex ?? this.currentSlideIndex,
      isOverlayVisible: isOverlayVisible ?? this.isOverlayVisible,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        content,
        currentModeIndex,
        currentSlideIndex,
        isOverlayVisible,
        errorMessage,
      ];
}
