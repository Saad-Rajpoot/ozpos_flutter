import 'package:dartz/dartz.dart';
import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/reservation_entity.dart';
import '../repositories/reservation_repository.dart';

class GetReservations implements UseCase<List<ReservationEntity>, NoParams> {
  final ReservationRepository repository;

  GetReservations(this.repository);

  @override
  Future<Either<Failure, List<ReservationEntity>>> call(NoParams params) async {
    return repository.getReservations();
  }
}
