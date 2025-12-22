import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

/// Model class for User JSON serialization/deserialization
class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String addressType; // Required: 'Home', 'Work', or 'Other'
  final String address; // Required full address
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    String? addressType,
    required this.address,
    required this.createdAt,
    this.lastLoginAt,
  }) : addressType = addressType ?? 'Home';

  /// Convert JSON to UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      addressType: json['addressType'] as String? ?? 
                   json['address_type'] as String? ?? 
                   'Home',
      address: json['address'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : DateTime.now(),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : json['last_login_at'] != null
              ? DateTime.parse(json['last_login_at'] as String)
              : null,
    );
  }

  /// Convert UserModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'addressType': addressType,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  /// Convert UserModel to UserEntity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      addressType: addressType,
      address: address,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
    );
  }

  /// Create UserModel from UserEntity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      addressType: entity.addressType,
      address: entity.address,
      createdAt: entity.createdAt,
      lastLoginAt: entity.lastLoginAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        addressType,
        address,
        createdAt,
        lastLoginAt,
      ];
}
