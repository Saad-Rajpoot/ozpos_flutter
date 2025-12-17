import '../../../../core/base/base_bloc.dart';
import '../../domain/entities/customer_display_mode.dart';

abstract class CustomerDisplayEvent extends BaseEvent {
  const CustomerDisplayEvent();
}

class CustomerDisplayOpened extends CustomerDisplayEvent {
  const CustomerDisplayOpened();
}

class CustomerDisplayModeAdvanced extends CustomerDisplayEvent {
  const CustomerDisplayModeAdvanced();
}

class CustomerDisplaySlideAdvanced extends CustomerDisplayEvent {
  const CustomerDisplaySlideAdvanced();
}

class CustomerDisplayModeSelected extends CustomerDisplayEvent {
  final CustomerDisplayMode mode;

  const CustomerDisplayModeSelected(this.mode);

  @override
  List<Object?> get props => [mode];
}

class CustomerDisplayClosed extends CustomerDisplayEvent {
  const CustomerDisplayClosed();
}

class CustomerDisplayRetryRequested extends CustomerDisplayEvent {
  const CustomerDisplayRetryRequested();
}
