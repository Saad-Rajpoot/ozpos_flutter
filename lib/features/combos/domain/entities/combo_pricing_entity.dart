import 'package:equatable/equatable.dart';

enum PricingMode {
  fixed,        // Set a specific combo price
  percentage,   // Percentage off sum of components
  amount,       // Fixed amount off sum of components
  mixAndMatch,  // Special rules like "2 for $10" or "Save 15% on any 2"
}

class ComboPricingEntity extends Equatable {
  final PricingMode mode;
  
  // For fixed pricing
  final double? fixedPrice;
  
  // For percentage off
  final double? percentOff; // 0-100
  
  // For amount off
  final double? amountOff;
  
  // For mix-and-match
  final String? mixCategoryId;    // Category for mix rules (e.g., "pizzas")
  final String? mixCategoryName;  // Cached name for display
  final int? mixQuantity;         // Quantity needed (e.g., 2 in "2 for $10")
  final double? mixPrice;         // Price for the bundle (e.g., $10 in "2 for $10")
  final double? mixPercentOff;    // Alternative: percent off for mix (e.g., 15% in "Save 15% on any 2")
  
  // Computed at creation
  final double totalIfSeparate;   // Sum of component prices
  final double finalPrice;        // Price after discount
  final double savings;           // Amount saved

