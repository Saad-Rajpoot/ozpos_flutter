import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/voucher_entity.dart';
import '../../domain/entities/tender_entity.dart';
import '../../domain/entities/cart_line_item_entity.dart';
import '../../domain/entities/payment_method_type.dart';

class InitializeCheckoutUseCase
    implements UseCase<InitializeCheckoutResult, InitializeCheckoutParams> {
  const InitializeCheckoutUseCase();

  @override
  Future<Either<Failure, InitializeCheckoutResult>> call(
      InitializeCheckoutParams params) async {
    try {
      return Right(InitializeCheckoutResult(
        isSplitMode: false,
        selectedMethod: PaymentMethodType.cash,
        cashReceived: '',
        tipPercent: 0,
        customTipAmount: '',
        discountPercent: 0,
        appliedVouchers: const [],
        loyaltyRedemption: 0.0,
        isLoyaltyRedeemed: false,
        tenders: const [],
        items: params.items,
      ));
    } catch (e) {
      return Left(
          ValidationFailure(message: 'Failed to initialize checkout: $e'));
    }
  }
}

class InitializeCheckoutParams extends Equatable {
  final List<CartLineItemEntity> items;

  const InitializeCheckoutParams({required this.items});

  @override
  List<Object?> get props => [items];
}

class InitializeCheckoutResult extends Equatable {
  final bool isSplitMode;
  final PaymentMethodType selectedMethod;
  final String cashReceived;
  final int tipPercent;
  final String customTipAmount;
  final int discountPercent;
  final List<VoucherEntity> appliedVouchers;
  final double loyaltyRedemption;
  final bool isLoyaltyRedeemed;
  final List<TenderEntity> tenders;
  final List<CartLineItemEntity> items;

  const InitializeCheckoutResult({
    required this.isSplitMode,
    required this.selectedMethod,
    required this.cashReceived,
    required this.tipPercent,
    required this.customTipAmount,
    required this.discountPercent,
    required this.appliedVouchers,
    required this.loyaltyRedemption,
    required this.isLoyaltyRedeemed,
    required this.tenders,
    required this.items,
  });

  @override
  List<Object?> get props => [
        isSplitMode,
        selectedMethod,
        cashReceived,
        tipPercent,
        customTipAmount,
        discountPercent,
        appliedVouchers,
        loyaltyRedemption,
        isLoyaltyRedeemed,
        tenders,
        items,
      ];
}
