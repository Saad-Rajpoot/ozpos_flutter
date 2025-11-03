import '../../domain/entities/customer_display_entity.dart';

abstract class CustomerDisplayDataSource {
  Future<CustomerDisplayEntity> getContent();
}
