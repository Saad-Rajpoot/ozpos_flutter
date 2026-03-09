import 'package:drift/drift.dart';

import 'pos_database.dart';

/// DAO for reading and writing menu snapshots used for offline menu support.
class MenuSnapshotDao {
  MenuSnapshotDao(this._db);

  final PosDatabase _db;

  /// Upserts a menu snapshot for the given vendor/branch.
  Future<void> upsertSnapshot({
    required String vendorUuid,
    required String branchUuid,
    required String payloadJson,
    String? version,
  }) async {
    final now = DateTime.now();
    await _db.into(_db.menuSnapshots).insert(
          MenuSnapshotsCompanion(
            vendorUuid: Value(vendorUuid),
            branchUuid: Value(branchUuid),
            payloadJson: Value(payloadJson),
            version: Value(version),
            updatedAt: Value(now),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// Returns the latest snapshot for the given vendor/branch, if any.
  Future<MenuSnapshot?> getSnapshot({
    required String vendorUuid,
    required String branchUuid,
  }) async {
    final query = _db.select(_db.menuSnapshots)
      ..where(
        (tbl) =>
            tbl.vendorUuid.equals(vendorUuid) &
            tbl.branchUuid.equals(branchUuid),
      )
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
      ..limit(1);

    return query.getSingleOrNull();
  }
}

