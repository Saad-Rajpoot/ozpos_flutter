import 'package:equatable/equatable.dart';
import '../repositories/checkout_repository.dart';
import '../entities/voucher_entity.dart';

class ApplyVoucherUseCase {
  final CheckoutRepository _repository;

  ApplyVoucherUseCase({required CheckoutRepository repository})
      : _repository = repository;

  Future<ApplyVoucherResult> call(ApplyVoucherParams params) async {
    if (params.code.trim().isEmpty) {
      return ApplyVoucherResult.error(message: 'Voucher code cannot be empty');
    }

    try {
      final voucher = await _repository.validateVoucher(params.code);

      if (voucher == null) {
        return ApplyVoucherResult.error(message: 'Invalid voucher code');
      }

      return ApplyVoucherResult.success(voucher: voucher);
    } catch (e) {
      return ApplyVoucherResult.error(message: 'Failed to apply voucher: $e');
    }
  }
}

class ApplyVoucherParams extends Equatable {
  final String code;

  const ApplyVoucherParams({required this.code});

  @override
  List<Object?> get props => [code];
}

class ApplyVoucherResult extends Equatable {
  final bool isSuccess;
  final VoucherEntity? voucher;
  final String? errorMessage;

  const ApplyVoucherResult._({
    required this.isSuccess,
    this.voucher,
    this.errorMessage,
  });

  factory ApplyVoucherResult.success({required VoucherEntity voucher}) {
    return ApplyVoucherResult._(
      isSuccess: true,
      voucher: voucher,
    );
  }

  factory ApplyVoucherResult.error({required String message}) {
    return ApplyVoucherResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }

  @override
  List<Object?> get props => [isSuccess, voucher, errorMessage];
}
