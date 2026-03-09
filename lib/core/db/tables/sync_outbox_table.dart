import 'package:drift/drift.dart';

/// Generic sync outbox for pending mutations that must be sent to the API.
class SyncOutboxEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Logical type of mutation, e.g. 'book_order', 'process_payment'.
  TextColumn get type => text()();

  /// HTTP method to use when replaying (GET/POST/PATCH/etc.).
  TextColumn get method => text()();

  /// Relative path for ApiClient, e.g. 'orders/book-order'.
  TextColumn get path => text()();

  /// JSON-encoded request body (if any).
  TextColumn get bodyJson => text().nullable()();

  /// Optional idempotency/correlation id used to de-duplicate on server.
  TextColumn get correlationId => text().nullable()();

  /// Current status: 'pending', 'in_progress', 'failed', 'completed'.
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// Number of retries attempted so far.
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  /// Earliest time at which this entry may be retried.
  DateTimeColumn get nextRetryAt => dateTime().withDefault(currentDateAndTime)();

  /// Last error message, if any.
  TextColumn get lastError => text().nullable()();

  /// When this entry was created.
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// When this entry was last updated.
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

