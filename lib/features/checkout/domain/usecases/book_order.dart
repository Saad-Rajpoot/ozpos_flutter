import 'package:dartz/dartz.dart';

import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/book_order_item_input.dart';
import '../entities/book_order_result.dart';
import '../repositories/checkout_repository.dart';

class BookOrderUseCase
    implements UseCase<BookOrderResult, BookOrderParams> {
  final CheckoutRepository _repository;

  const BookOrderUseCase({required CheckoutRepository repository})
      : _repository = repository;

  @override
  Future<Either<Failure, BookOrderResult>> call(BookOrderParams params) async {
    return _repository.bookOrder(
      vendorUuid: params.vendorUuid,
      branchUuid: params.branchUuid,
      eaterFirstName: params.eaterFirstName,
      eaterLastName: params.eaterLastName,
      eaterPhone: params.eaterPhone,
      eaterEmail: params.eaterEmail,
      items: params.items,
      serviceType: params.serviceType,
      placedAt: params.placedAt,
      subtotal: params.subtotal,
      tax: params.tax,
      total: params.total,
      deliveryFee: params.deliveryFee,
      tip: params.tip,
      paymentMethod: params.paymentMethod,
      tableNumber: params.tableNumber,
      address: params.address,
      notes: params.notes,
    );
  }
}

class BookOrderParams {
  final String? vendorUuid;  // Optional; repo uses session when null
  final String? branchUuid; // Optional; repo uses session when null
  final String? eaterFirstName;
  final String? eaterLastName;
  final String? eaterPhone;
  final String? eaterEmail;
  final List<BookOrderItemInput> items;
  final String serviceType;
  final DateTime placedAt;
  final double subtotal;
  final double tax;
  final double total;
  final double deliveryFee;
  final double tip;
  final String paymentMethod;
  final String? tableNumber;
  final String? address;
  final String? notes;

  const BookOrderParams({
    this.vendorUuid,
    this.branchUuid,
    this.eaterFirstName,
    this.eaterLastName,
    this.eaterPhone,
    this.eaterEmail,
    required this.items,
    required this.serviceType,
    required this.placedAt,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.deliveryFee,
    required this.tip,
    required this.paymentMethod,
    this.tableNumber,
    this.address,
    this.notes,
  });
}
