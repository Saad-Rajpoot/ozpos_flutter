/// Response models for the ozfoodz book-order API.

class BookOrderSuccessResponse {
  final bool ok;
  final bool success;
  final String message;
  final int orderId;
  final String displayId;
  final String referenceNo;
  final String status;

  const BookOrderSuccessResponse({
    required this.ok,
    required this.success,
    required this.message,
    required this.orderId,
    required this.displayId,
    required this.referenceNo,
    required this.status,
  });

  factory BookOrderSuccessResponse.fromJson(Map<String, dynamic> json) {
    return BookOrderSuccessResponse(
      ok: json['ok'] as bool? ?? false,
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      orderId: json['order_id'] as int? ?? 0,
      displayId: json['display_id'] as String? ?? '',
      referenceNo: json['reference_no'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }
}

class BookOrderErrorResponse {
  final bool ok;
  final bool success;
  final String message;
  final String error;

  const BookOrderErrorResponse({
    required this.ok,
    required this.success,
    required this.message,
    required this.error,
  });

  factory BookOrderErrorResponse.fromJson(Map<String, dynamic> json) {
    return BookOrderErrorResponse(
      ok: json['ok'] as bool? ?? false,
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      error: json['error'] as String? ?? 'Unknown error',
    );
  }
}
