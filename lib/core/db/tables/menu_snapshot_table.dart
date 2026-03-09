import 'package:drift/drift.dart';

/// Stores a serialized snapshot of the Single Vendor menu response
/// for a given vendor/branch pair. This allows offline menu loading
/// without changing existing menu mapping or UI.
class MenuSnapshots extends Table {
  /// Vendor UUID from auth session.
  TextColumn get vendorUuid => text()();

  /// Branch UUID from auth session.
  TextColumn get branchUuid => text()();

  /// Full JSON payload of the single-vendor response.
  TextColumn get payloadJson => text()();

  /// Optional version string from API meta, if provided.
  TextColumn get version => text().nullable()();

  /// Last time this snapshot was updated.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {vendorUuid, branchUuid};
}

