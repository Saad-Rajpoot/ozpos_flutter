import 'package:equatable/equatable.dart';
import '../../domain/entities/combo_entity.dart';
import 'combo_slot_model.dart';
import 'combo_pricing_model.dart';
import 'combo_availability_model.dart';
import 'combo_limits_model.dart';

/// Model class for Combo JSON serialization/deserialization
class ComboModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? image;
  final String? categoryTag;
  final int? pointsReward;
  final ComboStatus status;
  final List<ComboSlotModel> slots;
  final ComboPricingModel pricing;
  final ComboAvailabilityModel availability;
  final ComboLimitsModel limits;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool hasUnsavedChanges;

  const ComboModel({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    this.categoryTag,
    this.pointsReward,
    required this.status,
    required this.slots,
    required this.pricing,
    required this.availability,
    required this.limits,
    required this.createdAt,
    required this.updatedAt,
    this.hasUnsavedChanges = false,
  });

  /// Convert JSON to ComboModel
  factory ComboModel.fromJson(Map<String, dynamic> json) {
    return ComboModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String?,
      categoryTag: json['categoryTag'] as String?,
      pointsReward: json['pointsReward'] as int?,
      status: ComboStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      slots:
          (json['slots'] as List<dynamic>?)
              ?.map(
                (slot) => ComboSlotModel.fromJson(slot as Map<String, dynamic>),
              )
              .toList() ??
          <ComboSlotModel>[],
      pricing: ComboPricingModel.fromJson(
        json['pricing'] as Map<String, dynamic>,
      ),
      availability: ComboAvailabilityModel.fromJson(
        json['availability'] as Map<String, dynamic>,
      ),
      limits: ComboLimitsModel.fromJson(json['limits'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      hasUnsavedChanges: json['hasUnsavedChanges'] as bool? ?? false,
    );
  }

  /// Convert ComboModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'categoryTag': categoryTag,
      'pointsReward': pointsReward,
      'status': status.toString().split('.').last,
      'slots': slots.map((slot) => slot.toJson()).toList(),
      'pricing': pricing.toJson(),
      'availability': availability.toJson(),
      'limits': limits.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'hasUnsavedChanges': hasUnsavedChanges,
    };
  }

  /// Convert ComboModel to ComboEntity
  ComboEntity toEntity() {
    return ComboEntity(
      id: id,
      name: name,
      description: description,
      image: image,
      categoryTag: categoryTag,
      pointsReward: pointsReward,
      status: status,
      slots: slots.map((slot) => slot.toEntity()).toList(),
      pricing: pricing.toEntity(),
      availability: availability.toEntity(),
      limits: limits.toEntity(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      hasUnsavedChanges: hasUnsavedChanges,
    );
  }

  /// Create ComboModel from ComboEntity
  factory ComboModel.fromEntity(ComboEntity entity) {
    return ComboModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      image: entity.image,
      categoryTag: entity.categoryTag,
      pointsReward: entity.pointsReward,
      status: entity.status,
      slots: entity.slots
          .map((slot) => ComboSlotModel.fromEntity(slot))
          .toList(),
      pricing: ComboPricingModel.fromEntity(entity.pricing),
      availability: ComboAvailabilityModel.fromEntity(entity.availability),
      limits: ComboLimitsModel.fromEntity(entity.limits),
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      hasUnsavedChanges: entity.hasUnsavedChanges,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    image,
    categoryTag,
    pointsReward,
    status,
    slots,
    pricing,
    availability,
    limits,
    createdAt,
    updatedAt,
    hasUnsavedChanges,
  ];
}
