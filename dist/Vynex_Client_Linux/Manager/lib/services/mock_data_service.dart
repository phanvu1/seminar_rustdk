import '../core/constants.dart';
import '../models/user_model.dart';
import '../models/department_model.dart';
import '../models/device_model.dart';
import '../models/support_request_model.dart';
import '../models/permission_model.dart';
import '../models/remote_session_model.dart';
import '../models/notification_model.dart';
import '../models/activity_log_model.dart';

class MockDataService {
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal() {
    _initData();
  }

  late List<DepartmentModel> departments;
  late List<UserModel> users;
  late List<DeviceModel> devices;
  late List<SupportRequestModel> supportRequests;
  late List<PermissionModel> permissions;
  late List<RemoteSessionModel> sessions;
  late List<NotificationModel> notifications;
  late List<ActivityLogModel> activityLogs;
  late List<ServerMetricModel> serverMetrics;

  void _initData() {
    departments = [
      DepartmentModel(
        departmentId: 1,
        name: 'Phòng Kỹ thuật & CNTT',
        description: 'Quản trị hạ tầng mạng, máy chủ và hỗ trợ kỹ thuật',
        managerId: 1,
        managerName: 'Nguyễn Văn An (Admin)',
        memberCount: 1,
        deviceCount: 1,
      ),
      DepartmentModel(
        departmentId: 2,
        name: 'Phòng Kế toán - Tài chính',
        description: 'Quản lý thu chi, hóa đơn điện tử và kiểm toán',
        managerId: null,
        managerName: null,
        memberCount: 0,
        deviceCount: 0,
      ),
    ];

    users = [
      UserModel(
        userId: 1,
        username: 'admin',
        fullName: 'Nguyễn Văn An (Admin)',
        role: UserRole.admin,
        departmentId: 1,
        departmentName: 'Phòng Kỹ thuật & CNTT',
        email: 'admin@vynex.vn',
        phone: '0901 234 567',
        status: 'active',
        lastLogin: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];

    devices = [
      DeviceModel(
        deviceId: 2,
        vynexId: '184 838 3706',
        name: 'PC-IT-ADMIN (Host Windows)',
        userId: 1,
        userName: 'Nguyễn Văn An (Admin)',
        departmentId: 1,
        departmentName: 'Phòng Kỹ thuật & CNTT',
        deviceType: 'laptop',
        ipAddress: '10.13.13.2',
        macAddress: '74:40:BB:EA:B4:FB',
        osName: 'Windows 11 Pro 64-bit',
        status: 'online',
        lastHeartbeat: DateTime.now(),
        lastOnline: DateTime.now(),
      ),
    ];

    // Danh sách rỗng cho demo thực tế sạch sẽ
    supportRequests = [];

    permissions = [];

    sessions = [];

    notifications = [];

    activityLogs = [];

    serverMetrics = [
      ServerMetricModel(
        serverId: 1,
        serverName: 'Vynex HBBS (Rendezvous / ID Server)',
        serverType: 'HBBS',
        host: '127.0.0.1',
        port: 21116,
        status: 'online',
        cpuUsage: 12.5,
        ramUsage: 28.4,
        version: '1.2.3 (Vynex Core)',
        lastHeartbeat: DateTime.now().subtract(const Duration(seconds: 4)),
      ),
      ServerMetricModel(
        serverId: 2,
        serverName: 'Vynex HBBR (Relay Server)',
        serverType: 'HBBR',
        host: '127.0.0.1',
        port: 21117,
        status: 'online',
        cpuUsage: 7.8,
        ramUsage: 19.2,
        version: '1.2.3 (Vynex Core)',
        lastHeartbeat: DateTime.now().subtract(const Duration(seconds: 4)),
      ),
    ];
  }
}
