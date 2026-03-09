/// Result of a successful book-order API call.
class BookOrderResult {
  final int orderId;
  final String displayId;
  final String referenceNo;
  final String status;

  const BookOrderResult({
    required this.orderId,
    required this.displayId,
    required this.referenceNo,
    required this.status,
  });
}
