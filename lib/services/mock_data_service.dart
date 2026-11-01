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
        memberCount: 5,
        deviceCount: 12,
      ),
      DepartmentModel(
        departmentId: 2,
        name: 'Phòng Kế toán - Tài chính',
        description: 'Quản lý thu chi, hóa đơn điện tử và kiểm toán',
        managerId: 4,
        managerName: 'Phạm Thị Mai',
        memberCount: 8,
        deviceCount: 8,
      ),
      DepartmentModel(
        departmentId: 3,
        name: 'Phòng Kinh doanh & Tiếp thị',
        description: 'Tư vấn giải pháp, bán hàng và chăm sóc khách hàng',
        managerId: 5,
        managerName: 'Đỗ Hoàng Long',
        memberCount: 15,
        deviceCount: 15,
      ),
      DepartmentModel(
        departmentId: 4,
        name: 'Ban Nhân sự & Hành chính',
        description: 'Tuyển dụng, đào tạo và văn thư lưu trữ',
        managerId: 6,
        managerName: 'Vũ Hải Đăng',
        memberCount: 4,
        deviceCount: 4,
      ),
    ];

    users = [
      UserModel(
        userId: 1,
        username: 'admin',
        fullName: 'Nguyễn Văn An',
        role: UserRole.admin,
        departmentId: 1,
        departmentName: 'Phòng Kỹ thuật & CNTT',
        email: 'an.nguyen@vynex.vn',
        phone: '0901 234 567',
        status: 'active',
        lastLogin: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      UserModel(
        userId: 2,
        username: 'it_nam',
        fullName: 'Lê Hoàng Nam',
        role: UserRole.it,
        departmentId: 1,
        departmentName: 'Phòng Kỹ thuật & CNTT',
        email: 'nam.le@vynex.vn',
        phone: '0912 345 678',
        status: 'active',
        lastLogin: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      UserModel(
        userId: 3,
        username: 'it_tuan',
        fullName: 'Trần Minh Tuấn',
        role: UserRole.it,
        departmentId: 1,
        departmentName: 'Phòng Kỹ thuật & CNTT',
        email: 'tuan.tran@vynex.vn',
        phone: '0923 456 789',
        status: 'active',
        lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      UserModel(
        userId: 4,
        username: 'kt_mai',
        fullName: 'Phạm Thị Mai',
        role: UserRole.employee,
        departmentId: 2,
        departmentName: 'Phòng Kế toán - Tài chính',
        email: 'mai.pham@vynex.vn',
        phone: '0934 567 890',
        status: 'active',
        lastLogin: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      UserModel(
        userId: 5,
        username: 'kd_long',
        fullName: 'Đỗ Hoàng Long',
        role: UserRole.employee,
        departmentId: 3,
        departmentName: 'Phòng Kinh doanh & Tiếp thị',
        email: 'long.do@vynex.vn',
        phone: '0945 678 901',
        status: 'active',
        lastLogin: DateTime.now().subtract(const Duration(days: 1)),
      ),
      UserModel(
        userId: 6,
        username: 'ns_dang',
        fullName: 'Vũ Hải Đăng',
        role: UserRole.employee,
        departmentId: 4,
        departmentName: 'Ban Nhân sự & Hành chính',
        email: 'dang.vu@vynex.vn',
        phone: '0956 789 012',
        status: 'active',
        lastLogin: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    devices = [
      DeviceModel(
        deviceId: 1,
        vynexId: '948 201 543',
        name: 'PC-KETOAN-01 (Máy kế toán Mai)',
        userId: 4,
        userName: 'Phạm Thị Mai',
        departmentId: 2,
        departmentName: 'Phòng Kế toán - Tài chính',
        deviceType: 'desktop',
        ipAddress: '192.168.1.104',
        macAddress: '00:1A:2B:3C:4D:5E',
        osName: 'Windows 11 Pro 64-bit',
        status: 'online',
        lastHeartbeat: DateTime.now().subtract(const Duration(seconds: 12)),
        lastOnline: DateTime.now(),
      ),
      DeviceModel(
        deviceId: 2,
        vynexId: '832 910 119',
        name: 'LAPTOP-KD-LONG (ThinkPad X1)',
        userId: 5,
        userName: 'Đỗ Hoàng Long',
        departmentId: 3,
        departmentName: 'Phòng Kinh doanh & Tiếp thị',
        deviceType: 'laptop',
        ipAddress: '192.168.1.108',
        macAddress: '00:2B:3C:4D:5E:6F',
        osName: 'Windows 10 Enterprise',
        status: 'online',
        lastHeartbeat: DateTime.now().subtract(const Duration(seconds: 40)),
        lastOnline: DateTime.now(),
      ),
      DeviceModel(
        deviceId: 3,
        vynexId: '102 384 756',
        name: 'SRV-FILE-VYNEX (File Server Nội bộ)',
        userId: 1,
        userName: 'Nguyễn Văn An',
        departmentId: 1,
        departmentName: 'Phòng Kỹ thuật & CNTT',
        deviceType: 'server',
        ipAddress: '192.168.1.200',
        macAddress: '00:3C:4D:5E:6F:7A',
        osName: 'Windows Server 2022',
        status: 'online',
        lastHeartbeat: DateTime.now().subtract(const Duration(seconds: 5)),
        lastOnline: DateTime.now(),
      ),
      DeviceModel(
        deviceId: 4,
        vynexId: '554 123 908',
        name: 'PC-NHANSU-DANG (Dell OptiPlex)',
        userId: 6,
        userName: 'Vũ Hải Đăng',
        departmentId: 4,
        departmentName: 'Ban Nhân sự & Hành chính',
        deviceType: 'desktop',
        ipAddress: '192.168.1.115',
        macAddress: '00:4D:5E:6F:7A:8B',
        osName: 'Windows 11 Home',
        status: 'offline',
        lastHeartbeat: DateTime.now().subtract(const Duration(hours: 3)),
        lastOnline: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      DeviceModel(
        deviceId: 5,
        vynexId: '667 890 234',
        name: 'LAPTOP-IT-NAM (Dell Precision)',
        userId: 2,
        userName: 'Lê Hoàng Nam',
        departmentId: 1,
        departmentName: 'Phòng Kỹ thuật & CNTT',
        deviceType: 'laptop',
        ipAddress: '192.168.1.102',
        macAddress: '00:5E:6F:7A:8B:9C',
        osName: 'Windows 11 Pro',
        status: 'online',
        lastHeartbeat: DateTime.now().subtract(const Duration(seconds: 2)),
        lastOnline: DateTime.now(),
      ),
    ];

    supportRequests = [
      SupportRequestModel(
        requestId: 101,
        employeeId: 4,
        employeeName: 'Phạm Thị Mai',
        deviceId: 1,
        deviceName: 'PC-KETOAN-01 (Máy kế toán Mai)',
        vynexId: '948 201 543',
        title: 'Lỗi không in được hóa đơn điện tử qua mạng LAN',
        description: 'Máy in Canon LBP2900 chia sẻ qua mạng báo lỗi Spooler dừng hoạt động đột ngột, cần hỗ trợ gấp để xuất hóa đơn cuối tháng.',
        priority: 'high',
        status: 'pending',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      SupportRequestModel(
        requestId: 102,
        employeeId: 5,
        employeeName: 'Đỗ Hoàng Long',
        deviceId: 2,
        deviceName: 'LAPTOP-KD-LONG (ThinkPad X1)',
        vynexId: '832 910 119',
        title: 'Cần cấu hình VPN WireGuard truy cập dữ liệu CRM khi công tác',
        description: 'Tuần sau đi công tác Đà Nẵng, cần kỹ thuật cài đặt và kiểm tra kết nối VPN an toàn về máy chủ nội bộ.',
        priority: 'normal',
        status: 'accepted',
        assignedItId: 2,
        assignedItName: 'Lê Hoàng Nam',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        acceptedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      SupportRequestModel(
        requestId: 103,
        employeeId: 6,
        employeeName: 'Vũ Hải Đăng',
        deviceId: 4,
        deviceName: 'PC-NHANSU-DANG (Dell OptiPlex)',
        vynexId: '554 123 908',
        title: 'Phần mềm chấm công vân tay báo lỗi kết nối SQL Server',
        description: 'Đã xử lý xong bằng cách restart dịch vụ SQL Browser và đồng bộ dữ liệu máy quét vân tay tầng 2.',
        priority: 'urgent',
        status: 'completed',
        assignedItId: 2,
        assignedItName: 'Lê Hoàng Nam',
        rating: 5,
        feedback: 'Kỹ thuật viên Nam xử lý rất nhanh và nhiệt tình, hướng dẫn cặn kẽ cách tự khắc phục!',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        acceptedAt: DateTime.now().subtract(const Duration(days: 1, hours: -1)),
        completedAt: DateTime.now().subtract(const Duration(hours: 20)),
      ),
    ];

    permissions = [
      PermissionModel(
        permissionId: 1,
        userId: 2, // IT Nam
        itName: 'Lê Hoàng Nam',
        deviceId: 1, // PC Kế toán Mai
        deviceName: 'PC-KETOAN-01 (Máy kế toán Mai)',
        vynexId: '948 201 543',
        permissionType: 'control',
        grantedAt: DateTime.now().subtract(const Duration(hours: 4)),
        expiresAt: DateTime.now().add(const Duration(hours: 20)), // 24h
        notes: 'Cấp quyền 24h để hỗ trợ xử lý lỗi phần mềm kế toán MISA',
        status: true,
      ),
      PermissionModel(
        permissionId: 2,
        userId: 2, // IT Nam
        itName: 'Lê Hoàng Nam',
        deviceId: 3, // File Server
        deviceName: 'SRV-FILE-VYNEX (File Server Nội bộ)',
        vynexId: '102 384 756',
        permissionType: 'full',
        grantedAt: DateTime.now().subtract(const Duration(days: 10)),
        expiresAt: null, // Vĩnh viễn (Forever)
        notes: 'Quyền quản trị máy chủ lưu trữ nội bộ công ty',
        status: true,
      ),
      PermissionModel(
        permissionId: 3,
        userId: 3, // IT Tuấn
        itName: 'Trần Minh Tuấn',
        deviceId: 2,
        deviceName: 'LAPTOP-KD-LONG (ThinkPad X1)',
        vynexId: '832 910 119',
        permissionType: 'view',
        grantedAt: DateTime.now().subtract(const Duration(days: 8)),
        expiresAt: DateTime.now().subtract(const Duration(days: 1)), // Hết hạn 7 ngày
        notes: 'Cấp quyền 7 ngày hỗ trợ cấu hình Outlook',
        status: true,
      ),
    ];

    sessions = [
      RemoteSessionModel(
        sessionId: 501,
        requestId: 103,
        itUserId: 2,
        itName: 'Lê Hoàng Nam',
        targetUserId: 6,
        targetName: 'Vũ Hải Đăng',
        deviceId: 4,
        deviceName: 'PC-NHANSU-DANG',
        vynexId: '554 123 908',
        connectionType: 'direct',
        qualityScore: 5,
        itIpAddress: '192.168.1.102',
        notes: 'Đã kiểm tra cấu hình mạng LAN, restart SQL Browser service.',
        startedAt: DateTime.now().subtract(const Duration(hours: 21)),
        endedAt: DateTime.now().subtract(const Duration(hours: 20, minutes: 40)),
        durationSeconds: 1200,
        status: 'ended',
      ),
      RemoteSessionModel(
        sessionId: 502,
        requestId: 102,
        itUserId: 2,
        itName: 'Lê Hoàng Nam',
        targetUserId: 5,
        targetName: 'Đỗ Hoàng Long',
        deviceId: 2,
        deviceName: 'LAPTOP-KD-LONG',
        vynexId: '832 910 119',
        connectionType: 'relay',
        qualityScore: 4,
        itIpAddress: '192.168.1.102',
        notes: 'Cài đặt WireGuard client và import file cấu hình peer1.conf',
        startedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
        endedAt: DateTime.now().subtract(const Duration(hours: 1)),
        durationSeconds: 900,
        status: 'ended',
      ),
    ];

    notifications = [
      NotificationModel(
        notificationId: 1,
        userId: 2,
        title: 'Yêu cầu hỗ trợ mới #101',
        content: 'Nhân viên Phạm Thị Mai gửi yêu cầu: "Lỗi không in được hóa đơn điện tử qua mạng LAN"',
        type: 'support_request',
        referenceId: 101,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      NotificationModel(
        notificationId: 2,
        userId: 2,
        title: 'Admin đã cấp quyền truy cập máy',
        content: 'Bạn đã được Admin cấp quyền điều khiển máy PC-KETOAN-01 thời hạn 24 giờ.',
        type: 'permission_granted',
        referenceId: 1,
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      NotificationModel(
        notificationId: 3,
        userId: 6,
        title: 'Phiên hỗ trợ hoàn tất',
        content: 'Phiên hỗ trợ #103 đã hoàn tất. Vui lòng đánh giá chất lượng phục vụ của IT Staff.',
        type: 'session_ended',
        referenceId: 103,
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 20)),
      ),
    ];

    activityLogs = [
      ActivityLogModel(
        logId: 1,
        userId: 1,
        userName: 'Nguyễn Văn An (Admin)',
        action: 'PERMISSION_GRANT',
        description: 'Admin cấp quyền "Điều khiển" máy PC-KETOAN-01 cho IT Lê Hoàng Nam (thời hạn 24h)',
        ipAddress: '192.168.1.100',
        targetType: 'Device',
        status: 'success',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      ActivityLogModel(
        logId: 2,
        userId: 2,
        userName: 'Lê Hoàng Nam (IT Staff)',
        action: 'SESSION_START',
        description: 'Bắt đầu phiên điều khiển từ xa đến PC-NHANSU-DANG qua direct connection',
        ipAddress: '192.168.1.102',
        targetType: 'RemoteSession',
        status: 'success',
        createdAt: DateTime.now().subtract(const Duration(hours: 21)),
      ),
      ActivityLogModel(
        logId: 3,
        userId: 4,
        userName: 'Phạm Thị Mai (Employee)',
        action: 'TICKET_CREATE',
        description: 'Tạo yêu cầu hỗ trợ mới: Lỗi không in được hóa đơn',
        ipAddress: '192.168.1.104',
        targetType: 'SupportRequest',
        status: 'success',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
    ];

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
