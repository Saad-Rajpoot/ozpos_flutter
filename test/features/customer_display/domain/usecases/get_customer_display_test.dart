import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:ozpos_flutter/core/base/base_usecase.dart';
import 'package:ozpos_flutter/core/errors/failures.dart';
import 'package:ozpos_flutter/features/customer_display/domain/entities/customer_display_cart_item_entity.dart';
import 'package:ozpos_flutter/features/customer_display/domain/entities/customer_display_entity.dart';
import 'package:ozpos_flutter/features/customer_display/domain/entities/customer_display_loyalty_entity.dart';
import 'package:ozpos_flutter/features/customer_display/domain/entities/customer_display_mode.dart';
import 'package:ozpos_flutter/features/customer_display/domain/entities/customer_display_totals_entity.dart';
import 'package:ozpos_flutter/features/customer_display/domain/repositories/customer_display_repository.dart';
import 'package:ozpos_flutter/features/customer_display/domain/usecases/get_customer_display.dart';

class _MockCustomerDisplayRepository extends Mock
    implements CustomerDisplayRepository {}

void main() {
  late GetCustomerDisplay useCase;
  late _MockCustomerDisplayRepository repository;

  const demoEntity = CustomerDisplayEntity(
    orderNumber: '142',
    cartItems: [
      CustomerDisplayCartItemEntity(
        id: '1',
        name: 'Classic Burger',
        price: 12.99,
        quantity: 2,
        modifiers: ['Extra Cheese'],
      ),
    ],
    totals: CustomerDisplayTotalsEntity(
      subtotal: 25.98,
      discount: 0,
      tax: 2.6,
      total: 28.58,
      cashReceived: 0,
      changeDue: 0,
    ),
    loyalty: CustomerDisplayLoyaltyEntity(
      pointsEarned: 175,
      currentBalance: 420,
    ),
    promoSlides: [],
    demoSequence: [CustomerDisplayMode.idle, CustomerDisplayMode.order],
    modeIntervalSeconds: 5,
    slideIntervalSeconds: 4,
  );

  setUp(() {
    repository = _MockCustomerDisplayRepository();
    useCase = GetCustomerDisplay(repository: repository);
  });

  test('should retrieve demo content from repository', () async {
    when(() => repository.getDisplayContent())
        .thenAnswer((_) async => const Right(demoEntity));

    final result = await useCase(const NoParams());

    expect(result, const Right(demoEntity));
    verify(() => repository.getDisplayContent()).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('should return failure when repository fails', () async {
    const failure = ServerFailure(message: 'network-error');
    when(() => repository.getDisplayContent())
        .thenAnswer((_) async => const Left(failure));

    final result = await useCase(const NoParams());

    expect(result, const Left(failure));
    verify(() => repository.getDisplayContent()).called(1);
    verifyNoMoreInteractions(repository);
  });
}
