import 'package:flutter/material.dart';
import '../core/network/api_service.dart';
import '../models/permission_model.dart';
import 'mock_data_service.dart';

class PermissionService extends ChangeNotifier {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  List<PermissionModel> _permissions = [];
  bool _isLoading = false;

  List<PermissionModel> get permissions => _permissions;
  bool get isLoading => _isLoading;

  Future<void> fetchPermissions() async {
    _isLoading = true;
    notifyListeners();
    _permissions = await ApiService().getPermissions();
    _isLoading = false;
    notifyListeners();
  }

  // Check if a specific IT user has valid active permission for a given device
  bool hasPermission(int itUserId, int deviceId) {
    final list = _permissions.isNotEmpty ? _permissions : MockDataService().permissions;
    return list.any((p) =>
        p.userId == itUserId &&
        p.deviceId == deviceId &&
        p.isValid);
  }

  PermissionModel? getActivePermission(int itUserId, int deviceId) {
    final list = _permissions.isNotEmpty ? _permissions : MockDataService().permissions;
    try {
      return list.firstWhere(
        (p) => p.userId == itUserId && p.deviceId == deviceId && p.isValid,
      );
    } catch (_) {
      return null;
    }
  }

  // Admin grants permission
  Future<bool> grantPermission({
    required int itUserId,
    required String itName,
    required int deviceId,
    required String deviceName,
    required String vynexId,
    required String permissionType,
    required String durationType, // '24h', '7d', 'forever'
    String? notes,
  }) async {
    DateTime? expiresAt;
    final now = DateTime.now();
    if (durationType == '24h') {
      expiresAt = now.add(const Duration(hours: 24));
    } else if (durationType == '7d') {
      expiresAt = now.add(const Duration(days: 7));
    } else {
      expiresAt = null; // Forever
    }

    final newPermission = PermissionModel(
      permissionId: DateTime.now().millisecondsSinceEpoch % 100000,
      userId: itUserId,
      itName: itName,
      deviceId: deviceId,
      deviceName: deviceName,
      vynexId: vynexId,
      permissionType: permissionType,
      grantedAt: now,
      expiresAt: expiresAt,
      notes: notes ?? 'Được cấp bởi Admin ($durationType)',
      status: true,
    );

    final success = await ApiService().grantPermission(newPermission);
    await fetchPermissions();
    return success;
  }

  // Admin revokes permission
  Future<bool> revokePermission(int permissionId) async {
    final success = await ApiService().revokePermission(permissionId);
    await fetchPermissions();
    return success;
  }
}
