import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/voucher_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/checkout_metadata_entity.dart';

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
  double calculateTax(double amount, {double taxRate = 0.10});

  /// Save unpaid order for later payment
  Future<Either<Failure, String>> saveUnpaidOrder(OrderEntity orderEntity);
}
