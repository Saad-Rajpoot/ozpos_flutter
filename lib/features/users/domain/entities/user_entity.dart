import 'package:equatable/equatable.dart';

/// User entity for user management
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String addressType; // Required: 'Home', 'Work', or 'Other'
  final String address; // Required full address
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    String? addressType,
    required this.address,
    required this.createdAt,
    this.lastLoginAt,
  }) : addressType = addressType ?? 'Home';

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

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? addressType,
    String? address,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      addressType: addressType ?? this.addressType,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
