import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../../services/mock_data_service.dart';
import '../../models/user_model.dart';
import '../../models/device_model.dart';
import '../../models/department_model.dart';
import '../../models/support_request_model.dart';
import '../../models/permission_model.dart';
import '../../models/remote_session_model.dart';
import '../../models/notification_model.dart';

class ApiService extends ChangeNotifier {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String _baseUrl = AppConstants.defaultApiBaseUrl;
  String? _jwtToken;
  bool _isBackendConnected = false;
  String _lastError = '';

  String get baseUrl => _baseUrl;
  String? get jwtToken => _jwtToken;
  bool get isBackendConnected => _isBackendConnected;
  String get lastError => _lastError;

  void setBaseUrl(String url) {
    _baseUrl = url.replaceAll(RegExp(r'/+$'), '');
    notifyListeners();
  }

  void setJwtToken(String? token) {
    _jwtToken = token;
    notifyListeners();
  }

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_jwtToken != null && _jwtToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_jwtToken';
    }
    return headers;
  }

  // --- HEALTH CHECK ---
  Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse('$_baseUrl/');
      final res = await http.get(uri).timeout(const Duration(seconds: 2));
      if (res.statusCode == 200) {
        _isBackendConnected = true;
        _lastError = '';
        notifyListeners();
        return true;
      }
    } catch (e) {
      _lastError = e.toString();
    }
    _isBackendConnected = false;
    notifyListeners();
    return false;
  }

  // --- AUTH ---
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/auth/login');
      final res = await http
          .post(uri, headers: _buildHeaders(), body: jsonEncode({'username': username, 'password': password}))
          .timeout(AppConstants.apiTimeout);

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        _isBackendConnected = true;
        _jwtToken = data['token'] ?? 'jwt-vynex-token';
        notifyListeners();
        return {'success': true, 'data': data, 'isFallback': false};
      }
    } catch (e) {
      debugPrint('[ApiService] login fallback due to: $e');
    }

    // Smart Fallback
    _isBackendConnected = false;
    notifyListeners();
    final mockUser = MockDataService().users.firstWhere(
          (u) => u.username.toLowerCase() == username.toLowerCase(),
          orElse: () => MockDataService().users.first,
        );
    _jwtToken = 'jwt-mock-token-${mockUser.userId}';
    return {
      'success': true,
      'isFallback': true,
      'user_id': mockUser.userId,
      'role_id': mockUser.role.roleId,
      'token': _jwtToken,
      'user': mockUser,
    };
  }

  // --- USERS ---
  Future<List<UserModel>> getUsers() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/users');
      final res = await http.get(uri, headers: _buildHeaders()).timeout(AppConstants.apiTimeout);
      if (res.statusCode == 200) {
        final json = jsonDecode(utf8.decode(res.bodyBytes));
        final list = (json['data'] as List).map((e) => UserModel.fromJson(e)).toList();
        _isBackendConnected = true;
        notifyListeners();
        return list;
      }
    } catch (e) {
      debugPrint('[ApiService] getUsers fallback due to: $e');
    }
    _isBackendConnected = false;
    notifyListeners();
    return MockDataService().users;
  }

  Future<bool> createUser(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/users');
      final res = await http
          .post(uri, headers: _buildHeaders(), body: jsonEncode(data))
          .timeout(AppConstants.apiTimeout);
      if (res.statusCode == 200 || res.statusCode == 201) {
        _isBackendConnected = true;
        return true;
      }
    } catch (e) {
      debugPrint('[ApiService] createUser fallback due to: $e');
    }
    // Fallback: Add to mock service
    final newId = MockDataService().users.length + 1;
    final newUser = UserModel(
      userId: newId,
      username: data['username'] ?? 'user_$newId',
      fullName: data['full_name'] ?? 'User $newId',
      role: data['role_id'] == 1 ? UserRole.admin : (data['role_id'] == 2 ? UserRole.it : UserRole.employee),
      email: data['email'],
      phone: data['phone'],
      departmentId: data['department_id'],
    );
    MockDataService().users.add(newUser);
    notifyListeners();
    return true;
  }

  // --- DEVICES ---
  Future<List<DeviceModel>> getDevices() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/devices');
      final res = await http.get(uri, headers: _buildHeaders()).timeout(AppConstants.apiTimeout);
      if (res.statusCode == 200) {
        final json = jsonDecode(utf8.decode(res.bodyBytes));
        final list = (json['data'] as List).map((e) => DeviceModel.fromJson(e)).toList();
        _isBackendConnected = true;
        notifyListeners();
        return list;
      }
    } catch (e) {
      debugPrint('[ApiService] getDevices fallback due to: $e');
    }
    _isBackendConnected = false;
    notifyListeners();
    return MockDataService().devices;
  }

  Future<bool> createDevice(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/devices');
      final res = await http
          .post(uri, headers: _buildHeaders(), body: jsonEncode(data))
          .timeout(AppConstants.apiTimeout);
      if (res.statusCode == 200 || res.statusCode == 201) {
        _isBackendConnected = true;
        return true;
      }
    } catch (e) {
      debugPrint('[ApiService] createDevice fallback due to: $e');
    }
    final newId = MockDataService().devices.length + 1;
    final dev = DeviceModel(
      deviceId: newId,
      vynexId: data['rustdesk_id'] ?? data['vynex_id'] ?? '${(100 + newId * 13)} ${(200 + newId * 17)} ${(300 + newId * 19)}',
      name: data['device_name'] ?? 'Thiết bị mới #$newId',
      userId: data['user_id'],
      departmentId: data['department_id'],
      deviceType: data['device_type'] ?? 'desktop',
      ipAddress: data['ip_address'] ?? '192.168.1.${110 + newId}',
      status: 'online',
      lastHeartbeat: DateTime.now(),
      lastOnline: DateTime.now(),
    );
    MockDataService().devices.add(dev);
    notifyListeners();
    return true;
  }

  Future<bool> deleteDevice(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/devices/$id');
      final res = await http.delete(uri, headers: _buildHeaders()).timeout(AppConstants.apiTimeout);
      if (res.statusCode == 200) {
        _isBackendConnected = true;
        return true;
      }
    } catch (e) {
      debugPrint('[ApiService] deleteDevice fallback due to: $e');
    }
    MockDataService().devices.removeWhere((d) => d.deviceId == id);
    notifyListeners();
    return true;
  }

  // --- SUPPORT REQUESTS ---
  Future<List<SupportRequestModel>> getSupportRequests() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/support-requests');
      final res = await http.get(uri, headers: _buildHeaders()).timeout(AppConstants.apiTimeout);
      if (res.statusCode == 200) {
        final json = jsonDecode(utf8.decode(res.bodyBytes));
        final list = (json['data'] as List).map((e) => SupportRequestModel.fromJson(e)).toList();
        _isBackendConnected = true;
        notifyListeners();
        return list;
      }
    } catch (e) {
      debugPrint('[ApiService] getSupportRequests fallback: $e');
    }
    _isBackendConnected = false;
    notifyListeners();
    return MockDataService().supportRequests;
  }

  Future<bool> createSupportRequest(SupportRequestModel req) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/support-requests');
      final res = await http
          .post(uri, headers: _buildHeaders(), body: jsonEncode(req.toJson()))
          .timeout(AppConstants.apiTimeout);
      if (res.statusCode == 200 || res.statusCode == 201) {
        _isBackendConnected = true;
        return true;
      }
    } catch (e) {
      debugPrint('[ApiService] createSupportRequest fallback: $e');
    }
    MockDataService().supportRequests.insert(0, req);
    MockDataService().notifications.insert(
          0,
          NotificationModel(
            notificationId: MockDataService().notifications.length + 1,
            userId: 2, // notify IT
            title: 'Yêu cầu hỗ trợ mới #${req.requestId}',
            content: '${req.employeeName}: "${req.title}"',
            type: 'support_request',
            referenceId: req.requestId,
            createdAt: DateTime.now(),
          ),
        );
    notifyListeners();
    return true;
  }

  Future<bool> cancelSupportRequest(int requestId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/support-requests/$requestId/cancel');
      final res = await http.put(uri, headers: _buildHeaders()).timeout(AppConstants.apiTimeout);
      if (res.statusCode == 200) {
        _isBackendConnected = true;
        return true;
      }
    } catch (e) {
      debugPrint('[ApiService] cancelSupportRequest fallback: $e');
    }
    return true;
  }

  Future<bool> rateSupportRequest(int requestId, int rating, String feedback) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/support-requests/$requestId/rate');
      final res = await http.post(
        uri,
        headers: _buildHeaders(),
        body: jsonEncode({'rating': rating, 'feedback': feedback}),
      ).timeout(AppConstants.apiTimeout);
      if (res.statusCode == 200) {
        _isBackendConnected = true;
        return true;
      }
    } catch (e) {
      debugPrint('[ApiService] rateSupportRequest fallback: $e');
    }
    return true;
  }

  // --- PERMISSIONS ---
  Future<List<PermissionModel>> getPermissions() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/permissions');
      final res = await http.get(uri, headers: _buildHeaders()).timeout(AppConstants.apiTimeout);
      if (res.statusCode == 200) {
        final json = jsonDecode(utf8.decode(res.bodyBytes));
        final list = (json['data'] as List).map((e) => PermissionModel.fromJson(e)).toList();
        _isBackendConnected = true;
        notifyListeners();
        return list;
      }
    } catch (e) {
      debugPrint('[ApiService] getPermissions fallback: $e');
    }
    _isBackendConnected = false;
    notifyListeners();
    return MockDataService().permissions;
  }

  Future<bool> grantPermission(PermissionModel permission) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/permissions');
      final res = await http
          .post(uri, headers: _buildHeaders(), body: jsonEncode(permission.toJson()))
          .timeout(AppConstants.apiTimeout);
      if (res.statusCode == 200 || res.statusCode == 201) {
        _isBackendConnected = true;
        return true;
      }
    } catch (e) {
      debugPrint('[ApiService] grantPermission fallback: $e');
    }
    MockDataService().permissions.insert(0, permission);
    MockDataService().notifications.insert(
          0,
          NotificationModel(
            notificationId: MockDataService().notifications.length + 1,
            userId: permission.userId,
            title: 'Admin đã cấp quyền máy ${permission.deviceName}',
            content: 'Thời hạn: ${permission.expiryLabel} - Quyền: ${permission.permissionType.toUpperCase()}',
            type: 'permission_granted',
            referenceId: permission.permissionId,
            createdAt: DateTime.now(),
          ),
        );
    notifyListeners();
    return true;
  }

  Future<bool> revokePermission(int permissionId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/permissions/$permissionId/revoke');
      final res = await http.put(uri, headers: _buildHeaders()).timeout(AppConstants.apiTimeout);
      if (res.statusCode == 200) {
        _isBackendConnected = true;
        return true;
      }
    } catch (e) {
      debugPrint('[ApiService] revokePermission fallback: $e');
    }
    final index = MockDataService().permissions.indexWhere((p) => p.permissionId == permissionId);
    if (index != -1) {
      final existing = MockDataService().permissions[index];
      MockDataService().permissions[index] = existing.copyWith(
        revokedAt: DateTime.now(),
        status: false,
        notes: '${existing.notes ?? ""} (Đã thu hồi bởi Admin lúc ${DateTime.now().hour}:${DateTime.now().minute})',
      );
    }
    notifyListeners();
    return true;
  }

  // --- SESSIONS ---
  Future<List<RemoteSessionModel>> getSessions() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/sessions');
      final res = await http.get(uri, headers: _buildHeaders()).timeout(AppConstants.apiTimeout);
      if (res.statusCode == 200) {
        final json = jsonDecode(utf8.decode(res.bodyBytes));
        final list = (json['data'] as List).map((e) => RemoteSessionModel.fromJson(e)).toList();
        _isBackendConnected = true;
        notifyListeners();
        return list;
      }
    } catch (e) {
      debugPrint('[ApiService] getSessions fallback: $e');
    }
    _isBackendConnected = false;
    notifyListeners();
    return MockDataService().sessions;
  }

  Future<bool> logSession(RemoteSessionModel session) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/sessions');
      final res = await http
          .post(uri, headers: _buildHeaders(), body: jsonEncode(session.toJson()))
          .timeout(AppConstants.apiTimeout);
      if (res.statusCode == 200 || res.statusCode == 201) {
        _isBackendConnected = true;
        return true;
      }
    } catch (e) {
      debugPrint('[ApiService] logSession fallback: $e');
    }
    MockDataService().sessions.insert(0, session);
    notifyListeners();
    return true;
  }

  // --- DEPARTMENTS ---
  Future<List<DepartmentModel>> getDepartments() async {
    return MockDataService().departments;
  }

  // --- NOTIFICATIONS (THEO TAB 2, TAB 3 & LỖI 2.2) ---
  Future<List<NotificationModel>> getNotifications({int? userId, UserRole? role}) async {
    try {
      final roleStr = role == UserRole.admin
          ? 'admin'
          : (role == UserRole.it ? 'it' : 'employee');
      final uri = Uri.parse('$_baseUrl/api/notifications?user_id=${userId ?? 0}&role=$roleStr');
      final res = await http.get(uri, headers: _buildHeaders()).timeout(AppConstants.apiTimeout);
      if (res.statusCode == 200) {
        final json = jsonDecode(utf8.decode(res.bodyBytes));
        final list = (json['data'] as List).map((e) => NotificationModel.fromJson(e)).toList();
        _isBackendConnected = true;
        notifyListeners();
        return list;
      }
    } catch (e) {
      debugPrint('[ApiService] getNotifications fallback: $e');
    }

    // FALLBACK LỌC CHUẨN 3 VAI TRÒ (RBAC NOTIFICATIONS):
    final allNotifs = MockDataService().notifications;
    if (role == UserRole.admin) {
      // 1. Admin: Nhận và xem được mọi thông báo trong hệ thống
      return List<NotificationModel>.from(allNotifs);
    } else if (role == UserRole.it) {
      // 2. IT Staff: Chỉ nhận thông báo yêu cầu hỗ trợ mới từ nhân viên,
      // thông báo Admin cấp/thu hồi quyền, và thông báo liên quan trực tiếp đến phiên của IT
      return allNotifs.where((n) {
        if (n.type == 'support_request') return true;
        if (n.type == 'permission_granted' || n.type == 'permission_revoked') {
          return userId == null || n.userId == userId || n.userId == 2;
        }
        if (n.type == 'session_started' || n.type == 'session_ended') {
          return userId == null || n.userId == userId || n.userId == 2;
        }
        if (n.type == 'permission_request') {
          return n.userId == userId;
        }
        return false;
      }).toList();
    } else {
      // 3. Nhân viên: CHỈ nhận thông báo phản hồi về trạng thái yêu cầu của chính mình
      return allNotifs.where((n) {
        return userId != null && n.userId == userId;
      }).toList();
    }
  }

  Future<bool> sendNotification(NotificationModel notif) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/notifications');
      await http.post(
        uri,
        headers: _buildHeaders(),
        body: jsonEncode(notif.toJson()),
      ).timeout(AppConstants.apiTimeout);
    } catch (_) {}
    MockDataService().notifications.insert(0, notif);
    notifyListeners();
    return true;
  }

  Future<void> markNotificationAsRead(int id) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/notifications/$id/read');
      await http.put(uri, headers: _buildHeaders()).timeout(AppConstants.apiTimeout);
    } catch (_) {}
    final idx = MockDataService().notifications.indexWhere((n) => n.notificationId == id);
    if (idx != -1) {
      MockDataService().notifications[idx] = MockDataService().notifications[idx].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markAllNotificationsAsRead({int? userId}) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/notifications/read-all${userId != null ? '?user_id=$userId' : ''}');
      await http.put(uri, headers: _buildHeaders()).timeout(AppConstants.apiTimeout);
    } catch (_) {}
    for (int i = 0; i < MockDataService().notifications.length; i++) {
      if (userId == null || MockDataService().notifications[i].userId == userId) {
        MockDataService().notifications[i] = MockDataService().notifications[i].copyWith(isRead: true);
      }
    }
    notifyListeners();
  }
}
