import 'package:equatable/equatable.dart';
import '../../domain/entities/addon_management_entities.dart';

/// Model class for AddonItem JSON serialization/deserialization
class AddonItemModel extends Equatable {
  final String id;
  final String name;
  final double basePriceDelta;

  const AddonItemModel({
    required this.id,
    required this.name,
    required this.basePriceDelta,
  });

  /// Convert JSON to AddonItemModel
  factory AddonItemModel.fromJson(Map<String, dynamic> json) {
    return AddonItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      basePriceDelta: (json['basePriceDelta'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert AddonItemModel to JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'basePriceDelta': basePriceDelta};
  }

  /// Convert AddonItemModel to AddonItem entity
  AddonItem toEntity() {
    return AddonItem(id: id, name: name, basePriceDelta: basePriceDelta);
  }

  /// Create AddonItemModel from AddonItem entity
  factory AddonItemModel.fromEntity(AddonItem entity) {
    return AddonItemModel(
      id: entity.id,
      name: entity.name,
      basePriceDelta: entity.basePriceDelta,
    );
  }

  @override
  List<Object?> get props => [id, name, basePriceDelta];
}
