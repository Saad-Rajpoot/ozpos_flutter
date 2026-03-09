import '../../../../core/config/branch_tax_config.dart';

/// Domain service for cart calculations.
/// Uses branch tax config from API (tax_enable, tax_name, tax_value, tax_inclusive).
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
    return items.fold(
      0.0,
      (sum, item) {
        final lineTotal = (item as dynamic).lineTotal as double? ?? 0.0;
        return sum + lineTotal;
      },
    );
  }

  /// Tax config used for calculations (reads from BranchTaxConfigStore).
  static BranchTaxConfig get _taxConfig => BranchTaxConfigStore.instance.config;

  /// Calculate tax amount on an exclusive (pre-tax) amount. Used when state already has exclusive subtotal (e.g. copyWith).
  static double calculateGst(double subtotalExclusive, {double? taxRate}) {
    final config = _taxConfig;
    if (!config.enabled) return 0.0;
    final rate = taxRate ?? config.rate;
    return subtotalExclusive * rate;
  }

  /// Calculate total (exclusive + tax) from exclusive subtotal.
  static double calculateTotal(double subtotalExclusive, {double? taxRate}) {
    final gst = calculateGst(subtotalExclusive, taxRate: taxRate);
    return subtotalExclusive + gst;
  }

  /// Calculate all cart totals from the raw sum of line item totals.
  /// Interprets raw amount as tax-inclusive or tax-exclusive per branch config.
  /// Returns map with 'subtotal' (exclusive), 'gst', 'total', and 'taxLabel'.
  static Map<String, double> calculateAllTotals(
    double rawLineTotalsSum, {
    double? taxRate,
  }) {
    final amount = ensureNonNegative(rawLineTotalsSum);
    final config = _taxConfig;
    if (!config.enabled) {
      return {
        'subtotal': amount,
        'gst': 0.0,
        'total': amount,
      };
    }
    final rate = taxRate ?? config.rate;
    double subtotalExclusive;
    double gst;
    double total;
    if (config.taxInclusive) {
      total = amount;
      subtotalExclusive = total / (1.0 + rate);
      gst = total - subtotalExclusive;
    } else {
      subtotalExclusive = amount;
      gst = subtotalExclusive * rate;
      total = subtotalExclusive + gst;
    }
    return {
      'subtotal': subtotalExclusive,
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
