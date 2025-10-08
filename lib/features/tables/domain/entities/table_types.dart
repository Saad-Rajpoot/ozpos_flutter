import 'table_entity.dart';

// Re-export TableStatus from the entity file to make it available
export 'table_entity.dart' show TableStatus;

enum TableArea { main, tens, twenties, patio }

class TableData {
  final String number;
  final TableStatus status;
  final TableArea area;
  final String? serverTag;
  final double? amount;
  final Duration? elapsedTime;
  final int? guests;
  final String? orderId;
  final int? items;
  final String? waiter;
  final String? notes;

  const TableData({
    required this.number,
    required this.status,
    required this.area,
    this.serverTag,
    this.amount,
    this.elapsedTime,
    this.guests,
    this.orderId,
    this.items,
    this.waiter,
    this.notes,
  });

  factory TableData.fromEntity(TableEntity entity) {
    return TableData(
      number: entity.number,
      status: entity.status,
      area: _parseAreaFromNumber(entity.number),
      serverTag: entity.serverName,
      amount: entity.currentBill,
      elapsedTime: null, // This would need to be calculated based on order time
      guests: null, // This would need to be derived from order data
      orderId: entity.orderId,
      items: null, // This would need to be derived from order data
      waiter: entity.serverName,
      notes: null, // This would need to be derived from order data
    );
  }

  static TableArea _parseAreaFromNumber(String number) {
    final num = int.tryParse(number) ?? 0;
    if (num >= 10 && num < 20) return TableArea.tens;
    if (num >= 20 && num < 30) return TableArea.twenties;
    if (num >= 100) return TableArea.patio;
    return TableArea.main;
  }
}
