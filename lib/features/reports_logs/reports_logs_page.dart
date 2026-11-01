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

  void _exportReport(String type) {
    final fileName = type == 'PDF' ? 'Vynex_BaoCao_HoTro_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf' : 'Vynex_DuLieu_HoTro_${DateFormat('yyyyMMdd').format(DateTime.now())}.xlsx';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(type == 'PDF' ? Icons.picture_as_pdf_rounded : Icons.table_chart_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Đã xuất báo cáo $type thành công: $fileName'),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 4),
      ),
    );
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
