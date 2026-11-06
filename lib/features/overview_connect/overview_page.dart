import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/auth_service.dart';
import '../../services/permission_service.dart';
import '../../services/mock_data_service.dart';
import '../../services/vynex_launcher_service.dart';
import '../../shared/widgets/status_badge.dart';

class OverviewPage extends StatefulWidget {
  final ValueChanged<String>? onNavigate;
  const OverviewPage({Key? key, this.onNavigate}) : super(key: key);

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  final _remoteIdController = TextEditingController(text: '948 201 543');
  final String _localId = '832 910 119';
  String _oneTimePassword = 'vyn${Random().nextInt(900) + 100}';
  bool _obscurePassword = false;

  void _refreshPassword() {
    setState(() {
      const chars = 'abcdefghjkmnpqrstuvwxyz23456789';
      final rand = Random();
      _oneTimePassword = List.generate(6, (index) => chars[rand.nextInt(chars.length)]).join();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã làm mới mật khẩu một lần của máy này'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã sao chép $label vào bộ nhớ tạm: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _connectToRemote(String targetId, {bool isFileTransfer = false}) async {
    if (targetId.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập Vynex ID hợp lệ')),
      );
      return;
    }

    final auth = Provider.of<AuthService>(context, listen: false);
    final permService = Provider.of<PermissionService>(context, listen: false);
    final mock = MockDataService();
    final device = mock.devices.firstWhere(
      (d) => d.vynexId.replaceAll(' ', '') == targetId.replaceAll(' ', ''),
      orElse: () => mock.devices.first,
    );

    // Kiểm tra quyền trên bảng Permissions
    final hasPerm = permService.hasPermission(auth.currentUser.userId, device.deviceId);
    if (!hasPerm) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.gpp_bad_rounded, color: Color(0xFFEF4444)),
              SizedBox(width: 10),
              Text('Chặn Kết Nối Bảo Mật (RBAC)', style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: Text(
            'Bạn không có quyền thực hiện kết nối tới thiết bị "${device.name}" (ID: ${device.vynexId}).\n'
            'Chính sách Vynex yêu cầu quản trị viên cấp quyền trước khi khởi tạo phiên.',
            style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
            ElevatedButton(
              onPressed: () async {
                await permService.grantPermission(
                  itUserId: auth.currentUser.userId,
                  itName: auth.currentUser.fullName,
                  deviceId: device.deviceId,
                  deviceName: device.name,
                  vynexId: device.vynexId,
                  permissionType: 'control',
                  durationType: '24h',
                );
                if (!mounted) return;
                Navigator.pop(ctx);
                _connectToRemote(targetId, isFileTransfer: isFileTransfer);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryBlue),
              child: const Text('[Demo] Cấp Quyền & Kết Nối'),
            ),
          ],
        ),
      );
      return;
    }

    // Đã có quyền hợp lệ -> Sinh Session Token và gọi Vynex Client (.exe)
    final sessionToken = permService.generateSessionToken(auth.currentUser.userId, device.deviceId);
    final launchResult = await VynexLauncherService.launchClient(
      vynexId: device.vynexId,
      token: sessionToken,
      itUserId: auth.currentUser.userId,
    );

    if (!mounted) return;

    if (launchResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Đã kích hoạt Vynex Client (.exe) kết nối máy ${device.name} (${device.vynexId})'),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 4),
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
  }

  @override
  void dispose() {
    _remoteIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mock = MockDataService();
    final totalDevices = mock.devices.length;
    final onlineDevices = mock.devices.where((d) => d.isOnline).length;
    final pendingTickets = mock.supportRequests.where((t) => t.status == 'pending').length;
    final totalSessions = mock.sessions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bảng điều khiển & Kết nối nhanh',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Kiểm soát và hỗ trợ máy tính từ xa chuẩn RustDesk qua Web Dashboard',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => widget.onNavigate?.call('tickets'),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tạo Yêu Cầu Hỗ Trợ'),
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

          // KPI Cards Row
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 900;
              return GridView.count(
                crossAxisCount: isWide ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: isWide ? 2.3 : 1.8,
                children: [
                  _buildKpiCard(
                    context,
                    title: 'Tổng thiết bị',
                    value: '$totalDevices',
                    subtext: 'Đã đăng ký hệ thống',
                    icon: Icons.devices_rounded,
                    color: const Color(0xFF3B82F6),
                    isDark: isDark,
                  ),
                  _buildKpiCard(
                    context,
                    title: 'Máy trực tuyến',
                    value: '$onlineDevices',
                    subtext: 'Heartbeat < 1 phút',
                    icon: Icons.wifi_tethering_rounded,
                    color: const Color(0xFF10B981),
                    isDark: isDark,
                  ),
                  _buildKpiCard(
                    context,
                    title: 'Yêu cầu chờ xử lý',
                    value: '$pendingTickets',
                    subtext: 'Cần IT tiếp nhận ngay',
                    icon: Icons.pending_actions_rounded,
                    color: const Color(0xFFF59E0B),
                    isDark: isDark,
                  ),
                  _buildKpiCard(
                    context,
                    title: 'Phiên kết nối',
                    value: '$totalSessions',
                    subtext: 'Đã hoàn tất hỗ trợ',
                    icon: Icons.history_rounded,
                    color: const Color(0xFF8B5CF6),
                    isDark: isDark,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // RustDesk Layout Split (Local Device Card + Remote Connect Card)
          LayoutBuilder(
            builder: (context, constraints) {
              final isStacked = constraints.maxWidth < 840;
              if (isStacked) {
                return Column(
                  children: [
                    _buildLocalDeviceCard(context, isDark),
                    const SizedBox(height: 20),
                    _buildRemoteConnectCard(context, isDark),
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: _buildLocalDeviceCard(context, isDark)),
                  const SizedBox(width: 20),
                  Expanded(flex: 7, child: _buildRemoteConnectCard(context, isDark)),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // Recent sessions list card
          _buildRecentSessionsCard(context, isDark),
        ],
      ),
    );
  }

  Widget _buildKpiCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtext,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    subtext,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalDeviceCard(BuildContext context, bool isDark) {
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.computer_rounded, color: AppConstants.primaryBlue, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Thiết bị này của bạn',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const StatusBadge(status: 'online', customLabel: 'Sẵn sàng'),
              ],
            ),
            const SizedBox(height: 18),

            // Local Vynex ID Display
            Text(
              'VYNEX ID (MÃ MÁY TÍNH)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _localId,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppConstants.primaryBlue,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    tooltip: 'Sao chép Vynex ID',
                    onPressed: () => _copyToClipboard(_localId, 'Vynex ID'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // One-time password
            Text(
              'MẬT KHẨ MỘT LẦN (ONE-TIME PASSWORD)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _obscurePassword ? '••••••' : _oneTimePassword,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 18,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        tooltip: 'Làm mới mật khẩu',
                        onPressed: _refreshPassword,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Metadata info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Địa chỉ IP:',
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                ),
                const Text(
                  '192.168.1.108 (LAN)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hệ điều hành:',
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.black54),
                ),
                const Text(
                  'Windows 11 Pro 64-bit',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemoteConnectCard(BuildContext context, bool isDark) {
    final mock = MockDataService();

    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.cast_connected_rounded, color: Color(0xFF10B981), size: 20),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Điều khiển màn hình từ xa (Remote Control)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Partner ID Input
            Text(
              'NHẬP VYNEX ID CỦA ĐỐI TÁC CẦN KẾT NỐI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _remoteIdController,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                    decoration: InputDecoration(
                      hintText: 'Ví dụ: 948 201 543',
                      prefixIcon: const Icon(Icons.terminal_rounded, size: 20),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _connectToRemote(_remoteIdController.text),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Kết Nối'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _connectToRemote(_remoteIdController.text, isFileTransfer: true),
                  icon: const Icon(Icons.folder_shared_rounded, size: 18),
                  label: const Text('Truyền Tệp'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Recent devices list
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thiết bị kết nối gần đây:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () => widget.onNavigate?.call('devices'),
                  child: const Text('Xem tất cả máy', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: mock.devices.take(4).map((dev) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _remoteIdController.text = dev.vynexId;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _remoteIdController.text == dev.vynexId
                            ? AppConstants.primaryBlue
                            : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dev.isOnline ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dev.name,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              dev.vynexId,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessionsCard(BuildContext context, bool isDark) {
    final mock = MockDataService();

    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lịch sử phiên hỗ trợ từ xa gần nhất',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => widget.onNavigate?.call('reports'),
                  child: const Text('Xem toàn bộ lịch sử', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mock.sessions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final s = mock.sessions[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppConstants.primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cast_connected, color: AppConstants.primaryBlue, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${s.itName}  ➔  ${s.targetName} (${s.deviceName})',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Vynex ID: ${s.vynexId} • Kết nối: ${s.connectionType.toUpperCase()} • Ghi chú: ${s.notes ?? "Không có"}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            children: List.generate(
                              5,
                              (starIdx) => Icon(
                                Icons.star_rounded,
                                size: 14,
                                color: starIdx < (s.qualityScore ?? 5)
                                    ? const Color(0xFFFBBF24)
                                    : const Color(0xFFCBD5E1),
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Thời lượng: ${(s.durationSeconds ?? 0) ~/ 60} phút',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
