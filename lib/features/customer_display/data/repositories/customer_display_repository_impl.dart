import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/utils/repository_error_handler.dart';
import '../../domain/entities/customer_display_entity.dart';
import '../../domain/repositories/customer_display_repository.dart';
import '../datasources/customer_display_data_source.dart';

class CustomerDisplayRepositoryImpl implements CustomerDisplayRepository {
  final CustomerDisplayDataSource dataSource;

  CustomerDisplayRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, CustomerDisplayEntity>> getDisplayContent() async {
    // Note: This repository doesn't use NetworkInfo, so we skip network check
    // The data source handles its own network/connection logic
    return RepositoryErrorHandler.handleLocalOperation<CustomerDisplayEntity>(
      operation: () async => await dataSource.getContent(),
      operationName: 'loading customer display',
    );
  }
}
