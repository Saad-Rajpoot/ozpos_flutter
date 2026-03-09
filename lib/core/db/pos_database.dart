import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';

import '../config/app_config.dart';
import 'tables/menu_snapshot_table.dart';
import 'tables/orders_tables.dart';
import 'tables/sync_outbox_table.dart';

part 'pos_database.g.dart';

/// Drift database for POS offline-first storage.
///
/// Phase 2+: tables for menu, orders, and sync are added incrementally.
@DriftDatabase(
  tables: [
    MenuSnapshots,
    DbOrders,
    DbOrderItems,
    SyncOutboxEntries,
  ],
)
class PosDatabase extends _$PosDatabase {
  PosDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAllTables(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            // Orders and sync tables were added after initial release.
            await m.createTable(dbOrders);
            await m.createTable(dbOrderItems);
            await m.createTable(syncOutboxEntries);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(
    () async => SqfliteQueryExecutor.inDatabaseFolder(
      path: 'ozpos_pos.db',
      logStatements: AppConfig.instance.logDatabaseQueries,
    ),
  );
}

