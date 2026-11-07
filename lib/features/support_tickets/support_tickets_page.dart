import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/support_request_model.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../../services/permission_service.dart';
import '../../services/support_ticket_service.dart';
import '../../services/vynex_launcher_service.dart';
import '../../shared/widgets/search_filter_bar.dart';
import '../../shared/widgets/status_badge.dart';

class SupportTicketsPage extends StatefulWidget {
  const SupportTicketsPage({Key? key}) : super(key: key);

  @override
  State<SupportTicketsPage> createState() => _SupportTicketsPageState();
}

class _SupportTicketsPageState extends State<SupportTicketsPage> {
  String _searchQuery = '';
  String _selectedStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupportTicketService>(context, listen: false).fetchTickets();
      Provider.of<PermissionService>(context, listen: false).fetchPermissions();
    });
  }

  void _showCreateTicketDialog(BuildContext context) {
    final mock = MockDataService();
    final auth = Provider.of<AuthService>(context, listen: false);
    final ticketService = Provider.of<SupportTicketService>(context, listen: false);

    final titleController = TextEditingController();
    final descController = TextEditingController();
    int selectedDeviceId = mock.devices.first.deviceId;
    String selectedPriority = 'normal';

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
                  Icon(Icons.add_task_rounded, color: AppConstants.primaryBlue),
                  SizedBox(width: 10),
                  Text('Tạo Yêu Cầu Hỗ Trợ Kỹ Thuật'),
                ],
              ),
              content: SizedBox(
                width: 520,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Chọn thiết bị gặp sự cố:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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

                      const Text('Tiêu đề sự cố:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          hintText: 'Ví dụ: Lỗi không in được hóa đơn thuế...',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 14),

                      const Text('Mức độ ưu tiên:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: selectedPriority,
                        decoration: const InputDecoration(isDense: true),
                        items: const [
                          DropdownMenuItem(value: 'low', child: Text('Thấp (Low)')),
                          DropdownMenuItem(value: 'normal', child: Text('Bình thường (Normal)')),
                          DropdownMenuItem(value: 'high', child: Text('Cao (High)')),
                          DropdownMenuItem(value: 'urgent', child: Text('Khẩn cấp (Urgent)')),
                        ],
                        onChanged: (v) {
                          if (v != null) setDialogState(() => selectedPriority = v);
                        },
                      ),
                      const SizedBox(height: 14),

                      const Text('Mô tả chi tiết lỗi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Mô tả hiện tượng sự cố, mã lỗi hoặc phần mềm bị treo...',
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
                    if (titleController.text.trim().isEmpty) return;
                    final dev = mock.devices.firstWhere((d) => d.deviceId == selectedDeviceId);
                    await ticketService.createTicket(
                      employeeId: auth.currentUser.userId,
                      employeeName: auth.currentUser.fullName,
                      deviceId: dev.deviceId,
                      deviceName: dev.name,
                      vynexId: dev.vynexId,
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      priority: selectedPriority,
                    );
                    if (!mounted) return;
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã gửi yêu cầu hỗ trợ thành công đến bộ phận IT!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Gửi Yêu Cầu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleItConnect(BuildContext context, SupportRequestModel ticket) {
    final auth = Provider.of<AuthService>(context, listen: false);
    final permService = Provider.of<PermissionService>(context, listen: false);

    // Kịch bản 1: Kiểm tra quyền truy cập máy
    final hasPerm = permService.hasPermission(auth.currentUser.userId, ticket.deviceId);

    if (!hasPerm) {
      // IT CHƯA CÓ QUYỀN TRUY CẬP -> BÁO CẢNH BÁO & CHO PHÉP YÊU CẦU ADMIN
      showDialog(
        context: context,
        builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            title: const Row(
              children: [
                Icon(Icons.gpp_bad_rounded, color: Color(0xFFEF4444)),
                SizedBox(width: 10),
                Text('Chưa Có Quyền Truy Cập Thiết Bị'),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bạn (IT ${auth.currentUser.fullName}) chưa được Quản trị viên cấp quyền điều khiển máy "${ticket.deviceName}" hoặc quyền truy cập trước đây đã hết hạn.',
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.security_rounded, color: Color(0xFFDC2626), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Chính sách bảo mật Vynex RBAC yêu cầu phải có Permission cấp bởi Admin trước khi mở phiên điều khiển từ xa.',
                            style: TextStyle(color: Color(0xFF991B1B), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Bạn muốn xử lý như thế nào?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đóng'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await permService.requestPermission(
                    itUserId: auth.currentUser.userId,
                    itName: auth.currentUser.fullName,
                    deviceId: ticket.deviceId,
                    deviceName: ticket.deviceName,
                    vynexId: ticket.vynexId,
                    reason: 'Xử lý sự cố ticket #${ticket.requestId}: ${ticket.title}',
                  );
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã gửi yêu cầu xin cấp quyền điều khiển máy "${ticket.deviceName}" tới Admin.'),
                      backgroundColor: const Color(0xFFF59E0B),
                    ),
                  );
                },
                icon: const Icon(Icons.send_rounded, size: 16),
                label: const Text('Gửi yêu cầu xin Admin cấp quyền'),
              ),
              // Quick button for Demo to grant permission immediately
              ElevatedButton.icon(
                onPressed: () async {
                  await permService.grantPermission(
                    itUserId: auth.currentUser.userId,
                    itName: auth.currentUser.fullName,
                    deviceId: ticket.deviceId,
                    deviceName: ticket.deviceName,
                    vynexId: ticket.vynexId,
                    permissionType: 'control',
                    durationType: '24h',
                    notes: 'Admin duyệt cấp quyền khẩn cấp để xử lý ticket #${ticket.requestId}',
                  );
                  if (!mounted) return;
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Admin đã cấp quyền 24h thành công! Bây giờ IT có thể kết nối.'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                  // Open remote session
                  _openRemoteSession(context, ticket);
                },
                icon: const Icon(Icons.vpn_key_rounded, size: 16),
                label: const Text('[Demo] Cấp Quyền Ngay'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryBlue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      );
    } else {
      // ĐÃ CÓ QUYỀN -> MỞ PHIÊN HỖ TRỢ TRỰC TIẾP
      _openRemoteSession(context, ticket);
    }
  }

  void _openRemoteSession(BuildContext context, SupportRequestModel ticket) async {
    final auth = Provider.of<AuthService>(context, listen: false);
    final permService = Provider.of<PermissionService>(context, listen: false);
    final ticketService = Provider.of<SupportTicketService>(context, listen: false);

    // 1. Sinh Session Token ủy quyền bảo mật
    final sessionToken = permService.generateSessionToken(auth.currentUser.userId, ticket.deviceId);

    // 2. Tự động gọi mở Vynex Client (.exe) kèm tham số CLI: --connect <vynex_id> --token <session_token> --it-user <user_id>
    final launchResult = await VynexLauncherService.launchClient(
      vynexId: ticket.vynexId,
      token: sessionToken,
      itUserId: auth.currentUser.userId,
    );

    // 3. Ghi nhận phiên làm việc vào hệ thống
    await ticketService.startSession(
      ticket: ticket,
      itUserId: auth.currentUser.userId,
      itName: auth.currentUser.fullName,
    );

    if (!mounted) return;

    if (launchResult.success) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(Icons.cast_connected_rounded, color: Color(0xFF10B981), size: 28),
              SizedBox(width: 10),
              Text('Khởi Chạy Phiên Kết Nối Thành Công', style: TextStyle(color: Colors.white, fontSize: 16)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ứng dụng Vynex Client (.exe) đã được kích hoạt và đang tự động bắt tay P2P tới máy "${ticket.deviceName}" (ID: ${ticket.vynexId}).',
                style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Color(0xFF38BDF8), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Token Ủy Quyền: ${sessionToken.substring(0, 24)}...',
                        style: const TextStyle(color: Color(0xFF94A3B8), fontFamily: 'monospace', fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryBlue),
              child: const Text('Đã rõ'),
            ),
          ],
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

  void _showRatingDialog(BuildContext context, SupportRequestModel ticket) {
    int currentRating = 5;
    final feedbackController = TextEditingController();
    final ticketService = Provider.of<SupportTicketService>(context, listen: false);

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setRatingState) {
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              title: const Row(
                children: [
                  Icon(Icons.star_rounded, color: Color(0xFFFBBF24)),
                  SizedBox(width: 8),
                  Text('Đánh Giá Chất Lượng Hỗ Trợ'),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Yêu cầu #${ticket.requestId}: "${ticket.title}" đã hoàn thành bởi IT ${ticket.assignedItName ?? ""}. Vui lòng đánh giá trải nghiệm:',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        return IconButton(
                          icon: Icon(
                            star <= currentRating ? Icons.star_rounded : Icons.star_border_rounded,
                            size: 32,
                            color: const Color(0xFFFBBF24),
                          ),
                          onPressed: () => setRatingState(() => currentRating = star),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: feedbackController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'Nhận xét thêm về thái độ và tốc độ hỗ trợ của kỹ thuật viên...',
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Bỏ qua'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await ticketService.rateTicket(
                      ticket.requestId,
                      currentRating,
                      feedbackController.text.trim(),
                    );
                    if (!mounted) return;
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Cảm ơn bạn đã gửi đánh giá chất lượng phục vụ!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Gửi Đánh Giá'),
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
    final auth = Provider.of<AuthService>(context);
    final ticketService = Provider.of<SupportTicketService>(context);
    final role = auth.activeRole;

    List<SupportRequestModel> list = ticketService.tickets;
    if (_selectedStatusFilter != 'all') {
      list = list.where((t) => t.status == _selectedStatusFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((t) =>
              t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              t.employeeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              t.deviceName.toLowerCase().contains(_searchQuery.toLowerCase()))
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
                    'Quản lý Yêu cầu Hỗ trợ (Support Tickets)',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role == UserRole.employee
                        ? 'Gửi yêu cầu trợ giúp kỹ thuật và theo dõi tiến độ xử lý từ IT'
                        : 'Hàng chờ tiếp nhận và xử lý sự cố thiết bị của nhân viên',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateTicketDialog(context),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Tạo Yêu Cầu Mới'),
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
            hintText: 'Tìm theo tiêu đề, nhân viên hoặc máy...',
            onSearchChanged: (v) => setState(() => _searchQuery = v),
            filterActions: [
              DropdownButton<String>(
                value: _selectedStatusFilter,
                underline: const SizedBox(),
                dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Tất cả trạng thái')),
                  DropdownMenuItem(value: 'pending', child: Text('Chờ xử lý (Pending)')),
                  DropdownMenuItem(value: 'accepted', child: Text('Đã nhận (Accepted)')),
                  DropdownMenuItem(value: 'in_progress', child: Text('Đang kết nối')),
                  DropdownMenuItem(value: 'completed', child: Text('Đã hoàn thành')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _selectedStatusFilter = v);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tickets Table Card
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
                final ticket = list[index];
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Priority Indicator
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: ticket.priority == 'urgent'
                              ? const Color(0xFFFEE2E2)
                              : AppConstants.primaryBlue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          ticket.priority == 'urgent'
                              ? Icons.priority_high_rounded
                              : Icons.support_agent_rounded,
                          size: 20,
                          color: ticket.priority == 'urgent'
                              ? const Color(0xFFEF4444)
                              : AppConstants.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Main Ticket Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '#${ticket.requestId} - ${ticket.title}',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 10),
                                StatusBadge(status: ticket.status),
                                const SizedBox(width: 6),
                                StatusBadge(status: ticket.priority, isSmall: true),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Nhân viên: ${ticket.employeeName} • Thiết bị: ${ticket.deviceName} (ID: ${ticket.vynexId})',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                              ),
                            ),
                            if (ticket.description != null && ticket.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                ticket.description!,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                            if (ticket.rating != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Row(
                                    children: List.generate(
                                      5,
                                      (s) => Icon(
                                        Icons.star_rounded,
                                        size: 14,
                                        color: s < ticket.rating!
                                            ? const Color(0xFFFBBF24)
                                            : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Đánh giá: "${ticket.feedback ?? ""}"',
                                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Color(0xFF10B981)),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Actions depending on Role
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (ticket.status == 'pending') ...[
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    ticketService.acceptTicket(
                                      ticket.requestId,
                                      auth.currentUser.userId,
                                      auth.currentUser.fullName,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Đã nhận xử lý yêu cầu hỗ trợ!')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  ),
                                  child: const Text('Chấp Nhận'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () {
                                    ticketService.rejectTicket(ticket.requestId, 'Không thuộc phạm vi hỗ trợ');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFEF4444),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  ),
                                  child: const Text('Từ Chối'),
                                ),
                              ],
                            ),
                          ] else if (ticket.status == 'accepted' || ticket.status == 'in_progress') ...[
                            Builder(
                              builder: (context) {
                                final permService = Provider.of<PermissionService>(context);
                                final hasPerm = permService.hasPermission(auth.currentUser.userId, ticket.deviceId);
                                final hasRequested = permService.hasRequestedPermission(ticket.deviceId);

                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!hasPerm) ...[
                                      ElevatedButton.icon(
                                        onPressed: () async {
                                          await permService.requestPermission(
                                            itUserId: auth.currentUser.userId,
                                            itName: auth.currentUser.fullName,
                                            deviceId: ticket.deviceId,
                                            deviceName: ticket.deviceName,
                                            vynexId: ticket.vynexId,
                                            reason: 'Xử lý sự cố ticket #${ticket.requestId}: ${ticket.title}',
                                          );
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Đã gửi yêu cầu xin cấp quyền tới Admin!'),
                                              backgroundColor: Color(0xFFF59E0B),
                                            ),
                                          );
                                        },
                                        icon: Icon(hasRequested ? Icons.hourglass_top_rounded : Icons.vpn_key_rounded, size: 16),
                                        label: Text(hasRequested ? 'Đã gửi yêu cầu tới Admin' : 'Yêu cầu cấp quyền kết nối'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: hasRequested ? const Color(0xFFD97706) : const Color(0xFFF59E0B),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    ElevatedButton.icon(
                                      onPressed: () => _handleItConnect(context, ticket),
                                      icon: const Icon(Icons.cast_connected_rounded, size: 16),
                                      label: Text(hasPerm ? 'Kết Nối Ngay' : 'Kết Nối'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: hasPerm ? const Color(0xFF10B981) : AppConstants.primaryBlue,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ] else if (ticket.status == 'completed' && ticket.rating == null && role == UserRole.employee) ...[
                            ElevatedButton.icon(
                              onPressed: () => _showRatingDialog(context, ticket),
                              icon: const Icon(Icons.star_rounded, size: 16),
                              label: const Text('Đánh Giá 1-5 Sao'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFBBF24),
                                foregroundColor: Colors.black87,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              ),
                            ),
                          ],
                        ],
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
