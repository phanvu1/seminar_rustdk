import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/permission_model.dart';
import '../../services/mock_data_service.dart';
import '../../services/permission_service.dart';
import '../../shared/widgets/search_filter_bar.dart';
import '../../shared/widgets/status_badge.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({Key? key}) : super(key: key);

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  String _searchQuery = '';
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PermissionService>(context, listen: false).fetchPermissions();
    });
  }

  void _showGrantPermissionDialog(BuildContext context) {
    final mock = MockDataService();
    final permService = Provider.of<PermissionService>(context, listen: false);

    final itUsers = mock.users.where((u) => u.role == UserRole.it).toList();
    if (itUsers.isEmpty) return;

    int selectedItId = itUsers.first.userId;
    int selectedDeviceId = mock.devices.first.deviceId;
    String selectedPermType = 'control';
    String selectedDuration = '24h';
    final notesController = TextEditingController(text: 'Cấp quyền phục vụ kiểm tra và sửa lỗi hệ thống');

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
                  Icon(Icons.vpn_key_rounded, color: AppConstants.primaryBlue),
                  SizedBox(width: 10),
                  Text('Admin Cấp Quyền IT - Thiết Bị'),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Theo chính sách bảo mật Vynex RBAC, chỉ tài khoản Admin mới có thẩm quyền ủy quyền kết nối từ xa giữa IT Staff và máy tính nhân viên.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 16),

                      const Text('Chọn Kỹ thuật viên (IT Staff):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        value: selectedItId,
                        isExpanded: true,
                        decoration: const InputDecoration(isDense: true),
                        items: itUsers.map((u) {
                          return DropdownMenuItem<int>(
                            value: u.userId,
                            child: Text('${u.fullName} (@${u.username})'),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setDialogState(() => selectedItId = v);
                        },
                      ),
                      const SizedBox(height: 14),

                      const Text('Chọn Thiết bị nhân viên được cấp quyền:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        value: selectedDeviceId,
                        isExpanded: true,
                        decoration: const InputDecoration(isDense: true),
                        items: mock.devices.map((d) {
                          return DropdownMenuItem<int>(
                            value: d.deviceId,
                            child: Text('${d.name} (${d.vynexId})'),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setDialogState(() => selectedDeviceId = v);
                        },
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Loại quyền hạn:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: selectedPermType,
                                  decoration: const InputDecoration(isDense: true),
                                  items: const [
                                    DropdownMenuItem(value: 'control', child: Text('Điều khiển (Control)')),
                                    DropdownMenuItem(value: 'view', child: Text('Chỉ xem (View Only)')),
                                    DropdownMenuItem(value: 'file_transfer', child: Text('Truyền tệp')),
                                    DropdownMenuItem(value: 'full', child: Text('Toàn quyền (Full)')),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) setDialogState(() => selectedPermType = v);
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
                                const Text('Thời hạn hiệu lực:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: selectedDuration,
                                  decoration: const InputDecoration(isDense: true),
                                  items: const [
                                    DropdownMenuItem(value: '24h', child: Text('24 Giờ (Tạm thời)')),
                                    DropdownMenuItem(value: '7d', child: Text('7 Ngày (Dài hạn)')),
                                    DropdownMenuItem(value: 'forever', child: Text('Vĩnh viễn (Forever)')),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) setDialogState(() => selectedDuration = v);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      const Text('Ghi chú lý do cấp quyền:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: notesController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Nhập lý do hoặc số ticket yêu cầu hỗ trợ...',
                          isDense: true,
                        ),
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
                    final itUser = itUsers.firstWhere((u) => u.userId == selectedItId);
                    final device = mock.devices.firstWhere((d) => d.deviceId == selectedDeviceId);

                    await permService.grantPermission(
                      itUserId: itUser.userId,
                      itName: itUser.fullName,
                      deviceId: device.deviceId,
                      deviceName: device.name,
                      vynexId: device.vynexId,
                      permissionType: selectedPermType,
                      durationType: selectedDuration,
                      notes: notesController.text.trim(),
                    );

                    if (!mounted) return;
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã cấp quyền thành công cho IT ${itUser.fullName} (Thời hạn: $selectedDuration)!'),
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Xác Nhận Cấp Quyền'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final permService = Provider.of<PermissionService>(context);
    final mock = MockDataService();

    List<PermissionModel> list = permService.permissions.isNotEmpty ? permService.permissions : mock.permissions;

    if (_statusFilter == 'valid') {
      list = list.where((p) => p.isValid).toList();
    } else if (_statusFilter == 'expired') {
      list = list.where((p) => !p.isValid).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((p) =>
              p.itName.toLowerCase().contains(q) ||
              p.deviceName.toLowerCase().contains(q) ||
              p.vynexId.toLowerCase().contains(q))
          .toList();
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
                    'Phân quyền IT - Thiết bị (Access Control)',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quản lý ủy quyền bảo mật: Cấp quyền có thời hạn (24h, 7 ngày, Vĩnh viễn) và thu hồi tức thì',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showGrantPermissionDialog(context),
                icon: const Icon(Icons.add_moderator_rounded, size: 18),
                label: const Text('Cấp Quyền Truy Cập Mới'),
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

          // Search & Filter
          SearchFilterBar(
            hintText: 'Tìm theo IT, tên máy hoặc Vynex ID...',
            onSearchChanged: (v) => setState(() => _searchQuery = v),
            filterActions: [
              DropdownButton<String>(
                value: _statusFilter,
                underline: const SizedBox(),
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tất cả quyền')),
                  DropdownMenuItem(value: 'valid', child: Text('Còn hiệu lực')),
                  DropdownMenuItem(value: 'expired', child: Text('Đã hết hạn / Thu hồi')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _statusFilter = v);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Permissions Table
          Card(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final p = list[index];
                final isValid = p.isValid;

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Key Icon
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isValid
                              ? const Color(0xFF10B981).withOpacity(0.12)
                              : const Color(0xFFEF4444).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isValid ? Icons.vpn_key_rounded : Icons.key_off_rounded,
                          color: isValid ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // IT & Target Device
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'IT: ${p.itName}  ➔  ${p.deviceName}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Vynex ID: ${p.vynexId}  •  Quyền: ${p.permissionType.toUpperCase()}  •  Ghi chú: ${p.notes ?? "N/A"}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),

                      // Time and Expiry
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thời hạn: ${p.expiryLabel}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: isValid ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Cấp lúc: ${DateFormat('dd/MM/yyyy HH:mm').format(p.grantedAt)}',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ),

                      // Badge
                      StatusBadge(
                        status: isValid ? 'active' : 'revoked',
                        customLabel: isValid ? 'ĐANG CÓ HIỆU LỰC' : 'HẾT HẠN / THU HỒI',
                      ),
                      const SizedBox(width: 16),

                      // Revoke Button
                      if (isValid)
                        OutlinedButton.icon(
                          onPressed: () async {
                            await permService.revokePermission(p.permissionId);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã thu hồi quyền truy cập thành công!')),
                            );
                          },
                          icon: const Icon(Icons.block_rounded, size: 14, color: Color(0xFFEF4444)),
                          label: const Text('Thu Hồi', style: TextStyle(color: Color(0xFFEF4444))),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFCA5A5)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        )
                      else
                        const Text(
                          'Đã vô hiệu hóa',
                          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic),
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
