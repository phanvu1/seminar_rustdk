import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/network/api_service.dart';
import '../models/permission_model.dart';
import '../models/notification_model.dart';
import 'mock_data_service.dart';

class PermissionService extends ChangeNotifier {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  List<PermissionModel> _permissions = [];
  final Set<int> _pendingRequestedDeviceIds = {};
  bool _isLoading = false;

  List<PermissionModel> get permissions => _permissions;
  bool get isLoading => _isLoading;

  bool hasRequestedPermission(int deviceId) => _pendingRequestedDeviceIds.contains(deviceId);

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

  /// Sinh Session Token ủy quyền phiên kết nối từ Vynex Manager sang Vynex Client
  String generateSessionToken(int itUserId, int deviceId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'vynex_token_${deviceId}_${itUserId}_$timestamp';
  }

  /// Xác thực quyền kết nối với Backend hoặc Local Fallback
  Future<bool> verifyPermissionOnline(int itUserId, int deviceId) async {
    // 1. Kiểm tra trực tiếp trên cache / mock data service
    final localValid = hasPermission(itUserId, deviceId);
    if (!localValid) return false;

    // 2. Kiểm tra thêm qua backend API nếu có kết nối
    try {
      final base = ApiService().baseUrl;
      final url = Uri.parse('$base/api/permissions/verify?user_id=$itUserId&device_id=$deviceId');
      final res = await http.get(url).timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) {
        // Parse response
        return true;
      }
    } catch (_) {}
    return localValid;
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

  // IT Staff requests permission from Admin (Lỗi 2.3)
  Future<bool> requestPermission({
    required int itUserId,
    required String itName,
    required int deviceId,
    required String deviceName,
    required String vynexId,
    String? reason,
  }) async {
    _pendingRequestedDeviceIds.add(deviceId);
    notifyListeners();

    final notif = NotificationModel(
      notificationId: DateTime.now().millisecondsSinceEpoch % 100000,
      userId: 1, // Gửi tới Admin
      title: 'IT $itName yêu cầu cấp quyền điều khiển máy $deviceName',
      content: 'IT $itName yêu cầu cấp quyền điều khiển máy $deviceName (ID: $vynexId). Lý do: ${reason ?? "Hỗ trợ xử lý sự cố kỹ thuật"}',
      type: 'permission_request',
      referenceId: deviceId,
      isRead: false,
      createdAt: DateTime.now(),
    );

    await ApiService().sendNotification(notif);
    return true;
  }

  // Admin revokes permission
  Future<bool> revokePermission(int permissionId) async {
    final success = await ApiService().revokePermission(permissionId);
    await fetchPermissions();
    return success;
  }
}
