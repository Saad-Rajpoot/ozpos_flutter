import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/customer_display_entity.dart';

/// Repository contract for fetching customer display content
abstract class CustomerDisplayRepository {
  Future<Either<Failure, CustomerDisplayEntity>> getDisplayContent();
}
