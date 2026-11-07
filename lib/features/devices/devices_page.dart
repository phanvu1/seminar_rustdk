import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/network/api_service.dart';
import '../../models/device_model.dart';
import '../../services/auth_service.dart';
import '../../services/permission_service.dart';
import '../../services/mock_data_service.dart';
import '../../services/vynex_launcher_service.dart';
import '../../shared/widgets/search_filter_bar.dart';
import '../../shared/widgets/status_badge.dart';

class DevicesPage extends StatefulWidget {
  const DevicesPage({Key? key}) : super(key: key);

  @override
  State<DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> {
  String _searchQuery = '';
  String _departmentFilter = 'all';
  String _typeFilter = 'all';
  String _statusFilter = 'all';

  void _showAddDeviceDialog(BuildContext context) {
    final mock = MockDataService();
    final api = Provider.of<ApiService>(context, listen: false);

    final nameController = TextEditingController();
    final vynexIdController = TextEditingController(
      text: '${100 + (DateTime.now().millisecond * 7) % 800} ${(DateTime.now().microsecond * 3) % 900} ${(DateTime.now().millisecond * 11) % 900}',
    );
    final ipController = TextEditingController(text: '192.168.1.${120 + mock.devices.length}');
    String selectedType = 'desktop';
    int selectedDept = mock.departments.first.departmentId;
    int selectedUser = mock.users.first.userId;

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              title: const Row(
                children: [
                  Icon(Icons.add_to_queue_rounded, color: AppConstants.primaryBlue),
                  SizedBox(width: 10),
                  Text('Đăng Ký Thiết Bị Mới Vào Hệ Thống'),
                ],
              ),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tên thiết bị:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: 'Ví dụ: PC-KE-TOAN-05 (Máy kế toán Linh)',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 14),

                      const Text('Vynex ID (Mã kết nối RustDesk/Vynex):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: vynexIdController,
                        decoration: const InputDecoration(
                          hintText: '9 chữ số, ví dụ: 948 201 543',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Loại máy:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: selectedType,
                                  decoration: const InputDecoration(isDense: true),
                                  items: const [
                                    DropdownMenuItem(value: 'desktop', child: Text('Desktop (Máy bàn)')),
                                    DropdownMenuItem(value: 'laptop', child: Text('Laptop (Máy xách tay)')),
                                    DropdownMenuItem(value: 'server', child: Text('Server (Máy chủ)')),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) setDialogState(() => selectedType = v);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Phòng ban:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<int>(
                                  value: selectedDept,
                                  isExpanded: true,
                                  decoration: const InputDecoration(isDense: true),
                                  items: mock.departments.map((d) {
                                    return DropdownMenuItem<int>(
                                      value: d.departmentId,
                                      child: Text(d.name, overflow: TextOverflow.ellipsis),
                                    );
                                  }).toList(),
                                  onChanged: (v) {
                                    if (v != null) setDialogState(() => selectedDept = v);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      const Text('Địa chỉ IP nội bộ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: ipController,
                        decoration: const InputDecoration(
                          hintText: '192.168.1.xxx',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 14),

                      const Text('Gán cho nhân viên sử dụng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        value: selectedUser,
                        isExpanded: true,
                        decoration: const InputDecoration(isDense: true),
                        items: mock.users.map((u) {
                          return DropdownMenuItem<int>(
                            value: u.userId,
                            child: Text('${u.fullName} (@${u.username})'),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setDialogState(() => selectedUser = v);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nameController.text.trim().isEmpty) return;
                    await api.createDevice({
                      'device_name': nameController.text.trim(),
                      'rustdesk_id': vynexIdController.text.trim(),
                      'user_id': selectedUser,
                      'department_id': selectedDept,
                      'device_type': selectedType,
                      'ip_address': ipController.text.trim(),
                    });
                    if (!mounted) return;
                    Navigator.pop(ctx);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã thêm thiết bị mới thành công!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Thêm Thiết Bị'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirm(BuildContext context, DeviceModel device) {
    final api = Provider.of<ApiService>(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Xác nhận xóa thiết bị'),
          content: Text('Bạn có chắc chắn muốn xóa "${device.name}" (${device.vynexId}) khỏi danh sách quản lý?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                await api.deleteDevice(device.deviceId);
                if (!mounted) return;
                Navigator.pop(ctx);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã xóa thiết bị thành công!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mock = MockDataService();

    List<DeviceModel> devices = List.from(mock.devices);

    // Apply Filters
    if (_departmentFilter != 'all') {
      devices = devices.where((d) => d.departmentId.toString() == _departmentFilter).toList();
    }
    if (_typeFilter != 'all') {
      devices = devices.where((d) => d.deviceType.toLowerCase() == _typeFilter.toLowerCase()).toList();
    }
    if (_statusFilter != 'all') {
      devices = devices.where((d) => d.status.toLowerCase() == _statusFilter.toLowerCase()).toList();
    }
    if (_searchQuery.isNotEmpty) {
      devices = devices.where((d) {
        final q = _searchQuery.toLowerCase();
        return d.name.toLowerCase().contains(q) ||
            d.vynexId.toLowerCase().contains(q) ||
            (d.userName ?? '').toLowerCase().contains(q) ||
            (d.ipAddress ?? '').contains(q);
      }).toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quản lý Thiết bị (Devices Management)',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toàn bộ máy trạm, máy tính xách tay và máy chủ kết nối hệ thống Vynex',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddDeviceDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Thêm Thiết Bị Mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search & Filters Row
          SearchFilterBar(
            hintText: 'Tìm theo tên máy, Vynex ID, IP, nhân viên...',
            onSearchChanged: (v) => setState(() => _searchQuery = v),
            filterActions: [
              // Dept filter
              DropdownButton<String>(
                value: _departmentFilter,
                underline: const SizedBox(),
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                items: [
                  const DropdownMenuItem(value: 'all', child: Text('Tất cả phòng ban')),
                  ...mock.departments.map(
                    (d) => DropdownMenuItem(value: d.departmentId.toString(), child: Text(d.name)),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _departmentFilter = v);
                },
              ),
              const SizedBox(width: 8),

              // Device Type filter
              DropdownButton<String>(
                value: _typeFilter,
                underline: const SizedBox(),
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tất cả loại máy')),
                  DropdownMenuItem(value: 'desktop', child: Text('Desktop (Máy bàn)')),
                  DropdownMenuItem(value: 'laptop', child: Text('Laptop')),
                  DropdownMenuItem(value: 'server', child: Text('Server (Máy chủ)')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _typeFilter = v);
                },
              ),
              const SizedBox(width: 8),

              // Status filter
              DropdownButton<String>(
                value: _statusFilter,
                underline: const SizedBox(),
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tất cả trạng thái')),
                  DropdownMenuItem(value: 'online', child: Text('Trực tuyến (Online)')),
                  DropdownMenuItem(value: 'offline', child: Text('Ngoại tuyến (Offline)')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _statusFilter = v);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Devices Data Table Card
          Card(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: devices.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final dev = devices[index];
                IconData typeIcon = Icons.computer_rounded;
                if (dev.deviceType == 'laptop') typeIcon = Icons.laptop_mac_rounded;
                if (dev.deviceType == 'server') typeIcon = Icons.dns_rounded;

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Device Icon with online ring
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: dev.isOnline
                                  ? AppConstants.primaryBlue.withOpacity(0.12)
                                  : Colors.grey.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              typeIcon,
                              color: dev.isOnline ? AppConstants.primaryBlue : Colors.grey,
                              size: 24,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: dev.isOnline ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),

                      // Name, ID, user
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dev.name,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Vynex ID: ${dev.vynexId}  •  IP: ${dev.ipAddress ?? "N/A"}  •  OS: ${dev.osName ?? "Windows"}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),

                      // Department & User
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dev.departmentName ?? 'Chưa gán',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Người dùng: ${dev.userName ?? "Chung"}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),

                      // Status Badge
                      StatusBadge(status: dev.status),
                      const SizedBox(width: 16),

                      // Actions
                      Consumer<PermissionService>(
                        builder: (context, permService, _) {
                          final auth = Provider.of<AuthService>(context);
                          final hasPerm = permService.hasPermission(auth.currentUser.userId, dev.deviceId);
                          final hasRequested = permService.hasRequestedPermission(dev.deviceId);

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!hasPerm && (auth.activeRole == UserRole.it || auth.activeRole == UserRole.admin)) ...[
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    await permService.requestPermission(
                                      itUserId: auth.currentUser.userId,
                                      itName: auth.currentUser.fullName,
                                      deviceId: dev.deviceId,
                                      deviceName: dev.name,
                                      vynexId: dev.vynexId,
                                      reason: 'Yêu cầu quyền điều khiển từ xa thiết bị ${dev.name}',
                                    );
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Đã gửi yêu cầu xin cấp quyền tới Admin!'),
                                        backgroundColor: Color(0xFFF59E0B),
                                      ),
                                    );
                                  },
                                  icon: Icon(hasRequested ? Icons.hourglass_top_rounded : Icons.vpn_key_rounded, size: 14),
                                  label: Text(hasRequested ? 'Đã gửi yêu cầu' : 'Yêu cầu cấp quyền kết nối'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: hasRequested ? const Color(0xFFD97706) : const Color(0xFFF59E0B),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              ElevatedButton.icon(
                                onPressed: () async {
                                  if (!hasPerm) {
                                    showDialog(
                                      context: context,
                                      builder: (c) {
                                        final isDarkDialog = Theme.of(c).brightness == Brightness.dark;
                                        return AlertDialog(
                                          backgroundColor: isDarkDialog ? const Color(0xFF1E293B) : Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                          title: Row(
                                            children: [
                                              const Icon(Icons.gpp_bad_rounded, color: Color(0xFFEF4444)),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Chưa Có Quyền Truy Cập',
                                                style: TextStyle(
                                                  color: isDarkDialog ? Colors.white : const Color(0xFF0F172A),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: Text(
                                            'Bạn chưa được cấp quyền điều khiển máy "${dev.name}" (${dev.vynexId}).',
                                            style: TextStyle(
                                              color: isDarkDialog ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                              fontSize: 13,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(c),
                                              child: const Text('Đóng'),
                                            ),
                                            OutlinedButton.icon(
                                              onPressed: () async {
                                                await permService.requestPermission(
                                                  itUserId: auth.currentUser.userId,
                                                  itName: auth.currentUser.fullName,
                                                  deviceId: dev.deviceId,
                                                  deviceName: dev.name,
                                                  vynexId: dev.vynexId,
                                                  reason: 'Yêu cầu quyền điều khiển máy ${dev.name}',
                                                );
                                                if (!mounted) return;
                                                Navigator.pop(c);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Đã gửi yêu cầu xin cấp quyền tới Admin!'),
                                                    backgroundColor: Color(0xFFF59E0B),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.send_rounded, size: 14),
                                              label: const Text('Gửi yêu cầu tới Admin'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                await permService.grantPermission(
                                                  itUserId: auth.currentUser.userId,
                                                  itName: auth.currentUser.fullName,
                                                  deviceId: dev.deviceId,
                                                  deviceName: dev.name,
                                                  vynexId: dev.vynexId,
                                                  permissionType: 'control',
                                                  durationType: '24h',
                                                );
                                                if (!mounted) return;
                                                Navigator.pop(c);
                                              },
                                              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryBlue),
                                              child: const Text('[Demo] Cấp Quyền 24h'),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    return;
                                  }

                                  final token = permService.generateSessionToken(auth.currentUser.userId, dev.deviceId);
                                  final launchResult = await VynexLauncherService.launchClient(
                                    vynexId: dev.vynexId,
                                    token: token,
                                    itUserId: auth.currentUser.userId,
                                  );

                                  if (!mounted) return;

                                  if (launchResult.success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Đã kích hoạt Vynex Client (.exe) kết nối tới máy ${dev.name} (${dev.vynexId})'),
                                        backgroundColor: const Color(0xFF10B981),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(launchResult.message),
                                        backgroundColor: const Color(0xFFEF4444),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.cast_connected, size: 14),
                                label: Text(hasPerm ? 'Kết Nối Ngay' : 'Kết Nối'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: hasPerm ? const Color(0xFF10B981) : AppConstants.primaryBlue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                                tooltip: 'Xóa thiết bị',
                                onPressed: () => _showDeleteConfirm(context, dev),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
