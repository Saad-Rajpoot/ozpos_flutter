import 'package:equatable/equatable.dart';

/// User entity for user management
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.createdAt,
    this.lastLoginAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        createdAt,
        lastLoginAt,
      ];

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}
