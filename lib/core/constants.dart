import 'package:flutter/material.dart';

class AppConstants {
  // Brand identity
  static const String appName = 'Vynex';
  static const String appFullName = 'Vynex - Hệ thống Quản trị & Hỗ trợ Từ xa';
  static const String appVersion = 'v1.0.0 (Web)';

  // Brand Colors
  static const Color primaryBlue = Color(0xFF0066FF); // Xanh Vynex chủ đạo
  static const Color primaryHover = Color(0xFF0052CC);
  static const Color primaryLight = Color(0xFFE5EFFF);
  static const Color secondaryBlue = Color(0xFF0EA5E9); // Cyan / Sky Blue
  static const Color darkNavBg = Color(0xFF0B132B); // Sidebar Dark
  static const Color darkCardBg = Color(0xFF1E293B);
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCardBg = Colors.white;

  // Status Colors
  static const Color statusOnline = Color(0xFF10B981); // Emerald Green
  static const Color statusOffline = Color(0xFF94A3B8); // Slate
  static const Color statusPending = Color(0xFFF59E0B); // Amber
  static const Color statusInProgress = Color(0xFF3B82F6); // Blue
  static const Color statusCompleted = Color(0xFF10B981); // Green
  static const Color statusRejected = Color(0xFFEF4444); // Red
  static const Color statusUrgent = Color(0xFFDC2626); // Deep Red

  // API Endpoints Config
  static String defaultApiBaseUrl = 'http://localhost:8000';
  static const Duration apiTimeout = Duration(seconds: 4);

  // Storage Keys
  static const String tokenKey = 'vynex_jwt_token';
  static const String currentRoleKey = 'vynex_active_role';
  static const String apiUrlKey = 'vynex_api_base_url';
}

enum UserRole {
  admin,
  it,
  employee,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Quản trị viên (Admin)';
      case UserRole.it:
        return 'Kỹ thuật viên (IT Staff)';
      case UserRole.employee:
        return 'Nhân viên (Employee)';
    }
  }

  String get shortName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.it:
        return 'IT Staff';
      case UserRole.employee:
        return 'Nhân viên';
    }
  }

  int get roleId {
    switch (this) {
      case UserRole.admin:
        return 1;
      case UserRole.it:
        return 2;
      case UserRole.employee:
        return 3;
    }
  }

  static UserRole fromString(String role) {
    final lower = role.toLowerCase();
    if (lower.contains('admin') || lower == '1') return UserRole.admin;
    if (lower.contains('it') || lower == '2') return UserRole.it;
    return UserRole.employee;
  }
}
