import 'package:dartz/dartz.dart';

import '../../../../core/base/base_usecase.dart';
import '../../../../core/errors/failures.dart';
import '../entities/single_vendor_menu_entity.dart';
import '../repositories/single_vendor_repository.dart';

/// Params for selecting a specific menu variant (e.g. delivery vs pickup).
class GetSingleVendorParams {
  final String? menuType; // 'delivery', 'pickup', 'dine_in', etc.

  /// Optional concrete menu identifier (id / ue_external_id / name) to force
  /// a specific menu within the given [menuType].
  final String? menuId;

  const GetSingleVendorParams({this.menuType, this.menuId});
}

/// Use case for fetching menu from single-vendor API
class GetSingleVendorUsecase
    implements UseCase<SingleVendorMenuEntity, GetSingleVendorParams> {
  final SingleVendorRepository repository;

  GetSingleVendorUsecase({required this.repository});

  @override
  Future<Either<Failure, SingleVendorMenuEntity>> call(
    GetSingleVendorParams params,
  ) async {
    return repository.getSingleVendorMenu(
      menuType: params.menuType,
      menuId: params.menuId,
    );
  }
}
