import 'dart:math';

import 'package:drift/drift.dart';

import '../constants/app_constants.dart';
import 'pos_database.dart';

/// DAO for managing the sync outbox and basic retry/backoff.
class SyncOutboxDao {
  SyncOutboxDao(this._db);

  final PosDatabase _db;

  Future<int> enqueue({
    required String type,
    required String method,
    required String path,
    String? bodyJson,
    String? correlationId,
  }) async {
    final entry = SyncOutboxEntriesCompanion.insert(
      type: type,
      method: method,
      path: path,
      bodyJson: Value(bodyJson),
      correlationId: Value(correlationId),
    );
    return _db.into(_db.syncOutboxEntries).insert(entry);
  }

  /// Returns all entries that are ready to be processed at [now].
  Future<List<SyncOutboxEntry>> pendingEntries(DateTime now) async {
    final query = _db.select(_db.syncOutboxEntries)
      ..where(
        (tbl) =>
            tbl.status.equals('pending') &
            tbl.nextRetryAt.isSmallerOrEqualValue(now),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]);
    return query.get();
  }

  Future<void> markInProgress(int id) async {
    await (_db.update(_db.syncOutboxEntries)..where((tbl) => tbl.id.equals(id)))
        .write(
      SyncOutboxEntriesCompanion(
        status: const Value('in_progress'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markCompleted(int id) async {
    await (_db.update(_db.syncOutboxEntries)..where((tbl) => tbl.id.equals(id)))
        .write(
      SyncOutboxEntriesCompanion(
        status: const Value('completed'),
        updatedAt: Value(DateTime.now()),
        lastError: const Value(null),
      ),
    );
  }

  Future<void> markFailedWithBackoff({
    required int id,
    required int currentRetryCount,
    required String error,
  }) async {
    final nextRetryCount = currentRetryCount + 1;
    final baseSeconds = AppConstants.offlineRecheckInterval.inSeconds;
    final factor = pow(2, min(nextRetryCount, 5)).toInt();
    final backoffSeconds = baseSeconds * factor;
    final nextRetryAt =
        DateTime.now().add(Duration(seconds: backoffSeconds.clamp(30, 1800)));

    await (_db.update(_db.syncOutboxEntries)..where((tbl) => tbl.id.equals(id)))
        .write(
      SyncOutboxEntriesCompanion(
        status: const Value('pending'),
        retryCount: Value(nextRetryCount),
        nextRetryAt: Value(nextRetryAt),
        updatedAt: Value(DateTime.now()),
        lastError: Value(error),
      ),
    );
  }
}

