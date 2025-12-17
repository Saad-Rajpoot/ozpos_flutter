import 'package:equatable/equatable.dart';
import 'order_entity.dart';
import 'checkout_metadata_entity.dart';

class CheckoutEntity extends Equatable {
  final List<OrderEntity> orders;
  final CheckoutMetadataEntity metadata;

  const CheckoutEntity({
    required this.orders,
    required this.metadata,
  });

  @override
  List<Object?> get props => [orders, metadata];
}
