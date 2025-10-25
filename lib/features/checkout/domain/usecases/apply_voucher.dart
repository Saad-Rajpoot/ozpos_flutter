import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/checkout_repository.dart';
import '../entities/voucher_entity.dart';

class ApplyVoucherUseCase
    implements UseCase<ApplyVoucherResult, ApplyVoucherParams> {
  final CheckoutRepository _repository;

  const ApplyVoucherUseCase({required CheckoutRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, ApplyVoucherResult>> call(
      ApplyVoucherParams params) async {
    if (params.code.trim().isEmpty) {
      return Left(ValidationFailure(message: 'Voucher code cannot be empty'));
    }

    // Repository now returns Either, so we handle it directly
    final result = await _repository.validateVoucher(params.code);

    return result.fold(
      (failure) => Left(failure),
      (voucher) {
        if (voucher == null) {
          return Left(ValidationFailure(message: 'Invalid voucher code'));
        }
        return Right(ApplyVoucherResult.success(voucher: voucher));
      },
    );
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
