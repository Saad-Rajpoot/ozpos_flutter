import 'package:equatable/equatable.dart';
import '../repositories/checkout_repository.dart';
import '../entities/checkout_metadata_entity.dart';

class ProcessPaymentUseCase {
  final CheckoutRepository _repository;

  ProcessPaymentUseCase({required CheckoutRepository repository})
      : _repository = repository;

  Future<ProcessPaymentResult> call(ProcessPaymentParams params) async {
    try {
      final orderId = await _repository.processPayment(
        paymentMethod: params.paymentMethod,
        amount: params.amount,
        metadata: params.metadata,
      );

      return ProcessPaymentResult.success(
          orderId: orderId, paidAmount: params.amount);
    } catch (e) {
      return ProcessPaymentResult.error(message: 'Payment failed: $e');
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
