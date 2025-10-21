import '../models/order_model.dart';
import '../../domain/entities/checkout_entity.dart';

abstract class CheckoutDataSource {
  Future<CheckoutEntity> saveOrder(OrderModel orderModel);
}
