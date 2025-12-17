import 'package:equatable/equatable.dart';

/// Loyalty program summary displayed on the customer screen
class CustomerDisplayLoyaltyEntity extends Equatable {
  final int pointsEarned;
  final int currentBalance;
  final bool showLoyalty;

  const CustomerDisplayLoyaltyEntity({
    required this.pointsEarned,
    required this.currentBalance,
    this.showLoyalty = true,
  });

  bool get hasBalance => currentBalance > 0;

  bool get hasPointsToEarn => pointsEarned > 0;

  @override
  List<Object?> get props => [pointsEarned, currentBalance, showLoyalty];
}
