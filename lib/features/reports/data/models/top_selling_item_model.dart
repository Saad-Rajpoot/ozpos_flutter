import 'package:equatable/equatable.dart';
import '../../domain/entities/reports_entities.dart';

/// Model class for TopSellingItem JSON serialization/deserialization
class TopSellingItemModel extends Equatable {
  final String emoji;
  final String name;
  final String revenue;
  final String rank;
  final String orders;

  const TopSellingItemModel({
    required this.emoji,
    required this.name,
    required this.revenue,
    required this.rank,
    required this.orders,
  });

  /// Convert JSON to TopSellingItemModel
  factory TopSellingItemModel.fromJson(Map<String, dynamic> json) {
    return TopSellingItemModel(
      emoji: json['emoji'] as String,
      name: json['name'] as String,
      revenue: json['revenue'] as String,
      rank: json['rank'] as String,
      orders: json['orders'] as String,
    );
  }

  /// Convert TopSellingItemModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'name': name,
      'revenue': revenue,
      'rank': rank,
      'orders': orders,
    };
  }

  /// Convert TopSellingItemModel to TopSellingItem entity
  TopSellingItem toEntity() {
    return TopSellingItem(
      emoji: emoji,
      name: name,
      revenue: revenue,
      rank: rank,
      orders: orders,
    );
  }

  /// Create TopSellingItemModel from TopSellingItem entity
  factory TopSellingItemModel.fromEntity(TopSellingItem entity) {
    return TopSellingItemModel(
      emoji: entity.emoji,
      name: entity.name,
      revenue: entity.revenue,
      rank: entity.rank,
      orders: entity.orders,
    );
  }

  @override
  List<Object?> get props => [emoji, name, revenue, rank, orders];
}
