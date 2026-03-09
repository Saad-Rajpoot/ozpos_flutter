import 'package:dartz/dartz.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/repository_error_handler.dart';
import '../../../../core/db/sync_outbox_dao.dart';
import '../../../../core/db/orders_dao.dart';
import '../../../orders/domain/entities/order_entity.dart' as orders;
import '../../../orders/domain/entities/order_item_entity.dart' as orders;
import '../../domain/entities/payment_method_type.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../../domain/entities/voucher_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/checkout_metadata_entity.dart';
import '../../domain/entities/book_order_result.dart';
import '../../domain/entities/book_order_item_input.dart';
import '../../domain/services/payment_processor.dart';
import '../../domain/services/voucher_validator.dart';
import '../datasources/checkout_datasource.dart';
import '../datasources/checkout_remote_datasource.dart';
import '../mappers/book_order_mapper.dart';
import '../models/order_model.dart';
import '../models/book_order_request.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutDataSource _checkoutDataSource;
  final CheckoutRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final SharedPreferences _sharedPreferences;
  final PaymentProcessor _paymentProcessor;
  final VoucherValidator _voucherValidator;
  final SyncOutboxDao _syncOutboxDao;
  final OrdersDao _ordersDao;

  CheckoutRepositoryImpl({
    required CheckoutDataSource checkoutDataSource,
    required CheckoutRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
    required SharedPreferences sharedPreferences,
    required PaymentProcessor paymentProcessor,
    required VoucherValidator voucherValidator,
    required SyncOutboxDao syncOutboxDao,
    required OrdersDao ordersDao,
  })  : _checkoutDataSource = checkoutDataSource,
        _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo,
        _sharedPreferences = sharedPreferences,
        _paymentProcessor = paymentProcessor,
        _voucherValidator = voucherValidator,
        _syncOutboxDao = syncOutboxDao,
        _ordersDao = ordersDao;

  orders.OrderType _mapServiceTypeToOrderType(String serviceType) {
    switch (serviceType.toUpperCase()) {
      case 'DELIVERY':
        return orders.OrderType.delivery;
      case 'PICK_UP':
      case 'TAKEAWAY':
        return orders.OrderType.takeaway;
      case 'DINE_IN':
      default:
        return orders.OrderType.dinein;
    }
  }

  orders.OrderChannel _mapChannelFromOrderType(orders.OrderType type) {
    switch (type) {
      case orders.OrderType.delivery:
        return orders.OrderChannel.delivery;
      case orders.OrderType.takeaway:
        return orders.OrderChannel.takeaway;
      case orders.OrderType.dinein:
        return orders.OrderChannel.dinein;
    }
  }

  orders.OrderEntity _buildLocalOfflineOrder({
    required List<BookOrderItemInput> items,
    required String serviceType,
    required DateTime placedAt,
    required double subtotal,
    required double tax,
    required double total,
    required String paymentMethod,
    String? tableNumber,
    String? address,
    String? notes,
    String? eaterFirstName,
    String? eaterLastName,
    String? eaterPhone,
  }) {
    final orderType = _mapServiceTypeToOrderType(serviceType);
    final channel = _mapChannelFromOrderType(orderType);
    final createdAt = placedAt;
    final estimatedTime = placedAt.add(const Duration(minutes: 15));

    final customerName = [
      if (eaterFirstName != null && eaterFirstName.isNotEmpty) eaterFirstName,
      if (eaterLastName != null && eaterLastName.isNotEmpty) eaterLastName,
    ].join(' ').trim();

    final localId =
        'offline-${DateTime.now().millisecondsSinceEpoch.toString()}';

    final orderItems = items
        .map(
          (item) => orders.OrderItemEntity(
            name: item.menuItem.name,
            quantity: item.quantity,
            price: item.unitPrice,
            modifiers: item.selectedModifiers.entries
                .where((e) => e.value.isNotEmpty)
                .map(
                  (e) =>
                      '${e.key}: ${e.value.join(', ')}',
                )
                .toList(),
            instructions: item.specialInstructions,
          ),
        )
        .toList();

    return orders.OrderEntity(
      id: localId,
      queueNumber: '#OFFLINE',
      channel: channel,
      orderType: orderType,
      paymentStatus: orders.PaymentStatus.unpaid,
      status: orders.OrderStatus.active,
      customerName: customerName.isEmpty ? 'Offline Guest' : customerName,
      customerPhone: eaterPhone,
      items: orderItems,
      subtotal: subtotal,
      tax: tax,
      total: total,
      createdAt: createdAt,
      estimatedTime: estimatedTime,
      specialInstructions: notes,
      displayStatus: 'UNPAID',
    );
  }

  // Note: _localDataSource is available for future use when implementing
  // local data persistence features

  @override
  Future<Either<Failure, String>> processPayment({
    required String paymentMethod,
    required double amount,
    CheckoutMetadataEntity? metadata,
  }) async {
    // Enforce payment safety with respect to connectivity.
    final methodType = PaymentMethodType.fromString(paymentMethod);
    final isConnected = await _networkInfo.isConnected;

    // Online-only methods must not be marked as success while offline.
    final requiresOnline = methodType == PaymentMethodType.card ||
        methodType == PaymentMethodType.digitalWallet ||
        methodType == PaymentMethodType.bankTransfer ||
        methodType == PaymentMethodType.bnpl ||
        methodType == PaymentMethodType.wallet ||
        methodType == PaymentMethodType.loyaltyPoints ||
        methodType == PaymentMethodType.gift;

    if (!isConnected && requiresOnline) {
      return const Left(
        NetworkFailure(
          message:
              'This payment method requires internet. Please reconnect and try again.',
        ),
      );
    }

    // Cash / COD / Pay-later are still processed via existing processor;
    // future work can enqueue safe offline mutations into the outbox.
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
  Future<Either<Failure, BookOrderResult>> bookOrder({
    String? vendorUuid,
    String? branchUuid,
    String? eaterFirstName,
    String? eaterLastName,
    String? eaterPhone,
    String? eaterEmail,
    required List<BookOrderItemInput> items,
    required String serviceType,
    required DateTime placedAt,
    required double subtotal,
    required double tax,
    required double total,
    required double deliveryFee,
    required double tip,
    required String paymentMethod,
    String? tableNumber,
    String? address,
    String? notes,
  }) async {
    return RepositoryErrorHandler.handleOperation<BookOrderResult>(
      networkInfo: _networkInfo,
      operationName: 'booking order',
      skipNetworkCheck: true,
      operation: () async {
        final vUuid = vendorUuid ??
            _sharedPreferences.getString(AppConstants.authVendorUuidKey);
        final bUuid = branchUuid ??
            _sharedPreferences.getString(AppConstants.authBranchUuidKey);
        if (vUuid == null || vUuid.isEmpty || bUuid == null || bUuid.isEmpty) {
          throw const AuthException(message: 'Session expired');
        }
        final store = BookOrderStore(
          vendorUuid: vUuid,
          branchUuid: bUuid,
        );
        final eater = BookOrderEater(
          firstName: eaterFirstName,
          lastName: eaterLastName,
          phone: eaterPhone,
          email: eaterEmail,
        );
        final request = BookOrderMapper.toRequest(
          store: store,
          eater: eater,
          items: items,
          serviceType: serviceType,
          placedAt: placedAt,
          subtotal: subtotal,
          tax: tax,
          total: total,
          deliveryFee: deliveryFee,
          tip: tip,
          paymentMethod: paymentMethod,
          tableNumber: tableNumber,
          address: address,
          notes: notes,
        );

        final isConnected = await _networkInfo.isConnected;
        final methodType = PaymentMethodType.fromString(paymentMethod);
        final offlineSafe = methodType == PaymentMethodType.cash ||
            methodType == PaymentMethodType.cod ||
            methodType == PaymentMethodType.payLater;

        if (isConnected) {
          // Online path: behave as before.
          final response = await _remoteDataSource.bookOrder(request);

          return BookOrderResult(
            orderId: response.orderId,
            displayId: response.displayId,
            referenceNo: response.referenceNo,
            status: response.status,
          );
        }

        // Offline path:
        if (!offlineSafe) {
          throw const NetworkException(
            message:
                'No network connection. This payment method requires internet.',
          );
        }

        final correlationId =
            'local-book-${DateTime.now().millisecondsSinceEpoch}';
        await _syncOutboxDao.enqueue(
          type: 'book_order',
          method: 'POST',
          path: AppConstants.bookOrderEndpoint,
          bodyJson: jsonEncode(request.toJson()),
          correlationId: correlationId,
        );

        // Persist a local placeholder order so that offline order management
        // can display the order immediately while it is pending sync.
        try {
          final localOrder = _buildLocalOfflineOrder(
            items: items,
            serviceType: serviceType,
            placedAt: placedAt,
            subtotal: subtotal,
            tax: tax,
            total: total,
            paymentMethod: paymentMethod,
            tableNumber: tableNumber,
            address: address,
            notes: notes,
            eaterFirstName: eaterFirstName,
            eaterLastName: eaterLastName,
            eaterPhone: eaterPhone,
          );
          await _ordersDao.insertLocalOrder(localOrder);
        } catch (_) {
          // Offline UX should not fail if local caching fails.
        }

        // Return a local pseudo-result so checkout UI can proceed.
        return const BookOrderResult(
          orderId: -1,
          displayId: '#OFFLINE',
          referenceNo: 'OFFLINE',
          status: 'PENDING_SYNC',
        );
      },
    );
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
