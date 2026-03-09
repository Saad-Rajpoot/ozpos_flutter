import '../constants/app_constants.dart';

/// Branch tax configuration used for cart/checkout calculations.
/// Populated from single-vendor API branch.tax when menu is loaded.
class BranchTaxConfig {
  final bool enabled;
  final String name;
  final String type; // e.g. "percentage"
  /// Tax value (e.g. 10 for 10%, 2.5 for 2.5%). For percentage, rate = taxValue / 100.
  final double taxValue;
  /// When true, displayed prices include tax; subtotal is tax-inclusive.
  final bool taxInclusive;

  const BranchTaxConfig({
    this.enabled = true,
    this.name = 'GST',
    this.type = 'percentage',
    this.taxValue = 10.0,
    this.taxInclusive = true,
  });

  /// Tax rate as decimal (e.g. 0.10 for 10%, 0.025 for 2.5%).
  double get rate => type == 'percentage' ? (taxValue / 100.0) : 0.0;

  /// Formatted percentage string (e.g. "10" or "2.5" - no trailing .0 for whole numbers).
  String get _taxValueFormatted {
    if (taxValue == taxValue.roundToDouble()) {
      return taxValue.round().toString();
    }
    return taxValue.toString();
  }

  /// Display label e.g. "GST2 (2.5%) (incl.)" or "GST (10%) (excl.)".
  String get displayLabel {
    final ratePart = '$name ($_taxValueFormatted%)';
    final inclExcl = taxInclusive ? ' (incl.)' : ' (excl.)';
    return '$ratePart$inclExcl';
  }

  /// Default config when API does not provide tax (fallback to AppConstants.gstRate).
  static BranchTaxConfig get defaultConfig => BranchTaxConfig(
        enabled: true,
        name: 'GST',
        type: 'percentage',
        taxValue: AppConstants.gstRate * 100,
        taxInclusive: true,
      );
}

/// Global store for current branch tax config. Set when single-vendor menu is loaded.
class BranchTaxConfigStore {
  BranchTaxConfigStore._();
  static final BranchTaxConfigStore _instance = BranchTaxConfigStore._();
  static BranchTaxConfigStore get instance => _instance;

  BranchTaxConfig _config = BranchTaxConfig.defaultConfig;

  BranchTaxConfig get config => _config;

  void update(BranchTaxConfig config) {
    _config = config;
  }

  void updateFromApi({
    bool? taxEnable,
    String? taxName,
    String? taxType,
    double? taxValue,
    bool? taxInclusive,
  }) {
    _config = BranchTaxConfig(
      enabled: taxEnable ?? true,
      name: taxName ?? 'GST',
      type: taxType ?? 'percentage',
      taxValue: taxValue ?? 10.0,
      taxInclusive: taxInclusive ?? true,
    );
  }

  void clear() {
    _config = BranchTaxConfig.defaultConfig;
  }
}
