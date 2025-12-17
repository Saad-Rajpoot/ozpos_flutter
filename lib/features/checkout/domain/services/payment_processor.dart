import 'dart:async';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../entities/checkout_metadata_entity.dart';

/// Defines the contract for processing payments within the domain layer.
abstract class PaymentProcessor {
  Future<Either<Failure, String>> processPayment({
    required String paymentMethod,
    required double amount,
    CheckoutMetadataEntity? metadata,
  });
}

/// Default in-memory implementation that simulates payment processing.
class SimulatedPaymentProcessor implements PaymentProcessor {
  const SimulatedPaymentProcessor();

  @override
  Future<Either<Failure, String>> processPayment({
    required String paymentMethod,
    required double amount,
    CheckoutMetadataEntity? metadata,
  }) async {
    try {
      if (paymentMethod.trim().isEmpty) {
        return Left(ValidationFailure(message: 'Payment method is required'));
      }

      if (amount <= 0) {
        return Left(ValidationFailure(
            message: 'Payment amount must be greater than 0'));
      }

      await Future.delayed(const Duration(milliseconds: 800));

      final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

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
}
