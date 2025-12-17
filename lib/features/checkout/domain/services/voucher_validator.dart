import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../entities/voucher_entity.dart';

/// Defines the contract for validating voucher codes.
abstract class VoucherValidator {
  Future<Either<Failure, VoucherEntity?>> validate(String code);
}

/// Default implementation that encapsulates voucher parsing and validation rules.
class InMemoryVoucherValidator implements VoucherValidator {
  const InMemoryVoucherValidator();

  @override
  Future<Either<Failure, VoucherEntity?>> validate(String code) async {
    try {
      final trimmedCode = code.trim();

      if (trimmedCode.isEmpty) {
        return Left(ValidationFailure(message: 'Voucher code is required'));
      }

      final normalized = trimmedCode.toLowerCase();
      double voucherAmount = 10.0;

      if (normalized.contains('save5')) voucherAmount = 5.0;
      if (normalized.contains('save15')) voucherAmount = 15.0;
      if (normalized.contains('save20')) voucherAmount = 20.0;

      if (voucherAmount == 10.0 && !normalized.contains('save10')) {
        return Right(null);
      }

      final voucher = VoucherEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        code: trimmedCode,
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
}

