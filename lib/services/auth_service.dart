import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/network/api_service.dart';
import '../models/user_model.dart';
import 'mock_data_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  // Khởi tạo mặc định: Chưa đăng nhập để bắt buộc vào màn hình Login
  AuthService._internal() {
    _currentUser = MockDataService().users.first;
    _activeRole = _currentUser.role;
    _isAuthenticated = false; // Luôn bắt buộc đăng nhập khi mở app
  }

  late UserModel _currentUser;
  late UserRole _activeRole;
  bool _isAuthenticated = false; // Bắt buộc đăng nhập khi khởi động

  UserModel get currentUser => _currentUser;
  UserRole get activeRole => _activeRole;
  bool get isAuthenticated => _isAuthenticated;

  // Fast Role Switcher for instant demo evaluation
  void switchRole(UserRole newRole, {String? preferUsername}) {
    _activeRole = newRole;
    if (preferUsername != null) {
      final found = MockDataService().users.firstWhere(
            (u) => u.username.toLowerCase() == preferUsername.toLowerCase(),
            orElse: () => MockDataService().users.first,
          );
      _currentUser = found;
      _activeRole = found.role;
    } else {
      switch (newRole) {
        case UserRole.admin:
          _currentUser = MockDataService().users.firstWhere(
                (u) => u.role == UserRole.admin,
                orElse: () => MockDataService().users[0],
              );
          break;
        case UserRole.it:
          _currentUser = MockDataService().users.firstWhere(
                (u) => u.role == UserRole.it,
                orElse: () => MockDataService().users[1],
              );
          break;
        case UserRole.employee:
          _currentUser = MockDataService().users.firstWhere(
                (u) => u.role == UserRole.employee,
                orElse: () => MockDataService().users[3],
              );
          break;
      }
    }
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final u = username.trim().toLowerCase();
    final p = password.trim();

    if (u.isEmpty || p.isEmpty) {
      return {'success': false, 'message': 'Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu!'};
    }

    final apiRes = await ApiService().login(u, p);
    if (apiRes['success'] == true) {
      final userData = apiRes['user'] ?? {};
      final roleId = userData['role_id'] is int
          ? userData['role_id']
          : int.tryParse(userData['role_id']?.toString() ?? '') ?? 3;
      final role = roleId == 1 ? UserRole.admin : (roleId == 2 ? UserRole.it : UserRole.employee);

      final loggedInUser = UserModel(
        userId: userData['user_id'] is int
            ? userData['user_id']
            : int.tryParse(userData['user_id']?.toString() ?? '') ?? 999,
        username: userData['username'] ?? u,
        fullName: userData['full_name'] ?? u,
        role: role,
        departmentId: userData['department_id'] is int
            ? userData['department_id']
            : int.tryParse(userData['department_id']?.toString() ?? ''),
        departmentName: userData['department_name'],
        email: userData['email'],
        phone: userData['phone'],
        status: userData['status'] ?? 'active',
      );

      // Đồng bộ thông tin người dùng vào danh sách cục bộ
      final idx = MockDataService().users.indexWhere(
            (usr) => usr.userId == loggedInUser.userId || usr.username.toLowerCase() == u,
          );
      if (idx != -1) {
        MockDataService().users[idx] = loggedInUser;
      } else {
        MockDataService().users.add(loggedInUser);
      }

      _currentUser = loggedInUser;
      _activeRole = loggedInUser.role;
      _isAuthenticated = true;
      notifyListeners();
      return {'success': true};
    } else {
      return {
        'success': false,
        'isLocked': apiRes['isLocked'] == true,
        'message': apiRes['message'] ?? 'Tên đăng nhập hoặc mật khẩu không chính xác.',
      };
    }
  }

  void logout() {
    _isAuthenticated = false;
    ApiService().setJwtToken(null);
    notifyListeners();
  }

  void updateProfile({String? fullName, String? email, String? phone}) {
    _currentUser = _currentUser.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
    );
    notifyListeners();
  }
}
