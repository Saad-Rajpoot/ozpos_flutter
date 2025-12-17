import '../../../../core/constants/app_constants.dart';

/// Domain service for cart calculations
/// This encapsulates business logic for cart total calculations including GST
class CartCalculator {
  /// Calculate subtotal from list of line totals
  ///
  /// [lineTotals] - List of line item totals
  ///
  /// Returns the subtotal (sum of all line item totals)
  static double calculateSubtotal(List<double> lineTotals) {
    return lineTotals.fold(0.0, (sum, total) => sum + total);
  }

  /// Calculate subtotal from list of cart line items
  ///
  /// This method accepts any type that has a `lineTotal` property (getter or field)
  /// [items] - List of cart line items (e.g., CartLineItem from presentation layer)
  ///
  /// Returns the subtotal (sum of all line item totals)
  static double calculateSubtotalFromItems<T>(List<T> items) {
    // Extract lineTotals from items
    // Works with any object that has a lineTotal property (getter or field)
    return items.fold(
      0.0,
      (sum, item) {
        // Use dynamic access to get lineTotal property
        // This works for objects like CartLineItem that have lineTotal getter
        final lineTotal = (item as dynamic).lineTotal as double? ?? 0.0;
        return sum + lineTotal;
      },
    );
  }

  /// Calculate GST (Goods and Services Tax) amount
  ///
  /// [subtotal] - The subtotal amount before tax
  /// [taxRate] - The tax rate (defaults to AppConstants.gstRate)
  ///
  /// Returns the GST amount
  static double calculateGst(double subtotal, {double? taxRate}) {
    final rate = taxRate ?? AppConstants.gstRate;
    return subtotal * rate;
  }

  /// Calculate total amount including GST
  ///
  /// [subtotal] - The subtotal amount before tax
  /// [taxRate] - Optional tax rate (defaults to AppConstants.gstRate)
  ///
  /// Returns the total amount (subtotal + GST)
  static double calculateTotal(double subtotal, {double? taxRate}) {
    final gst = calculateGst(subtotal, taxRate: taxRate);
    return subtotal + gst;
  }

  /// Calculate all cart totals (subtotal, GST, and total)
  ///
  /// [subtotal] - The subtotal amount before tax
  /// [taxRate] - Optional tax rate (defaults to AppConstants.gstRate)
  ///
  /// Returns a map with 'subtotal', 'gst', and 'total' keys
  static Map<String, double> calculateAllTotals(
    double subtotal, {
    double? taxRate,
  }) {
    final adjustedSubtotal = ensureNonNegative(subtotal);
    final gst = calculateGst(adjustedSubtotal, taxRate: taxRate);
    final total = adjustedSubtotal + gst;

    return {
      'subtotal': adjustedSubtotal,
      'gst': gst,
      'total': total,
    };
  }

  /// Ensure subtotal is not negative (minimum 0.0)
  ///
  /// [subtotal] - The subtotal amount
  ///
  /// Returns the adjusted subtotal (minimum 0.0)
  static double ensureNonNegative(double subtotal) {
    return subtotal <= 0.0 ? 0.0 : subtotal;
  }
}
