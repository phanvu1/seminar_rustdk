import 'dart:async';
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
  Timer? _refreshTimer;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDevices();
      _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (mounted) _fetchDevices(isSilent: true);
      });
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchDevices({bool isSilent = false}) async {
    if (!isSilent) setState(() => _isRefreshing = true);
    final api = Provider.of<ApiService>(context, listen: false);
    await api.getDevices();
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  String _formatIpWithPeer(String? ip) {
    if (ip == null || ip.isEmpty) return 'N/A';
    final trimmed = ip.trim();
    final match = RegExp(r'^10\.13\.13\.(\d+)$').firstMatch(trimmed);
    if (match != null) {
      final octet = int.tryParse(match.group(1)!);
      if (octet != null) {
        if (octet == 1) return '$trimmed (Gateway / Server)';
        return '$trimmed (Peer ${octet - 1})';
      }
    }
    return trimmed;
  }

  Future<void> _showAddDeviceDialog(BuildContext context) async {
    final api = Provider.of<ApiService>(context, listen: false);
    // Đồng bộ danh sách người dùng và phòng ban mới nhất từ Server
    await Future.wait([
      api.getUsers(),
      api.getDepartments(),
      api.getDevices(),
    ]);
    if (!mounted) return;

    final mock = MockDataService();
    final nameController = TextEditingController();
    final vynexIdController = TextEditingController();

    final peerList = <Map<String, String>>[
      for (int i = 1; i <= 20; i++)
        {
          'id': 'peer$i',
          'label': 'Peer $i (10.13.13.${i + 1})${i == 1 ? " - Admin" : (i == 7 ? " - Máy Gia Bảo" : "")}',
          'ip': '10.13.13.${i + 1}',
        },
      {'id': 'custom', 'label': 'Nhập IP tùy chỉnh khác...', 'ip': ''},
    ];

    // Mặc định chọn Peer 7 (10.13.13.8) nếu có nhân viên mới
    String selectedPeer = 'peer7';
    final ipController = TextEditingController(text: '10.13.13.8');

    String selectedType = 'desktop';

    // Ưu tiên chọn nhân viên mới nhất (không phải Admin)
    final nonAdmins = mock.users.where((u) => u.userId != 1).toList();
    int selectedUser = nonAdmins.isNotEmpty
        ? nonAdmins.last.userId
        : (mock.users.isNotEmpty ? mock.users.first.userId : 1);

    final initialUser = mock.users.firstWhere(
      (u) => u.userId == selectedUser,
      orElse: () => mock.users.first,
    );
    int selectedDept = initialUser.departmentId ?? (mock.departments.isNotEmpty ? mock.departments.first.departmentId : 1);

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
                width: 520,
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
                          hintText: 'Ví dụ: Máy của Bảo (Kế toán)',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Text(
                              'Vynex ID (Mã kết nối RustDesk/Vynex):',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              setDialogState(() {
                                vynexIdController.text =
                                    '${100 + (DateTime.now().millisecond * 7) % 800} ${(DateTime.now().microsecond * 3) % 900} ${(DateTime.now().millisecond * 11) % 900}';
                              });
                            },
                            icon: const Icon(Icons.refresh, size: 14),
                            label: const Text('Tạo ID mẫu', style: TextStyle(fontSize: 11)),
                            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: vynexIdController,
                        decoration: const InputDecoration(
                          hintText: '9 chữ số hiển thị trên máy đối tác (ví dụ: 93 643 131)',
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

                      const Text('Gán WireGuard Peer / IP VPN:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: selectedPeer,
                        isExpanded: true,
                        decoration: const InputDecoration(isDense: true),
                        items: peerList.map((p) {
                          return DropdownMenuItem<String>(
                            value: p['id']!,
                            child: Text(p['label']!, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() {
                              selectedPeer = v;
                              if (v != 'custom') {
                                final found = peerList.firstWhere((p) => p['id'] == v);
                                ipController.text = found['ip']!;
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: ipController,
                        decoration: InputDecoration(
                          hintText: '10.13.13.x (ví dụ: 10.13.13.8 cho Peer 7)',
                          helperText: 'Hệ thống dùng IP này để quét trạng thái và thiết lập kết nối VPN',
                          helperStyle: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          isDense: true,
                        ),
                        onChanged: (val) {
                          final match = peerList.firstWhere((p) => p['ip'] == val.trim(), orElse: () => {'id': 'custom'});
                          if (match['id'] != selectedPeer) {
                            setDialogState(() => selectedPeer = match['id']!);
                          }
                        },
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
                            child: Text(
                              '${u.fullName} (@${u.username})${u.userId == 1 ? " [ADMIN]" : ""}',
                              style: TextStyle(
                                fontWeight: u.userId == 1 ? FontWeight.bold : FontWeight.normal,
                                color: u.userId == 1 ? const Color(0xFFEF4444) : null,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() {
                              selectedUser = v;
                              final u = mock.users.firstWhere((user) => user.userId == v, orElse: () => mock.users.first);
                              if (u.departmentId != null) {
                                selectedDept = u.departmentId!;
                              }
                            });
                          }
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
                        content: Text('Đã lưu và kích hoạt thiết bị thành công!'),
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

  Future<void> _showEditDeviceDialog(BuildContext context, DeviceModel device) async {
    final api = Provider.of<ApiService>(context, listen: false);
    await Future.wait([
      api.getUsers(),
      api.getDepartments(),
    ]);
    if (!mounted) return;

    final mock = MockDataService();
    final nameController = TextEditingController(text: device.name);
    final vynexIdController = TextEditingController(text: device.vynexId);
    final ipController = TextEditingController(text: device.ipAddress ?? '');
    String selectedType = device.deviceType;
    int selectedDept = device.departmentId ?? (mock.departments.isNotEmpty ? mock.departments.first.departmentId : 1);
    int selectedUser = device.userId ?? (mock.users.isNotEmpty ? mock.users.first.userId : 1);

    final peerList = <Map<String, String>>[
      for (int i = 1; i <= 20; i++)
        {
          'id': 'peer$i',
          'label': 'Peer $i (10.13.13.${i + 1})${i == 1 ? " - Admin" : (i == 7 ? " - Máy Gia Bảo" : "")}',
          'ip': '10.13.13.${i + 1}',
        },
      {'id': 'custom', 'label': 'Nhập IP tùy chỉnh khác...', 'ip': ''},
    ];

    String selectedPeer = 'custom';
    for (final p in peerList) {
      if (p['ip'] == (device.ipAddress ?? '').trim()) {
        selectedPeer = p['id']!;
        break;
      }
    }

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
                  Icon(Icons.edit_note_rounded, color: AppConstants.primaryBlue),
                  SizedBox(width: 10),
                  Text('Chỉnh Sửa Thông Tin Thiết Bị'),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tên thiết bị:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(isDense: true),
                      ),
                      const SizedBox(height: 14),

                      const Text('Vynex ID (Mã kết nối RustDesk/Vynex):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: vynexIdController,
                        decoration: const InputDecoration(isDense: true),
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

                      const Text('Gán WireGuard Peer / IP VPN:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: selectedPeer,
                        isExpanded: true,
                        decoration: const InputDecoration(isDense: true),
                        items: peerList.map((p) {
                          return DropdownMenuItem<String>(
                            value: p['id']!,
                            child: Text(p['label']!, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() {
                              selectedPeer = v;
                              if (v != 'custom') {
                                final found = peerList.firstWhere((p) => p['id'] == v);
                                ipController.text = found['ip']!;
                              }
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: ipController,
                        decoration: InputDecoration(
                          hintText: '10.13.13.x',
                          helperText: 'Cập nhật IP theo đúng file WireGuard của máy đối tác',
                          helperStyle: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          isDense: true,
                        ),
                        onChanged: (val) {
                          final match = peerList.firstWhere((p) => p['ip'] == val.trim(), orElse: () => {'id': 'custom'});
                          if (match['id'] != selectedPeer) {
                            setDialogState(() => selectedPeer = match['id']!);
                          }
                        },
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
                            child: Text(
                              '${u.fullName} (@${u.username})${u.userId == 1 ? " [ADMIN]" : ""}',
                              style: TextStyle(
                                fontWeight: u.userId == 1 ? FontWeight.bold : FontWeight.normal,
                                color: u.userId == 1 ? const Color(0xFFEF4444) : null,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() {
                              selectedUser = v;
                              final u = mock.users.firstWhere((user) => user.userId == v, orElse: () => mock.users.first);
                              if (u.departmentId != null) {
                                selectedDept = u.departmentId!;
                              }
                            });
                          }
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
                    await api.updateDevice(device.deviceId, {
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
                        content: Text('Đã cập nhật thông tin thiết bị thành công!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Lưu Thay Đổi'),
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
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _isRefreshing ? null : () => _fetchDevices(),
                    icon: _isRefreshing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.sync_rounded, size: 18),
                    label: Text(_isRefreshing ? 'Đang đồng bộ...' : 'Làm Mới Trạng Thái'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 10),
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
                              'Vynex ID: ${dev.vynexId}  •  IP: ${_formatIpWithPeer(dev.ipAddress)}  •  OS: ${dev.osName ?? "Windows"}',
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
                          final isAdmin = auth.currentUser.role == UserRole.admin || auth.activeRole == UserRole.admin;
                          final hasPerm = isAdmin || permService.hasPermission(auth.currentUser.userId, dev.deviceId);
                          final hasRequested = permService.hasRequestedPermission(dev.deviceId);

                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (dev.userId == 1 && auth.currentUser.userId != 1) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFFCA5A5)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.shield_rounded, size: 14, color: Color(0xFFDC2626)),
                                      SizedBox(width: 6),
                                      Text(
                                        'Bảo Vệ Admin (Cấm Điều Khiển)',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                if (!hasPerm && !isAdmin && auth.activeRole == UserRole.it) ...[
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
                                    if (dev.userId == 1 && auth.currentUser.userId != 1) {
                                      showDialog(
                                        context: context,
                                        builder: (c) => AlertDialog(
                                          title: const Row(
                                            children: [
                                              Icon(Icons.shield_rounded, color: Color(0xFFEF4444)),
                                              SizedBox(width: 8),
                                              Text('Bảo Vệ Máy Quản Trị Viên'),
                                            ],
                                          ),
                                          content: const Text(
                                            'Đây là thiết bị của Quản Trị Viên (Admin).\n\n'
                                            'Chính sách bảo mật Unidirectional Guard nghiêm cấm mọi tài khoản khác điều khiển máy của Admin dưới bất kỳ hình thức nào!',
                                          ),
                                          actions: [
                                            TextButton(onPressed: () => Navigator.pop(c), child: const Text('Đã hiểu')),
                                          ],
                                        ),
                                      );
                                      return;
                                    }
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
                                            ElevatedButton.icon(
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
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppConstants.primaryBlue,
                                                foregroundColor: Colors.white,
                                              ),
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
                                icon: const Icon(Icons.edit_note_rounded, color: AppConstants.primaryBlue, size: 20),
                                tooltip: 'Chỉnh sửa thông tin thiết bị',
                                onPressed: () => _showEditDeviceDialog(context, dev),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 18),
                                tooltip: 'Xóa thiết bị',
                                onPressed: () => _showDeleteConfirm(context, dev),
                              ),
                            ],
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
