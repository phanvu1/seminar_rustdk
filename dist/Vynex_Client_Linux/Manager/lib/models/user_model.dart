import '../core/constants.dart';

class UserModel {
  final int userId;
  final String username;
  final String fullName;
  final UserRole role;
  final int? departmentId;
  final String? departmentName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String status; // active, inactive, locked
  final DateTime? lastLogin;

  UserModel({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.role,
    this.departmentId,
    this.departmentName,
    this.email,
    this.phone,
    this.avatarUrl,
    this.status = 'active',
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    UserRole parsedRole = UserRole.employee;
    if (json['role_id'] != null) {
      final rid = json['role_id'];
      if (rid == 1) {
        parsedRole = UserRole.admin;
      } else if (rid == 2) {
        parsedRole = UserRole.it;
      } else {
        parsedRole = UserRole.employee;
      }
    } else if (json['role'] != null) {
      parsedRole = UserRoleExtension.fromString(json['role'].toString());
    }

    return UserModel(
      userId: json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0,
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? json['name'] ?? json['username'] ?? '',
      role: parsedRole,
      departmentId: json['department_id'] is int ? json['department_id'] : int.tryParse(json['department_id']?.toString() ?? ''),
      departmentName: json['department_name'],
      email: json['email'],
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      status: json['status'] ?? 'active',
      lastLogin: json['last_login'] != null ? DateTime.tryParse(json['last_login'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'full_name': fullName,
      'role_id': role.roleId,
      'department_id': departmentId,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'status': status,
    };
  }

  UserModel copyWith({
    String? fullName,
    UserRole? role,
    int? departmentId,
    String? departmentName,
    String? email,
    String? phone,
    String? status,
  }) {
    return UserModel(
      userId: userId,
      username: username,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl,
      status: status ?? this.status,
      lastLogin: lastLogin,
    );
  }
}
