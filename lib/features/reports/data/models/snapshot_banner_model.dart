import 'package:equatable/equatable.dart';
import '../../domain/entities/reports_entities.dart';

/// Model class for SnapshotBanner JSON serialization/deserialization
class SnapshotBannerModel extends Equatable {
  final String title;
  final String summary;

  const SnapshotBannerModel({required this.title, required this.summary});

  /// Convert JSON to SnapshotBannerModel
  factory SnapshotBannerModel.fromJson(Map<String, dynamic> json) {
    return SnapshotBannerModel(
      title: json['title'] as String,
      summary: json['summary'] as String,
    );
  }

  /// Convert SnapshotBannerModel to JSON
  Map<String, dynamic> toJson() {
    return {'title': title, 'summary': summary};
  }

  /// Convert SnapshotBannerModel to SnapshotBanner entity
  SnapshotBanner toEntity() {
    return SnapshotBanner(title: title, summary: summary);
  }

  /// Create SnapshotBannerModel from SnapshotBanner entity
  factory SnapshotBannerModel.fromEntity(SnapshotBanner entity) {
    return SnapshotBannerModel(title: entity.title, summary: entity.summary);
  }

  @override
  List<Object?> get props => [title, summary];
}
