enum OrderType {
  dineIn('dine_in'),
  takeaway('takeaway'),
  delivery('delivery'),
  driveThrough('drive_through');

  const OrderType(this.value);
  final String value;

  static OrderType fromString(String value) {
    return OrderType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => OrderType.dineIn,
    );
  }
}
