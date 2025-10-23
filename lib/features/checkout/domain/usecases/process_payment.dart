import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/checkout_repository.dart';
import '../entities/checkout_metadata_entity.dart';

class ProcessPaymentUseCase
    implements UseCase<ProcessPaymentResult, ProcessPaymentParams> {
  final CheckoutRepository _repository;

  const ProcessPaymentUseCase({required CheckoutRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, ProcessPaymentResult>> call(
      ProcessPaymentParams params) async {
    try {
      final orderId = await _repository.processPayment(
        paymentMethod: params.paymentMethod,
        amount: params.amount,
        metadata: params.metadata,
      );

      return Right(ProcessPaymentResult.success(
          orderId: orderId, paidAmount: params.amount));
    } catch (e) {
      return Left(ServerFailure(message: 'Payment failed: $e'));
    }
  }
}

class ProcessPaymentParams extends Equatable {
  final String paymentMethod;
  final double amount;
  final CheckoutMetadataEntity? metadata;

  const ProcessPaymentParams({
    required this.paymentMethod,
    required this.amount,
    this.metadata,
  });

  @override
  List<Object?> get props => [paymentMethod, amount, metadata];
}

class ProcessPaymentResult extends Equatable {
  final bool isSuccess;
  final String? orderId;
  final double? paidAmount;
  final String? errorMessage;

  const ProcessPaymentResult._({
    required this.isSuccess,
    this.orderId,
    this.paidAmount,
    this.errorMessage,
  });

  factory ProcessPaymentResult.success({
    required String orderId,
    required double paidAmount,
  }) {
    return ProcessPaymentResult._(
      isSuccess: true,
      orderId: orderId,
      paidAmount: paidAmount,
    );
  }

  factory ProcessPaymentResult.error({required String message}) {
    return ProcessPaymentResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }

  @override
  List<Object?> get props => [isSuccess, orderId, paidAmount, errorMessage];
}
