import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/repository_error_handler.dart';
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
  Either<Failure, double> calculateTax(double amount, {double taxRate = 0.10}) {
    // Validate input before calculation
    if (amount < 0) {
      return const Left(
        ValidationFailure(message: 'Amount cannot be negative'),
      );
    }

    if (taxRate < 0 || taxRate > 1) {
      return const Left(
        ValidationFailure(message: 'Tax rate must be between 0 and 1'),
      );
    }

    // Perform calculation
    final tax = amount * taxRate;
    return Right(tax);
  }

  @override
  Future<Either<Failure, String>> saveUnpaidOrder(
      OrderEntity orderEntity) async {
    // Validate order entity before processing
    if (orderEntity.id.isEmpty) {
      return const Left(ValidationFailure(message: 'Order ID is required'));
    }

    // Use error handler for local operation (database save)
    return RepositoryErrorHandler.handleLocalOperation<String>(
      operation: () async {
        // Convert entity to model for data layer
        final orderModel = OrderModel.fromEntity(orderEntity);

        // Save to local data source
        await _checkoutDataSource.saveOrder(orderModel);

        final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}-UNPAID';
        return orderId;
      },
      operationName: 'saving unpaid order',
    );
  }
}
