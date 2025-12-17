import 'package:equatable/equatable.dart';

import '../../domain/entities/customer_display_loyalty_entity.dart';

class CustomerDisplayLoyaltyModel extends Equatable {
  final int pointsEarned;
  final int currentBalance;
  final bool showLoyalty;

  const CustomerDisplayLoyaltyModel({
    required this.pointsEarned,
    required this.currentBalance,
    this.showLoyalty = true,
  });

  factory CustomerDisplayLoyaltyModel.fromJson(Map<String, dynamic> json) {
    return CustomerDisplayLoyaltyModel(
      pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
      currentBalance: (json['currentBalance'] as num?)?.toInt() ?? 0,
      showLoyalty: json['showLoyalty'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pointsEarned': pointsEarned,
      'currentBalance': currentBalance,
      'showLoyalty': showLoyalty,
    };
  }

  CustomerDisplayLoyaltyEntity toEntity() {
    return CustomerDisplayLoyaltyEntity(
      pointsEarned: pointsEarned,
      currentBalance: currentBalance,
      showLoyalty: showLoyalty,
    );
  }

  factory CustomerDisplayLoyaltyModel.fromEntity(
      CustomerDisplayLoyaltyEntity entity) {
    return CustomerDisplayLoyaltyModel(
      pointsEarned: entity.pointsEarned,
      currentBalance: entity.currentBalance,
      showLoyalty: entity.showLoyalty,
    );
  }

  @override
  List<Object?> get props => [pointsEarned, currentBalance, showLoyalty];
}
