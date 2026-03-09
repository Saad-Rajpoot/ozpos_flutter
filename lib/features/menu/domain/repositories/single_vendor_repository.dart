import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/single_vendor_menu_entity.dart';

/// Repository for single-vendor API (menu from data.branch.menuV2)
/// Fetches vendor_uuid and branch_uuid from session (SharedPreferences)
abstract class SingleVendorRepository {
  /// Fetches menu from single-vendor endpoint.
  /// Uses vendor_uuid and branch_uuid from session.
  /// Returns SessionFailure if UUIDs not found (e.g. session expired).
  ///
  /// [menuType] is an optional hint to select a specific menu variant
  /// (e.g. 'delivery', 'pickup') when multiple menus are configured.
  /// [menuId] can be used to select a concrete menu (by id / ue_external_id / name).
  Future<Either<Failure, SingleVendorMenuEntity>> getSingleVendorMenu({
    String? menuType,
    String? menuId,
  });
}
