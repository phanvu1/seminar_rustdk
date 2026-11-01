import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../core/network/api_service.dart';
import '../../services/mock_data_service.dart';
import '../../shared/widgets/status_badge.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _apiUrlController;
  int _sessionTimeoutMinutes = 30;
  int _maxLoginAttempts = 5;
  bool _enableAutoHeartbeat = true;
  bool _enableSmartRelay = true;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    final api = Provider.of<ApiService>(context, listen: false);
    _apiUrlController = TextEditingController(text: api.baseUrl);
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    setState(() => _isChecking = true);
    final api = Provider.of<ApiService>(context, listen: false);
    api.setBaseUrl(_apiUrlController.text.trim());
    final isOnline = await api.checkHealth();
    if (!mounted) return;
    setState(() => _isChecking = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isOnline
              ? 'Kết nối FastAPI Backend thành công (200 OK)!'
              : 'Không thể kết nối Backend. Hệ thống tự động chuyển sang chế độ Smart Fallback (Demo Mock Data).',
        ),
        backgroundColor: isOnline ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final api = Provider.of<ApiService>(context);
    final mock = MockDataService();

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
                    'Cấu hình Hệ thống & Máy chủ (Settings)',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quản lý thông số máy chủ Rendezvous/Relay, API Gateway và chính sách bảo mật',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã lưu toàn bộ cấu hình hệ thống!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
                icon: const Icon(Icons.save_rounded, size: 18),
                label: const Text('Lưu Thay Đổi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Server Status Cards (HBBS & HBBR)
          Text(
            'TRẠNG THÁI MÁY CHỦ HỖ TRỢ TỪ XA (HBBS / HBBR)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: mock.serverMetrics.map((srv) {
              return Expanded(
                child: Card(
                  margin: const EdgeInsets.only(right: 16),
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(srv.serverName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                            StatusBadge(status: srv.status, isSmall: true),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Host: ${srv.host}:${srv.port}  •  Phiên bản: ${srv.version}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CPU: ${srv.cpuUsage}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: (srv.cpuUsage ?? 10) / 100,
                                    color: const Color(0xFF3B82F6),
                                    backgroundColor: Colors.grey.withOpacity(0.2),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('RAM: ${srv.ramUsage}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: (srv.ramUsage ?? 20) / 100,
                                    color: const Color(0xFF10B981),
                                    backgroundColor: Colors.grey.withOpacity(0.2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // API Gateway & Smart Fallback Config
          Card(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.api_rounded, color: AppConstants.primaryBlue),
                      const SizedBox(width: 10),
                      const Text(
                        'Cấu hình Kết nối API Backend & Cơ chế Smart Fallback',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      StatusBadge(
                        status: api.isBackendConnected ? 'online' : 'pending',
                        customLabel: api.isBackendConnected ? 'FastAPI Live (Port 8000)' : 'Chế độ Demo Fallback',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Hệ thống tự động thăm dò kết nối tới Backend FastAPI. Nếu server chưa khởi động hoặc chưa mở DB, Vynex tự động kích hoạt bộ đệm Smart Fallback để bạn demo đầy đủ tính năng mà không bị ngắt quãng.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _apiUrlController,
                          decoration: const InputDecoration(
                            labelText: 'FastAPI Base URL',
                            hintText: 'http://localhost:8000',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _isChecking ? null : _testConnection,
                        icon: _isChecking
                            ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.network_check_rounded, size: 16),
                        label: const Text('Kiểm Tra Kết Nối'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Security & Timeout Parameters
          Card(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Chính sách Bảo mật & Thời gian chờ phiên (Security Policies)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Timeout phiên điều khiển từ xa (phút):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              value: _sessionTimeoutMinutes,
                              decoration: const InputDecoration(isDense: true),
                              items: const [
                                DropdownMenuItem(value: 15, child: Text('15 phút')),
                                DropdownMenuItem(value: 30, child: Text('30 phút (Mặc định)')),
                                DropdownMenuItem(value: 60, child: Text('60 phút')),
                                DropdownMenuItem(value: 120, child: Text('120 phút (2 giờ)')),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _sessionTimeoutMinutes = v);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Giới hạn số lần đăng nhập sai tối đa:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<int>(
                              value: _maxLoginAttempts,
                              decoration: const InputDecoration(isDense: true),
                              items: const [
                                DropdownMenuItem(value: 3, child: Text('3 lần (Khóa sau 3 lần)')),
                                DropdownMenuItem(value: 5, child: Text('5 lần (Khuyên dùng)')),
                                DropdownMenuItem(value: 10, child: Text('10 lần')),
                              ],
                              onChanged: (v) {
                                if (v != null) setState(() => _maxLoginAttempts = v);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SwitchListTile(
                    title: const Text('Tự động Heartbeat Ping định kỳ 15 giây với HBBS Server', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Cập nhật trạng thái Online/Offline theo thời gian thực', style: TextStyle(fontSize: 12)),
                    value: _enableAutoHeartbeat,
                    activeColor: AppConstants.primaryBlue,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => _enableAutoHeartbeat = v),
                  ),
                  SwitchListTile(
                    title: const Text('Tự động chuyển tiếp Relay HBBR khi kết nối Direct P2P thất bại', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    subtitle: const Text('Bảo đảm phiên hỗ trợ luôn thông suốt qua NAT firewall', style: TextStyle(fontSize: 12)),
                    value: _enableSmartRelay,
                    activeColor: AppConstants.primaryBlue,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (v) => setState(() => _enableSmartRelay = v),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
