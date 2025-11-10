import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../../domain/entities/voucher_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/checkout_metadata_entity.dart';
import '../../domain/services/payment_processor.dart';
import '../../domain/services/voucher_validator.dart';
import '../datasources/checkout_datasource.dart';
import '../models/order_model.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutDataSource _checkoutDataSource;
  final PaymentProcessor _paymentProcessor;
  final VoucherValidator _voucherValidator;

  CheckoutRepositoryImpl({
    required CheckoutDataSource checkoutDataSource,
    required PaymentProcessor paymentProcessor,
    required VoucherValidator voucherValidator,
  })  : _checkoutDataSource = checkoutDataSource,
        _paymentProcessor = paymentProcessor,
        _voucherValidator = voucherValidator;

  // Note: _localDataSource is available for future use when implementing
  // local data persistence features

  @override
  Future<Either<Failure, String>> processPayment({
    required String paymentMethod,
    required double amount,
    CheckoutMetadataEntity? metadata,
  }) async {
    return _paymentProcessor.processPayment(
      paymentMethod: paymentMethod,
      amount: amount,
      metadata: metadata,
    );
  }

  @override
  Future<Either<Failure, VoucherEntity?>> validateVoucher(String code) async {
    return _voucherValidator.validate(code);
  }

  @override
  double calculateTax(double amount, {double taxRate = 0.10}) {
    // Pure function - no need for Either pattern
    if (amount < 0) {
      throw ValidationException(message: 'Amount cannot be negative');
    }
    return amount * taxRate;
  }

  @override
  Future<Either<Failure, String>> saveUnpaidOrder(
      OrderEntity orderEntity) async {
    try {
      // Validate order entity
      if (orderEntity.id.isEmpty) {
        return Left(ValidationFailure(message: 'Order ID is required'));
      }

      // Convert entity to model for data layer
      final orderModel = OrderModel.fromEntity(orderEntity);

      // Save to local data source
      await _checkoutDataSource.saveOrder(orderModel);

      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}-UNPAID';
      return Right(orderId);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to save unpaid order: $e'));
    }
  }
}
