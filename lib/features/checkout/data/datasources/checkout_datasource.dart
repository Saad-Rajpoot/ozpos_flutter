import '../models/order_model.dart';
import '../models/book_order_request.dart';
import '../models/book_order_response.dart';
import '../../domain/entities/checkout_entity.dart';

abstract class CheckoutDataSource {
  Future<CheckoutEntity> saveOrder(OrderModel orderModel);

  /// Book order via ozfoodz API; returns success with order details or throws ServerException on error.
  Future<BookOrderSuccessResponse> bookOrder(BookOrderRequest request);
}
