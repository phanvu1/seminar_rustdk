import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../core/network/api_service.dart';
import '../models/user_model.dart';
import 'mock_data_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    // Default active user is Admin for convenient demo
    _currentUser = MockDataService().users.first;
    _activeRole = _currentUser.role;
  }

  late UserModel _currentUser;
  late UserRole _activeRole;
  bool _isAuthenticated = true;

  UserModel get currentUser => _currentUser;
  UserRole get activeRole => _activeRole;
  bool get isAuthenticated => _isAuthenticated;

  // Fast Role Switcher for instant demo evaluation
  void switchRole(UserRole newRole) {
    _activeRole = newRole;
    // Match appropriate demo user
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
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    final result = await ApiService().login(username, password);
    if (result['success'] == true) {
      _isAuthenticated = true;
      if (result['user'] is UserModel) {
        _currentUser = result['user'];
      } else {
        // Find or build user
        final uid = result['user_id'] ?? 1;
        _currentUser = MockDataService().users.firstWhere(
              (u) => u.userId == uid,
              orElse: () => MockDataService().users.first,
            );
      }
      _activeRole = _currentUser.role;
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
