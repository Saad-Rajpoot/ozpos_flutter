import '../../../../core/base/base_bloc.dart';

abstract class DeliveryEvent extends BaseEvent {
  const DeliveryEvent();
}

/// Load all delivery data from JSON file
class LoadDeliveryDataEvent extends DeliveryEvent {
  const LoadDeliveryDataEvent();
}
