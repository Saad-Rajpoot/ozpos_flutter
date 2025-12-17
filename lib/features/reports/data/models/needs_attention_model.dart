import 'package:equatable/equatable.dart';
import '../../domain/entities/reports_entities.dart';

/// Model class for NeedsAttentionItem JSON serialization/deserialization
class NeedsAttentionItemModel extends Equatable {
  final String emoji;
  final String name;
  final String revenue;
  final String orders;

  const NeedsAttentionItemModel({
    required this.emoji,
    required this.name,
    required this.revenue,
    required this.orders,
  });

  /// Convert JSON to NeedsAttentionItemModel
  factory NeedsAttentionItemModel.fromJson(Map<String, dynamic> json) {
    return NeedsAttentionItemModel(
      emoji: json['emoji'] as String,
      name: json['name'] as String,
      revenue: json['revenue'] as String,
      orders: json['orders'] as String,
    );
  }

  /// Convert NeedsAttentionItemModel to JSON
  Map<String, dynamic> toJson() {
    return {'emoji': emoji, 'name': name, 'revenue': revenue, 'orders': orders};
  }

  /// Convert NeedsAttentionItemModel to NeedsAttentionItem entity
  NeedsAttentionItem toEntity() {
    return NeedsAttentionItem(
      emoji: emoji,
      name: name,
      revenue: revenue,
      orders: orders,
    );
  }

  /// Create NeedsAttentionItemModel from NeedsAttentionItem entity
  factory NeedsAttentionItemModel.fromEntity(NeedsAttentionItem entity) {
    return NeedsAttentionItemModel(
      emoji: entity.emoji,
      name: entity.name,
      revenue: entity.revenue,
      orders: entity.orders,
    );
  }

  @override
  List<Object?> get props => [emoji, name, revenue, orders];
}
