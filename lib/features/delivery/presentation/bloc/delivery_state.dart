import 'package:equatable/equatable.dart';
import '../../domain/entities/delivery_entities.dart';

abstract class DeliveryState extends Equatable {
  const DeliveryState();

  @override
  List<Object?> get props => [];
}

class DeliveryInitial extends DeliveryState {
  const DeliveryInitial();
}

class DeliveryLoading extends DeliveryState {
  const DeliveryLoading();
}

class DeliveryLoaded extends DeliveryState {
  final DeliveryData deliveryData;

  const DeliveryLoaded({required this.deliveryData});

  DeliveryLoaded copyWith({DeliveryData? deliveryData}) {
    return DeliveryLoaded(deliveryData: deliveryData ?? this.deliveryData);
  }

  @override
  List<Object?> get props => [deliveryData];
}

class DeliveryError extends DeliveryState {
  final String message;

  const DeliveryError(this.message);

  @override
  List<Object?> get props => [message];
}
