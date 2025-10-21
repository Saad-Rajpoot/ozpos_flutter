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
  Future<String> processPayment({
    required String paymentMethod,
    required double amount,
    CheckoutMetadataEntity? metadata,
  }) async {
    // Simulate payment processing delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate order ID
    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

    // In a real implementation, this would:
    // - For cash: record transaction in local database
    // - For card/wallet/BNPL: create payment intent server-side
    // - For split: process all tenders

    return orderId;
  }

  @override
  Future<VoucherEntity?> validateVoucher(String code) async {
    // Simple voucher validation (matching existing logic)
    double voucherAmount = 10.0; // Default
    final lowerCode = code.toLowerCase();

    if (lowerCode.contains('save5')) voucherAmount = 5.0;
    if (lowerCode.contains('save15')) voucherAmount = 15.0;
    if (lowerCode.contains('save20')) voucherAmount = 20.0;

    final voucher = VoucherEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      code: code,
      amount: voucherAmount,
      appliedAt: DateTime.now(),
    );

    return voucher;
  }

  @override
  double calculateTax(double amount, {double taxRate = 0.10}) {
    return amount * taxRate;
  }

  @override
  Future<String> saveUnpaidOrder(OrderEntity orderEntity) async {
    // Convert entity to model for data layer
    final orderModel = OrderModel.fromEntity(orderEntity);

    // Save to local data source
    await _checkoutDataSource.saveOrder(orderModel);

    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch}-UNPAID';
    return orderId;
  }
}
