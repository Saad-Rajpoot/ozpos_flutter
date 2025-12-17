import 'package:equatable/equatable.dart';
import '../../domain/entities/combo_pricing_entity.dart';

/// Model class for ComboPricing JSON serialization/deserialization
class ComboPricingModel extends Equatable {
  final PricingMode mode;
  final double? fixedPrice;
  final double? percentOff;
  final double? amountOff;
  final String? mixCategoryId;
  final String? mixCategoryName;
  final int? mixQuantity;
  final double? mixPrice;
  final double? mixPercentOff;
  final double totalIfSeparate;
  final double finalPrice;
  final double savings;

  const ComboPricingModel({
    required this.mode,
    this.fixedPrice,
    this.percentOff,
    this.amountOff,
    this.mixCategoryId,
    this.mixCategoryName,
    this.mixQuantity,
    this.mixPrice,
    this.mixPercentOff,
    required this.totalIfSeparate,
    required this.finalPrice,
    required this.savings,
  });

  /// Convert JSON to ComboPricingModel
  factory ComboPricingModel.fromJson(Map<String, dynamic> json) {
    return ComboPricingModel(
      mode: PricingMode.values.firstWhere(
        (e) => e.toString().split('.').last == json['mode'],
      ),
      fixedPrice: (json['fixedPrice'] as num?)?.toDouble(),
      percentOff: (json['percentOff'] as num?)?.toDouble(),
      amountOff: (json['amountOff'] as num?)?.toDouble(),
      mixCategoryId: json['mixCategoryId'] as String?,
      mixCategoryName: json['mixCategoryName'] as String?,
      mixQuantity: json['mixQuantity'] as int?,
      mixPrice: (json['mixPrice'] as num?)?.toDouble(),
      mixPercentOff: (json['mixPercentOff'] as num?)?.toDouble(),
      totalIfSeparate: (json['totalIfSeparate'] as num?)?.toDouble() ?? 0.0,
      finalPrice: (json['finalPrice'] as num?)?.toDouble() ?? 0.0,
      savings: (json['savings'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert ComboPricingModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'mode': mode.toString().split('.').last,
      'fixedPrice': fixedPrice,
      'percentOff': percentOff,
      'amountOff': amountOff,
      'mixCategoryId': mixCategoryId,
      'mixCategoryName': mixCategoryName,
      'mixQuantity': mixQuantity,
      'mixPrice': mixPrice,
      'mixPercentOff': mixPercentOff,
      'totalIfSeparate': totalIfSeparate,
      'finalPrice': finalPrice,
      'savings': savings,
    };
  }

  /// Convert ComboPricingModel to ComboPricingEntity
  ComboPricingEntity toEntity() {
    return ComboPricingEntity(
      mode: mode,
      fixedPrice: fixedPrice,
      percentOff: percentOff,
      amountOff: amountOff,
      mixCategoryId: mixCategoryId,
      mixCategoryName: mixCategoryName,
      mixQuantity: mixQuantity,
      mixPrice: mixPrice,
      mixPercentOff: mixPercentOff,
      totalIfSeparate: totalIfSeparate,
      finalPrice: finalPrice,
      savings: savings,
    );
  }

  /// Create ComboPricingModel from ComboPricingEntity
  factory ComboPricingModel.fromEntity(ComboPricingEntity entity) {
    return ComboPricingModel(
      mode: entity.mode,
      fixedPrice: entity.fixedPrice,
      percentOff: entity.percentOff,
      amountOff: entity.amountOff,
      mixCategoryId: entity.mixCategoryId,
      mixCategoryName: entity.mixCategoryName,
      mixQuantity: entity.mixQuantity,
      mixPrice: entity.mixPrice,
      mixPercentOff: entity.mixPercentOff,
      totalIfSeparate: entity.totalIfSeparate,
      finalPrice: entity.finalPrice,
      savings: entity.savings,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    fixedPrice,
    percentOff,
    amountOff,
    mixCategoryId,
    mixCategoryName,
    mixQuantity,
    mixPrice,
    mixPercentOff,
    totalIfSeparate,
    finalPrice,
    savings,
  ];
}
