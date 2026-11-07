import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../services/support_ticket_service.dart';

class RemoteSessionDialog extends StatefulWidget {
  final int deviceId;
  final String deviceName;
  final String vynexId;
  final String targetUserName;
  final String connectionType;
  final int? supportRequestId;

  const RemoteSessionDialog({
    Key? key,
    required this.deviceId,
    required this.deviceName,
    required this.vynexId,
    required this.targetUserName,
    this.connectionType = 'direct',
    this.supportRequestId,
  }) : super(key: key);

  @override
  State<RemoteSessionDialog> createState() => _RemoteSessionDialogState();
}

class _RemoteSessionDialogState extends State<RemoteSessionDialog> {
  int _seconds = 0;
  Timer? _timer;
  final _notesController = TextEditingController();
  int _qualityScore = 5;
  bool _isEnding = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDuration(int totalSecs) {
    final m = (totalSecs ~/ 60).toString().padLeft(2, '0');
    final s = (totalSecs % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _handleFinishSession() async {
    setState(() => _isEnding = true);
    if (widget.supportRequestId != null) {
      final ticketService = Provider.of<SupportTicketService>(context, listen: false);
      await ticketService.completeSession(
        requestId: widget.supportRequestId!,
        sessionId: 500 + DateTime.now().second,
        sessionNotes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : 'Hoàn thành hỗ trợ kỹ thuật máy ${widget.deviceName}',
        qualityScore: _qualityScore,
      );
    }
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã hoàn thành phiên hỗ trợ máy ${widget.deviceName} (${_formatDuration(_seconds)})'),
        backgroundColor: const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        width: 1080,
        height: 720,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A), // Dark studio canvas
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: const Color(0xFF334155), width: 1.5),
        ),
        child: Column(
          children: [
            // Top Session Toolbar
            Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                border: Border(bottom: BorderSide(color: Color(0xFF334155))),
              ),
              child: Row(
                children: [
                  // Status Dot
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Vynex Remote: ${widget.deviceName} (${widget.vynexId})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.connectionType.toUpperCase(),
                      style: const TextStyle(color: AppConstants.secondaryBlue, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),

                  // Metrics Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.speed_rounded, color: Color(0xFF10B981), size: 14),
                        const SizedBox(width: 6),
                        const Text('60 FPS • 14ms • 4.2 Mbps', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                        const SizedBox(width: 12),
                        const Icon(Icons.timer_outlined, color: AppConstants.primaryBlue, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          _formatDuration(_seconds),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // End Session Button
                  ElevatedButton.icon(
                    onPressed: _isEnding ? null : _handleFinishSession,
                    icon: const Icon(Icons.stop_circle_rounded, size: 16),
                    label: const Text('Kết Thúc Phiên'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEF4444),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Remote Screen Content Simulation
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Simulated Remote Desktop Background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.desktop_windows_rounded, size: 64, color: Colors.white.withOpacity(0.2)),
                          const SizedBox(height: 12),
                          Text(
                            'Màn hình làm việc máy ${widget.deviceName}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.85),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Người dùng mục tiêu: ${widget.targetUserName} • Đang kết nối trực tiếp qua HBBS Relay',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Simulated active app window
                          Container(
                            width: 580,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B).withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF334155)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.terminal_rounded, color: Color(0xFF10B981), size: 18),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Vynex IT Diagnostics Tool',
                                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('RUNNING', style: TextStyle(color: Color(0xFF10B981), fontSize: 10)),
                                    ),
                                  ],
                                ),
                                const Divider(color: Color(0xFF334155)),
                                const Text(
                                  r'PS C:\Users\Employee> vynex-diag --check-network' '\n'
                                  '[OK] Gateway 192.168.1.1 reachable (1ms)\n'
                                  '[OK] DNS 192.168.1.200 resolved internal hosts\n'
                                  '[OK] Port 21116 / 21117 HBBS/HBBR Connected\n'
                                  '[INFO] Print Spooler service status: OK (Restarted)',
                                  style: TextStyle(
                                    color: Color(0xFFCBD5E1),
                                    fontFamily: 'Consolas',
                                    fontFamilyFallback: ['Courier New', 'monospace', 'Segoe UI'],
                                    fontSize: 11,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Dock / Windows Taskbar Simulation
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      color: const Color(0xFF0F172A).withOpacity(0.92),
                      child: Row(
                        children: [
                          const Icon(Icons.window_rounded, color: AppConstants.primaryBlue, size: 22),
                          const SizedBox(width: 16),
                          const Icon(Icons.folder_rounded, color: Color(0xFFFBBF24), size: 20),
                          const SizedBox(width: 16),
                          const Icon(Icons.language_rounded, color: Color(0xFF38BDF8), size: 20),
                          const SizedBox(width: 16),
                          const Icon(Icons.terminal_rounded, color: Colors.white70, size: 20),
                          const Spacer(),
                          Text(
                            'ENG  ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Session Notes & Rating Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFF1E293B),
              child: Row(
                children: [
                  const Icon(Icons.notes_rounded, color: Color(0xFF94A3B8), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _notesController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'Nhập ghi chú kỹ thuật cho phiên hỗ trợ này (ví dụ: đã sửa lỗi in ấn, cập nhật driver)...',
                        hintStyle: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
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
}
