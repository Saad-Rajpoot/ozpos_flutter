/// API login response wrapper: { "success", "message", "data" }
class LoginResponseModel {
  const LoginResponseModel({
    required this.success,
    this.message,
    this.data,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      data: json['data'] != null
          ? LoginDataModel.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  final bool success;
  final String? message;
  final LoginDataModel? data;
}

/// Login API "data" object: user and token fields
class LoginDataModel {
  const LoginDataModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.vendorUuid,
    required this.vendorName,
    required this.branchUuid,
    required this.branchName,
    required this.token,
  });

  factory LoginDataModel.fromJson(Map<String, dynamic> json) {
    return LoginDataModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
      vendorUuid: json['vendor_uuid'] as String? ?? '',
      vendorName: json['vendor_name'] as String? ?? '',
      branchUuid: json['branch_uuid'] as String? ?? '',
      branchName: json['branch_name'] as String? ?? '',
      token: json['token'] as String? ?? '',
    );
  }

  final int id;
  final String name;
  final String email;
  final String role;
  final String vendorUuid;
  final String vendorName;
  final String branchUuid;
  final String branchName;
  final String token;
}
