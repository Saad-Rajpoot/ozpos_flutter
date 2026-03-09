import 'package:drift/drift.dart';

/// Main orders table storing flattened fields from [OrderEntity].
class DbOrders extends Table {
  /// Unique order id from backend (or derived).
  TextColumn get id => text()();

  /// Queue/display number shown in UI.
  TextColumn get queueNumber => text()();

  /// Channel name (e.g. "Pickup", "Delivery", "Dine-In", "UberEats").
  TextColumn get channel => text()();

  /// Order type (delivery / takeaway / dinein).
  TextColumn get orderType => text()();

  /// Payment status (paid / unpaid).
  TextColumn get paymentStatus => text()();

  /// Order status (active / completed / cancelled).
  TextColumn get status => text()();

  /// Customer display name.
  TextColumn get customerName => text()();

  /// Optional customer phone.
  TextColumn get customerPhone => text().nullable()();

  /// Subtotal amount.
  RealColumn get subtotal => real()();

  /// Tax amount.
  RealColumn get tax => real()();

  /// Total amount.
  RealColumn get total => real()();

  /// Created at timestamp (UTC).
  DateTimeColumn get createdAt => dateTime()();

  /// Estimated ready/serve time.
  DateTimeColumn get estimatedTime => dateTime()();

  /// Order-level special instructions / notes.
  TextColumn get specialInstructions => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Order items table storing items for each order.
class DbOrderItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Foreign key to [DbOrders.id].
  TextColumn get orderId => text()();

  TextColumn get name => text()();
  IntColumn get quantity => integer()();
  RealColumn get price => real()();

  /// JSON-encoded list of modifier lines ("Category: Selection").
  TextColumn get modifiersJson => text().nullable()();

  /// Item-level instructions.
  TextColumn get instructions => text().nullable()();
}

