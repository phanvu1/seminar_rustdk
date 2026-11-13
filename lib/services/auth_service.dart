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

  Future<bool> login(String username, String password) async {
    // Kiểm tra mật khẩu chuẩn: '123' cho tất cả tài khoản demo
    final u = username.trim().toLowerCase();
    final p = password.trim();

    if (p != '123') {
      return false;
    }

    // Thử kết nối API Backend nếu có sẵn
    try {
      final apiRes = await ApiService().login(u, p);
      if (apiRes['token'] != null) {
        ApiService().setJwtToken(apiRes['token']);
      }
    } catch (_) {}

    // Khớp tài khoản theo đúng 4 Actor nghiệp vụ (admin, it, it2, nhanvien)
    UserModel? matchedUser;
    if (u == 'admin') {
      matchedUser = MockDataService().users.firstWhere((usr) => usr.username == 'admin');
    } else if (u == 'it' || u == 'it1') {
      matchedUser = MockDataService().users.firstWhere((usr) => usr.username == 'it');
    } else if (u == 'it2' || u == 'it_nam' || u == 'nam') {
      matchedUser = MockDataService().users.firstWhere((usr) => usr.username == 'it2');
    } else if (u == 'nhanvien' || u == 'ketoan' || u == 'mai') {
      matchedUser = MockDataService().users.firstWhere((usr) => usr.role == UserRole.employee);
    } else {
      matchedUser = MockDataService().users.firstWhere(
            (usr) => usr.username.toLowerCase() == u,
            orElse: () => MockDataService().users.first,
          );
    }

    if (matchedUser != null) {
      _currentUser = matchedUser;
      _activeRole = matchedUser.role;
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
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
