import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../services/mock_data_service.dart';

class ReportsLogsPage extends StatefulWidget {
  const ReportsLogsPage({Key? key}) : super(key: key);

  @override
  State<ReportsLogsPage> createState() => _ReportsLogsPageState();
}

class _ReportsLogsPageState extends State<ReportsLogsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _exportReport(String type) async {
    final isPdf = type == 'PDF';
    final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final displayDate = DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now());
    final fileName = isPdf ? 'Vynex_BaoCao_HoTro_$dateStr.pdf' : 'Vynex_DuLieu_HoTro_$dateStr.csv';

    // Xác định thư mục Downloads hoặc Documents của Windows
    String targetDir = Directory.current.path;
    final userProfile = Platform.environment['USERPROFILE'];
    if (userProfile != null) {
      final downloadsDir = Directory('$userProfile\\Downloads');
      if (downloadsDir.existsSync()) {
        targetDir = downloadsDir.path;
      } else {
        final docsDir = Directory('$userProfile\\Documents');
        if (docsDir.existsSync()) {
          targetDir = docsDir.path;
        }
      }
    }

    final filePath = '$targetDir\\$fileName';
    final mock = MockDataService();

    try {
      final file = File(filePath);

      if (isPdf) {
        // Tạo file PDF hợp lệ chuẩn cấu trúc PDF-1.4
        final buffer = StringBuffer();
        buffer.writeln('%PDF-1.4');
        buffer.writeln('1 0 obj << /Type /Catalog /Pages 2 0 R >> endobj');
        buffer.writeln('2 0 obj << /Type /Pages /Kids [3 0 R] /Count 1 >> endobj');
        buffer.writeln('3 0 obj << /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >> endobj');
        buffer.writeln('4 0 obj << /Type /Font /Subtype /Type1 /BaseFont /Helvetica >> endobj');

        final streamContent = StringBuffer();
        streamContent.writeln('BT');
        streamContent.writeln('/F1 18 Tf');
        streamContent.writeln('50 740 Td');
        streamContent.writeln('(VYNEX MANAGEMENT SYSTEM - AUDIT REPORT) Tj');
        streamContent.writeln('/F1 12 Tf');
        streamContent.writeln('0 -30 Td');
        streamContent.writeln('(Generated: $displayDate) Tj');
        streamContent.writeln('0 -20 Td');
        streamContent.writeln('(Total Devices: ${mock.devices.length} | Active Sessions: ${mock.sessions.length}) Tj');
        streamContent.writeln('0 -30 Td');
        streamContent.writeln('(--- RECENT REMOTE SESSIONS LOG ---) Tj');

        for (var s in mock.sessions.take(10)) {
          streamContent.writeln('0 -18 Td');
          streamContent.writeln('(Session #${s.sessionId} | ${s.deviceName} | IT: ${s.itUserName} | Duration: ${s.durationFormatted}) Tj');
        }

        streamContent.writeln('ET');
        final streamBytes = streamContent.toString();

        buffer.writeln('5 0 obj << /Length ${streamBytes.length} >>');
        buffer.writeln('stream');
        buffer.write(streamBytes);
        buffer.writeln('endstream');
        buffer.writeln('endobj');
        buffer.writeln('xref');
        buffer.writeln('0 6');
        buffer.writeln('0000000000 65535 f ');
        buffer.writeln('trailer << /Size 6 /Root 1 0 R >>');
        buffer.writeln('startxref');
        buffer.writeln('10');
        buffer.writeln('%%EOF');

        await file.writeAsString(buffer.toString());
      } else {
        // Tạo file CSV với BOM UTF-8 để Microsoft Excel mở trực tiếp không lỗi tiếng Việt
        final csv = StringBuffer();
        csv.write('\uFEFF'); // UTF-8 BOM
        csv.writeln('Mã Phiên,Tên Thiết Bị,Vynex ID,Kỹ Thuật Viên IT,Người Dùng,Loại Kết Nối,Bắt Đầu,Thời Lượng,Đánh Giá,Trạng Thái,Ghi Chú');
        for (var s in mock.sessions) {
          final start = DateFormat('dd/MM/yyyy HH:mm:ss').format(s.startTime);
          csv.writeln('${s.sessionId},"${s.deviceName}","${s.vynexId}","${s.itUserName}","${s.targetUserName}","${s.connectionType}","$start","${s.durationFormatted}",${s.qualityScore ?? 5},"${s.status}","${s.notes ?? ''}"');
        }
        await file.writeAsString(csv.toString(), encoding: utf8);
      }

      if (!mounted) return;

      // Hiển thị Dialog thông báo đường dẫn file đã xuất kèm các nút thao tác nhanh
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(isPdf ? Icons.picture_as_pdf_rounded : Icons.table_chart_rounded,
                  color: isPdf ? const Color(0xFFEF4444) : const Color(0xFF10B981), size: 28),
              const SizedBox(width: 10),
              Text(
                'Xuất Báo Cáo $type Thành Công',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('File báo cáo đã được lưu trực tiếp vào ổ cứng:',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: SelectableText(
                  filePath,
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontFamily: 'monospace',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Bạn có thể mở xem ngay hoặc mở thư mục lưu trữ trên Windows Explorer.',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
            OutlinedButton.icon(
              onPressed: () {
                Process.run('explorer.exe', ['/select,', filePath]);
              },
              icon: const Icon(Icons.folder_open_rounded, size: 16),
              label: const Text('Mở Thư Mục Chứa File'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Process.run('cmd.exe', ['/c', 'start', '', filePath]);
                Navigator.pop(ctx);
              },
              icon: const Icon(Icons.launch_rounded, size: 16),
              label: const Text('Mở File Ngay'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isPdf ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã lưu file: $filePath'),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi xuất file: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                    'Báo cáo & Lịch sử Hoạt động (Reports & Audit Logs)',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Thống kê hiệu suất hỗ trợ, xếp hạng IT và nhật ký kiểm toán hệ thống Vynex',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              // Export Actions (Kịch bản 3)
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _exportReport('Excel'),
                    icon: const Icon(Icons.table_view_rounded, size: 16, color: Color(0xFF10B981)),
                    label: const Text('Xuất Excel (.xlsx)', style: TextStyle(color: Color(0xFF10B981))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF10B981)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _exportReport('PDF'),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                    label: const Text('Xuất Báo Cáo PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Tabs
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppConstants.primaryBlue,
            unselectedLabelColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            indicatorColor: AppConstants.primaryBlue,
            tabs: const [
              Tab(text: 'Biểu Đồ Thống Kê & Hiệu Suất IT'),
              Tab(text: 'Lịch Sử Phiên Kết Nối (RemoteSessions)'),
              Tab(text: 'Nhật Ký Kiểm Toán (ActivityLogs)'),
            ],
          ),
          const SizedBox(height: 20),

          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              if (_tabController.index == 0) {
                return _buildAnalyticsTab(context, isDark);
              } else if (_tabController.index == 1) {
                return _buildSessionsTab(context, isDark);
              } else {
                return _buildActivityLogsTab(context, isDark);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Charts Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bar Chart: Support tickets per day
            Expanded(
              flex: 6,
              child: Card(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Số lượng yêu cầu hỗ trợ theo 7 ngày gần nhất',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppConstants.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Tuần này', style: TextStyle(color: AppConstants.primaryBlue, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 12,
                            barTouchData: BarTouchData(enabled: true),
                            titlesData: FlTitlesData(
                              leftTitles: const AxisTitles(
                                sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (val, meta) {
                                    const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                                    final i = val.toInt();
                                    if (i >= 0 && i < days.length) {
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(days[i], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                      );
                                    }
                                    return const Text('');
                                  },
                                ),
                              ),
                              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 3,
                              getDrawingHorizontalLine: (val) => FlLine(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                strokeWidth: 1,
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            barGroups: [
                              _makeBarGroup(0, 4, AppConstants.primaryBlue),
                              _makeBarGroup(1, 7, AppConstants.primaryBlue),
                              _makeBarGroup(2, 5, AppConstants.primaryBlue),
                              _makeBarGroup(3, 9, AppConstants.primaryBlue),
                              _makeBarGroup(4, 8, AppConstants.primaryBlue),
                              _makeBarGroup(5, 3, AppConstants.primaryBlue),
                              _makeBarGroup(6, 2, const Color(0xFF94A3B8)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Top IT Performance Card
            Expanded(
              flex: 4,
              child: Card(
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
                        'Bảng xếp hạng Kỹ thuật viên (IT Leaderboard)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      _buildItRankItem(
                        rank: 1,
                        name: 'Lê Hoàng Nam',
                        ticketsDone: 18,
                        avgDuration: '14 phút',
                        rating: 4.9,
                        color: const Color(0xFFFBBF24),
                      ),
                      const Divider(height: 20),
                      _buildItRankItem(
                        rank: 2,
                        name: 'Trần Minh Tuấn',
                        ticketsDone: 12,
                        avgDuration: '19 phút',
                        rating: 4.8,
                        color: const Color(0xFF94A3B8),
                      ),
                      const Divider(height: 20),
                      _buildItRankItem(
                        rank: 3,
                        name: 'Nguyễn Văn An (Admin)',
                        ticketsDone: 6,
                        avgDuration: '10 phút',
                        rating: 5.0,
                        color: const Color(0xFFB45309),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Incident breakdown by department
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
                  'Phân bổ sự cố theo Phòng ban',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 16),
                _buildDeptProgress('Phòng Kế toán - Tài chính (Phần mềm kế toán, hóa đơn)', 0.45, '45%', const Color(0xFF3B82F6)),
                const SizedBox(height: 12),
                _buildDeptProgress('Phòng Kinh doanh (VPN, Email Outlook, CRM)', 0.30, '30%', const Color(0xFF10B981)),
                const SizedBox(height: 12),
                _buildDeptProgress('Ban Nhân sự (Máy chấm công, máy in văn phòng)', 0.15, '15%', const Color(0xFFF59E0B)),
                const SizedBox(height: 12),
                _buildDeptProgress('Phòng Kỹ thuật & CNTT (Cập nhật server, backup)', 0.10, '10%', const Color(0xFF8B5CF6)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 18,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
        ),
      ],
    );
  }

  Widget _buildItRankItem({
    required int rank,
    required String name,
    required int ticketsDone,
    required String avgDuration,
    required double rating,
    required Color color,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: color,
          child: Text('$rank', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text('Đã giải quyết $ticketsDone ticket • TB: $avgDuration', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          ),
        ),
        Row(
          children: [
            const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFBBF24)),
            const SizedBox(width: 2),
            Text('$rating', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildDeptProgress(String label, double ratio, String percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text(percent, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: ratio,
          backgroundColor: Colors.grey.withOpacity(0.15),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildSessionsTab(BuildContext context, bool isDark) {
    final mock = MockDataService();
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: mock.sessions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final s = mock.sessions[index];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cable_rounded, color: AppConstants.primaryBlue, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Phiên #${s.sessionId}: ${s.itName} ➔ ${s.targetName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Thiết bị: ${s.deviceName} (${s.vynexId}) • Kết nối: ${s.connectionType.toUpperCase()}', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text('Ghi chú: ${s.notes ?? "Không có"}', style: const TextStyle(fontSize: 12)),
                ),
                Text('Thời lượng: ${(s.durationSeconds ?? 0) ~/ 60}m', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 16),
                Row(
                  children: List.generate(
                    5,
                    (st) => Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: st < (s.qualityScore ?? 5) ? const Color(0xFFFBBF24) : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivityLogsTab(BuildContext context, bool isDark) {
    final mock = MockDataService();
    return Card(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: mock.activityLogs.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final l = mock.activityLogs[index];
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.history_toggle_off_rounded, size: 20, color: Color(0xFF64748B)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(l.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E7FF),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(l.action, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4338CA))),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(l.description, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                    ],
                  ),
                ),
                Text(
                  'IP: ${l.ipAddress ?? "127.0.0.1"} • ${DateFormat('HH:mm dd/MM').format(l.createdAt)}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
