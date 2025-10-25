import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../../domain/entities/voucher_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../datasources/checkout_datasource.dart';
import '../models/order_model.dart';
import '../../domain/entities/checkout_metadata_entity.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutDataSource _checkoutDataSource;

  CheckoutRepositoryImpl({required CheckoutDataSource checkoutDataSource})
      : _checkoutDataSource = checkoutDataSource;

  // Note: _localDataSource is available for future use when implementing
  // local data persistence features

  @override
  Future<Either<Failure, String>> processPayment({
    required String paymentMethod,
    required double amount,
    CheckoutMetadataEntity? metadata,
  }) async {
    try {
      // Validate payment parameters
      if (paymentMethod.isEmpty) {
        return Left(ValidationFailure(message: 'Payment method is required'));
      }

      if (amount <= 0) {
        return Left(ValidationFailure(
            message: 'Payment amount must be greater than 0'));
      }

      // Simulate payment processing delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Generate order ID
      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

      // In a real implementation, this would:
      // - For cash: record transaction in local database
      // - For card/wallet/BNPL: create payment intent server-side
      // - For split: process all tenders

      return Right(orderId);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Payment processing failed: $e'));
    }
  }

  @override
  Future<Either<Failure, VoucherEntity?>> validateVoucher(String code) async {
    try {
      // Validate voucher code
      if (code.isEmpty) {
        return Left(ValidationFailure(message: 'Voucher code is required'));
      }

      // Simple voucher validation (matching existing logic)
      double voucherAmount = 10.0; // Default
      final lowerCode = code.toLowerCase();

      if (lowerCode.contains('save5')) voucherAmount = 5.0;
      if (lowerCode.contains('save15')) voucherAmount = 15.0;
      if (lowerCode.contains('save20')) voucherAmount = 20.0;

      // Check if voucher is valid (simple validation)
      if (voucherAmount == 10.0 && !lowerCode.contains('save10')) {
        return Right(null); // Invalid voucher code
      }

      final voucher = VoucherEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        code: code,
        amount: voucherAmount,
        appliedAt: DateTime.now(),
      );

      return Right(voucher);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Voucher validation failed: $e'));
    }
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
