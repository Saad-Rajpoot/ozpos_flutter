import 'package:dartz/dartz.dart';
import '../errors/failures.dart';

/// Base use case interface
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// No parameters class for use cases that don't need parameters
class NoParams {
  const NoParams();
}