  const ComboPricingEntity({
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

  // Factory constructors for each pricing mode
  
  static ComboPricingEntity fixed({
    required double fixedPrice,
    required double totalIfSeparate,
  }) {
    final savings = (totalIfSeparate - fixedPrice).clamp(0.0, double.infinity);
    return ComboPricingEntity(
      mode: PricingMode.fixed,
      fixedPrice: fixedPrice,
      totalIfSeparate: totalIfSeparate,
      finalPrice: fixedPrice,
      savings: savings,
    );
  }
  
  static ComboPricingEntity percentage({
    required double percentOff,
    required double totalIfSeparate,
  }) {
    final discount = totalIfSeparate * (percentOff / 100);
    final finalPrice = (totalIfSeparate - discount).clamp(0.0, double.infinity);
    return ComboPricingEntity(
      mode: PricingMode.percentage,
      percentOff: percentOff,
      totalIfSeparate: totalIfSeparate,
      finalPrice: finalPrice,
      savings: discount,
    );
  }
  
  static ComboPricingEntity amount({
    required double amountOff,
    required double totalIfSeparate,
  }) {
    final discount = amountOff.clamp(0.0, totalIfSeparate);
    final finalPrice = totalIfSeparate - discount;
    return ComboPricingEntity(
      mode: PricingMode.amount,
      amountOff: amountOff,
      totalIfSeparate: totalIfSeparate,
      finalPrice: finalPrice,
      savings: discount,
    );
  }
  
  static ComboPricingEntity mixAndMatch({
    String? categoryId,
    String? categoryName,
    required int quantity,
    double? fixedPrice,
    double? percentOff,
    required double totalIfSeparate,
  }) {
    double finalPrice;
    double savings;
    
    if (fixedPrice != null) {
      // "2 for $10" style
      finalPrice = fixedPrice;
      savings = (totalIfSeparate - fixedPrice).clamp(0.0, double.infinity);
    } else if (percentOff != null) {
      // "Save 15% on any 2" style
      final discount = totalIfSeparate * (percentOff / 100);
      finalPrice = (totalIfSeparate - discount).clamp(0.0, double.infinity);
      savings = discount;
    } else {
      // Default to no discount
      finalPrice = totalIfSeparate;
      savings = 0.0;
    }
    
    return ComboPricingEntity(
      mode: PricingMode.mixAndMatch,
      mixCategoryId: categoryId,
      mixCategoryName: categoryName,
      mixQuantity: quantity,
      mixPrice: fixedPrice,
      mixPercentOff: percentOff,
      totalIfSeparate: totalIfSeparate,
      finalPrice: finalPrice,
      savings: savings,
    );
  }

  // Computed properties
  
  bool get hasDiscount => savings > 0;
  
  double get discountPercentage {
    if (totalIfSeparate == 0) return 0.0;
    return (savings / totalIfSeparate) * 100;
  }
  
  String get savingsText {
    if (savings > 0) {
      return 'SAVE \$${savings.toStringAsFixed(2)}';
    }
    return '';
  }
  
  String get pricingDescription {
    switch (mode) {
      case PricingMode.fixed:
        return 'Fixed Price: \$${fixedPrice!.toStringAsFixed(2)}';
        
      case PricingMode.percentage:
        return '${percentOff!.toInt()}% Off (Save \$${savings.toStringAsFixed(2)})';
        
      case PricingMode.amount:
        return '\$${amountOff!.toStringAsFixed(2)} Off';
        
      case PricingMode.mixAndMatch:
        if (mixPrice != null) {
          return '$mixQuantity for \$${mixPrice!.toStringAsFixed(2)}';
        } else if (mixPercentOff != null) {
          return 'Save ${mixPercentOff!.toInt()}% on any $mixQuantity';
        } else {
          return 'Mix & Match Deal';
        }
    }
  }
  
  String get breakdownText {
    return 'Total separately: \$${totalIfSeparate.toStringAsFixed(2)}\n'
           'Combo price: \$${finalPrice.toStringAsFixed(2)}\n'
           'You save: \$${savings.toStringAsFixed(2)}';
  }

  List<String> get validationErrors {
    final List<String> errors = [];
    
    switch (mode) {
      case PricingMode.fixed:
        if (fixedPrice == null || fixedPrice! <= 0) {
          errors.add('Fixed price must be greater than 0');
        }
        break;
        
      case PricingMode.percentage:
        if (percentOff == null || percentOff! <= 0 || percentOff! >= 100) {
          errors.add('Percentage must be between 1-99%');
        }
        break;
        
      case PricingMode.amount:
        if (amountOff == null || amountOff! <= 0) {
          errors.add('Amount off must be greater than 0');
        }
        if (amountOff != null && amountOff! > totalIfSeparate) {
          errors.add('Amount off cannot exceed total component price');
        }
        break;
        
      case PricingMode.mixAndMatch:
        if (mixQuantity == null || mixQuantity! < 2) {
          errors.add('Mix quantity must be at least 2');
        }
        
        if (mixPrice == null && mixPercentOff == null) {
          errors.add('Mix pricing must specify either fixed price or percentage off');
        }
        
        if (mixPrice != null && mixPrice! <= 0) {
          errors.add('Mix price must be greater than 0');
        }
        
        if (mixPercentOff != null && (mixPercentOff! <= 0 || mixPercentOff! >= 100)) {
          errors.add('Mix percentage must be between 1-99%');
        }
        break;
    }
    
    return errors;
  }

  ComboPricingEntity copyWith({
    PricingMode? mode,
    double? fixedPrice,
    double? percentOff,
    double? amountOff,
    String? mixCategoryId,
    String? mixCategoryName,
    int? mixQuantity,
    double? mixPrice,
    double? mixPercentOff,
    double? totalIfSeparate,
    double? finalPrice,
    double? savings,
  }) {
    return ComboPricingEntity(
      mode: mode ?? this.mode,
      fixedPrice: fixedPrice ?? this.fixedPrice,
      percentOff: percentOff ?? this.percentOff,
      amountOff: amountOff ?? this.amountOff,
      mixCategoryId: mixCategoryId ?? this.mixCategoryId,
      mixCategoryName: mixCategoryName ?? this.mixCategoryName,
      mixQuantity: mixQuantity ?? this.mixQuantity,
      mixPrice: mixPrice ?? this.mixPrice,
      mixPercentOff: mixPercentOff ?? this.mixPercentOff,
      totalIfSeparate: totalIfSeparate ?? this.totalIfSeparate,
      finalPrice: finalPrice ?? this.finalPrice,
      savings: savings ?? this.savings,
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