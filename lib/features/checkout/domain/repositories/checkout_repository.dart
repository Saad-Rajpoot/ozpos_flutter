import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/voucher_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/checkout_metadata_entity.dart';
import '../../domain/entities/book_order_item_input.dart';
import '../../domain/entities/book_order_result.dart';

abstract class CheckoutRepository {
  /// Process payment with given method and amount
  Future<Either<Failure, String>> processPayment({
    required String paymentMethod,
    required double amount,
    CheckoutMetadataEntity? metadata,
  });

  /// Validate voucher code and return voucher entity
  Future<Either<Failure, VoucherEntity?>> validateVoucher(String code);

  /// Calculate tax for given amount
  /// Returns Either<Failure, double> for consistent error handling
  /// If amount is negative, returns ValidationFailure
  Either<Failure, double> calculateTax(double amount, {double taxRate = 0.10});

  /// Save unpaid order for later payment
  Future<Either<Failure, String>> saveUnpaidOrder(OrderEntity orderEntity);

  /// Book order via ozfoodz API.
  /// vendorUuid and branchUuid are optional; when null, uses session values from storage.
  Future<Either<Failure, BookOrderResult>> bookOrder({
    String? vendorUuid,
    String? branchUuid,
    String? eaterFirstName,
    String? eaterLastName,
    String? eaterPhone,
    String? eaterEmail,
    required List<BookOrderItemInput> items,
    required String serviceType,
    required DateTime placedAt,
    required double subtotal,
    required double tax,
    required double total,
    required double deliveryFee,
    required double tip,
    required String paymentMethod,
    String? tableNumber,
    String? address,
    String? notes,
  });
}
