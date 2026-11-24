import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../core/network/api_service.dart';
import '../models/permission_model.dart';
import '../models/notification_model.dart';
import 'auth_service.dart';
import 'mock_data_service.dart';

class PermissionService extends ChangeNotifier {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  List<PermissionModel> _permissions = [];
  List<NotificationModel> _pendingRequests = [];
  final Set<String> _pendingTicketRequests = {};
  final Set<String> _rejectedDeviceRequests = {};
  bool _isLoading = false;
  Timer? _pollingTimer;

  List<PermissionModel> get permissions => _permissions;
  List<NotificationModel> get pendingRequests => _pendingRequests;
  bool get isLoading => _isLoading;

  void startPolling() {
    if (_pollingTimer != null && _pollingTimer!.isActive) return;
    fetchPermissions();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      silentFetchPermissions();
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> silentFetchPermissions() async {
    final newPerms = await ApiService().getPermissions();
    _permissions = newPerms;
    await fetchPendingRequests();
    notifyListeners();
  }

  Future<void> fetchPendingRequests() async {
    try {
      final auth = AuthService();
      final myId = auth.currentUser.userId;
      final myRole = auth.currentUser.role;

      // 1. Nếu là Admin: lấy danh sách yêu cầu chờ duyệt
      if (myRole == UserRole.admin) {
        final notifs = await ApiService().getNotifications(userId: 1, role: UserRole.admin);
        _pendingRequests = notifs.where((n) => n.type == 'permission_request' && !n.isRead).toList();
      }

      // 2. Nếu là IT: đồng bộ danh sách thông báo để biết Admin đã từ chối hay phê duyệt
      final itNotifs = await ApiService().getNotifications(userId: myId, role: UserRole.it);
      for (final n in itNotifs) {
        final devId = n.referenceId;
        if (devId != null && devId > 0) {
          if (n.type == 'permission_rejected') {
            _pendingTicketRequests.remove('dev_$devId');
            _rejectedDeviceRequests.add('dev_$devId');
          } else if (n.type == 'permission_granted') {
            _pendingTicketRequests.remove('dev_$devId');
            _rejectedDeviceRequests.remove('dev_$devId');
          }
        }
      }
    } catch (_) {}
  }

  bool hasRequestedTicket(int requestId) => _pendingTicketRequests.contains('req_$requestId');

  bool hasRequestedPermission(int deviceId) => _pendingTicketRequests.contains('dev_$deviceId');

  bool isPermissionRejected(int deviceId) => _rejectedDeviceRequests.contains('dev_$deviceId');

  void clearRejection(int deviceId) {
    _rejectedDeviceRequests.remove('dev_$deviceId');
    notifyListeners();
  }

  Future<void> fetchPermissions() async {
    _isLoading = true;
    notifyListeners();
    _permissions = await ApiService().getPermissions();
    await fetchPendingRequests();
    _isLoading = false;
    notifyListeners();
  }

  // Check if a specific IT user has valid active permission for a given device
  bool hasPermission(int itUserId, int deviceId) {
    // Nếu kiểm tra cho Admin thì Admin luôn có toàn quyền
    final auth = AuthService();
    final targetUser = MockDataService().users.firstWhere(
      (u) => u.userId == itUserId,
      orElse: () => auth.currentUser,
    );
    if (targetUser.role == UserRole.admin) {
      return true;
    }

    // Nếu kiểm tra cho IT Staff (ví dụ Trần Thị B user_id=2 hay Lê Hoàng Nam user_id=3)
    final list = _permissions.isNotEmpty ? _permissions : MockDataService().permissions;
    return list.any((p) =>
        p.userId == itUserId &&
        p.deviceId == deviceId &&
        p.isValid);
  }

  /// Lấy bản ghi quyền hợp lệ hiện tại của một IT với một thiết bị (nếu có)
  PermissionModel? getActivePermissionFor(int itUserId, int deviceId) {
    final list = _permissions.isNotEmpty ? _permissions : MockDataService().permissions;
    try {
      return list.firstWhere(
        (p) => p.userId == itUserId && p.deviceId == deviceId && p.isValid,
      );
    } catch (_) {
      return null;
    }
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
      durationHours: durationType == '24h' ? 24 : (durationType == '7d' ? 168 : null),
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
    int? requestId,
    String? reason,
  }) async {
    if (requestId != null) {
      _pendingTicketRequests.add('req_$requestId');
    }
    _pendingTicketRequests.add('dev_$deviceId');
    _rejectedDeviceRequests.remove('dev_$deviceId');
    notifyListeners();

    final notif = NotificationModel(
      notificationId: DateTime.now().millisecondsSinceEpoch % 100000,
      userId: 1, // Gửi tới Admin
      title: 'IT $itName yêu cầu cấp quyền máy $deviceName',
      content: '[REQ:it_id=$itUserId,dev_id=$deviceId] IT $itName yêu cầu cấp quyền điều khiển máy $deviceName (ID: $vynexId)${requestId != null && requestId > 0 ? " cho Ticket #$requestId" : ""}. Lý do: ${reason ?? "Hỗ trợ xử lý sự cố kỹ thuật"}',
      type: 'permission_request',
      referenceId: requestId != null && requestId > 0 ? requestId : deviceId,
      isRead: false,
      createdAt: DateTime.now(),
    );

    await ApiService().sendNotification(notif);
    return true;
  }

  // Admin rejects permission request and notifies IT
  Future<bool> rejectPermission({
    required int notificationId,
    required int itUserId,
    required int deviceId,
    String? reason,
  }) async {
    final success = await ApiService().rejectPermissionRequest(
      notificationId: notificationId,
      itUserId: itUserId,
      deviceId: deviceId,
      reason: reason,
    );
    await fetchPendingRequests();
    notifyListeners();
    return success;
  }

  // Admin revokes permission
  Future<bool> revokePermission(int permissionId) async {
    final success = await ApiService().revokePermission(permissionId);
    await fetchPermissions();
    return success;
  }
}
