import 'package:equatable/equatable.dart';

abstract class DeliveryEvent extends Equatable {
  const DeliveryEvent();

  @override
  List<Object?> get props => [];
}

/// Load all delivery data from JSON file
class LoadDeliveryDataEvent extends DeliveryEvent {
  const LoadDeliveryDataEvent();
}
