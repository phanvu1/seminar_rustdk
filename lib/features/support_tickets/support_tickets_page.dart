import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/support_request_model.dart';
import '../../models/user_model.dart';
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
      Provider.of<SupportTicketService>(context, listen: false).startPolling();
      Provider.of<PermissionService>(context, listen: false).startPolling();
    });
  }

  void _showCreateTicketDialog(BuildContext context) {
    final mock = MockDataService();
    final auth = Provider.of<AuthService>(context, listen: false);
    final ticketService = Provider.of<SupportTicketService>(context, listen: false);
    final permService = Provider.of<PermissionService>(context, listen: false);

    final titleController = TextEditingController();
    final descController = TextEditingController();
    final passwordController = TextEditingController();
    int selectedDeviceId = mock.devices.first.deviceId;
    String selectedPriority = 'normal';
    bool selfAssign = auth.currentUser.role == UserRole.it; // Mặc định nếu IT tạo thì tự nhận xử lý

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final currentSelectedDev = mock.devices.firstWhere(
              (d) => d.deviceId == selectedDeviceId,
              orElse: () => mock.devices.first,
            );

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
                      const Text('Chọn thiết bị cần hỗ trợ (Nhân viên hoặc IT đồng nghiệp):',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<int>(
                        value: selectedDeviceId,
                        isExpanded: true,
                        decoration: const InputDecoration(isDense: true),
                        items: mock.devices.map((d) {
                          return DropdownMenuItem<int>(
                            value: d.deviceId,
                            child: Text('${d.name} [${d.userName ?? "Chưa gán"}] (${d.vynexId})'),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) setDialogState(() => selectedDeviceId = v);
                        },
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Chủ sở hữu thiết bị: ${currentSelectedDev.userName ?? "Không xác định"} • Phòng ban: ${currentSelectedDev.departmentName ?? "Chưa rõ"}',
                        style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 14),

                      const Row(
                        children: [
                          Text('Mật khẩu kết nối máy tính (Bắt buộc):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          SizedBox(width: 4),
                          Text('*', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          hintText: 'Nhập mật khẩu RustDesk trên máy cần hỗ trợ...',
                          prefixIcon: Icon(Icons.vpn_key_rounded, size: 18, color: Color(0xFFE11D48)),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (auth.currentUser.role == UserRole.it) ...[
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: const Text('Tôi trực tiếp tiếp nhận & xin Admin cấp quyền xử lý máy này',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                          value: selfAssign,
                          activeColor: AppConstants.primaryBlue,
                          onChanged: (v) => setDialogState(() => selfAssign = v ?? true),
                        ),
                        const SizedBox(height: 10),
                      ],

                      const Text('Tiêu đề sự cố (*):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          hintText: 'Ví dụ: Cài đặt phần mềm, khắc phục lỗi hệ điều hành...',
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

                      const Text('Mô tả chi tiết:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: descController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Mô tả hiện tượng sự cố, nhu cầu cần can thiệp từ xa...',
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
                    if (titleController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Vui lòng nhập tiêu đề sự cố!'), backgroundColor: Color(0xFFEF4444)),
                      );
                      return;
                    }
                    if (passwordController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bắt buộc: Vui lòng nhập mật khẩu Vynex Client của máy!'), backgroundColor: Color(0xFFEF4444)),
                      );
                      return;
                    }

                    final dev = mock.devices.firstWhere((d) => d.deviceId == selectedDeviceId);
                    final isSelf = selfAssign && auth.currentUser.role == UserRole.it;

                    await ticketService.createTicket(
                      employeeId: dev.userId ?? auth.currentUser.userId,
                      employeeName: dev.userName ?? auth.currentUser.fullName,
                      deviceId: dev.deviceId,
                      deviceName: dev.name,
                      vynexId: dev.vynexId,
                      clientPassword: passwordController.text.trim(),
                      title: titleController.text.trim(),
                      description: descController.text.trim(),
                      priority: selectedPriority,
                      assignedItId: isSelf ? auth.currentUser.userId : null,
                      assignedItName: isSelf ? auth.currentUser.fullName : null,
                    );

                    if (isSelf) {
                      final latestTicket = ticketService.tickets.isNotEmpty ? ticketService.tickets.first : null;
                      if (latestTicket != null) {
                        await permService.requestPermission(
                          itUserId: auth.currentUser.userId,
                          itName: auth.currentUser.fullName,
                          deviceId: dev.deviceId,
                          deviceName: dev.name,
                          vynexId: dev.vynexId,
                          requestId: latestTicket.requestId,
                          reason: 'IT tự tạo yêu cầu và xin quyền xử lý máy "${dev.name}"',
                        );
                      }
                    }

                    if (!mounted) return;
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isSelf
                            ? 'Đã tạo yêu cầu và gửi thông báo xin cấp quyền tới Admin!'
                            : 'Đã gửi yêu cầu hỗ trợ thành công đến hệ thống!'),
                        backgroundColor: const Color(0xFF10B981),
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

    // BẢO VỆ TỐI CAO MÁY ADMIN (UNIDIRECTIONAL GUARD):
    // Tuyệt đối không một kỹ thuật viên nào được phép kết nối điều khiển máy của Admin
    final mock = MockDataService();
    final targetDev = mock.devices.where((d) => d.deviceId == ticket.deviceId).toList();
    final isTargetAdmin = ticket.employeeId == 1 || (targetDev.isNotEmpty && targetDev.first.userId == 1);

    if (isTargetAdmin && auth.currentUser.userId != 1) {
      showDialog(
        context: context,
        builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Row(
              children: [
                Icon(Icons.shield_rounded, color: Color(0xFFEF4444)),
                SizedBox(width: 10),
                Text('Bảo Vệ Tối Cao Quản Trị Viên (Admin Shield)'),
              ],
            ),
            content: const Text(
              'Thiết bị này thuộc quyền sở hữu của Quản Trị Viên Tối Cao (Admin).\n\n'
              'Theo chính sách bảo mật Zero-Trust doanh nghiệp của Vynex Enterprise:\n'
              '• Kỹ thuật viên (IT Staff) và nhân viên tuyệt đối không thể kết nối điều khiển máy của Admin dưới bất kỳ hình thức nào, kể cả khi có yêu cầu hỗ trợ.',
              style: TextStyle(height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Đã hiểu'),
              ),
            ],
          );
        },
      );
      return;
    }

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

    // 2. Tự động gọi mở Vynex Client (.exe) kèm tham số CLI: --connect <vynex_id> --password <pass> --token <session_token> --it-user <user_id>
    final launchResult = await VynexLauncherService.launchClient(
      vynexId: ticket.vynexId,
      token: sessionToken,
      itUserId: auth.currentUser.userId,
      password: ticket.clientPassword,
    );

    // 3. Ghi nhận phiên làm việc vào hệ thống
    await ticketService.startSession(
      ticket: ticket,
      itUserId: auth.currentUser.userId,
      itName: auth.currentUser.fullName,
    );

    if (!mounted) return;

    if (launchResult.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.cast_connected_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Đang khởi động Vynex Client kết nối tới "${ticket.deviceName}" (${ticket.vynexId})...'),
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

    List<SupportRequestModel> list = ticketService.tickets.where((t) {
      if (role == UserRole.employee) {
        return t.employeeId == auth.currentUser.userId;
      }
      if (role == UserRole.it) {
        // IT chỉ thấy ticket chưa ai nhận (pending) HOẶC ticket đã được giao/nhận bởi chính IT này
        return t.status == 'pending' || t.assignedItId == auth.currentUser.userId;
      }
      // Admin thấy toàn bộ ticket
      return true;
    }).toList();
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
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Provider.of<SupportTicketService>(context, listen: false).fetchTickets();
                      await Provider.of<PermissionService>(context, listen: false).fetchPermissions();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã cập nhật danh sách yêu cầu mới nhất!'), duration: Duration(seconds: 1)),
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Làm Mới'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Priority Icon + ID & Title + Badges + Spacer + Created At
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  '#${ticket.requestId} - ${ticket.title}',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                StatusBadge(status: ticket.status),
                                StatusBadge(status: ticket.priority, isSmall: true),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('dd/MM/yyyy HH:mm').format(ticket.createdAt),
                            style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Info Row: Employee, Device, Client Password chip
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 6,
                        children: [
                          Text(
                            'Nhân viên: ${ticket.employeeName} • Thiết bị: ${ticket.deviceName} (ID: ${ticket.vynexId})',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                            ),
                          ),
                          if (ticket.clientPassword != null && ticket.clientPassword!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.key_rounded, size: 13, color: Color(0xFF10B981)),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Pass: ${ticket.clientPassword}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),

                      // Description
                      if (ticket.description != null && ticket.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          ticket.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],

                      // Rating & Feedback
                      if (ticket.rating != null) ...[
                        const SizedBox(height: 8),
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

                      // Bottom Action Bar: Divider + Wrap (guarantees NO collision or overlap EVER)
                      const SizedBox(height: 12),
                      const Divider(height: 1, color: Color(0x1F94A3B8)),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (ticket.status == 'pending') ...[
                              if (auth.currentUser.role == UserRole.admin) ...[
                                PopupMenuButton<UserModel>(
                                  tooltip: 'Chỉ định kỹ thuật viên IT tiếp nhận xử lý',
                                  onSelected: (itStaff) {
                                    ticketService.acceptTicket(
                                      ticket.requestId,
                                      itStaff.userId,
                                      itStaff.fullName,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Admin đã chỉ định ${itStaff.fullName} xử lý ticket #${ticket.requestId}!'),
                                        backgroundColor: AppConstants.primaryBlue,
                                      ),
                                    );
                                  },
                                  itemBuilder: (ctx) {
                                    final itUsers = MockDataService().users.where((u) => u.role == UserRole.it).toList();
                                    return itUsers.map((itStaff) => PopupMenuItem(
                                      value: itStaff,
                                      child: Text('Chỉ định: ${itStaff.fullName}'),
                                    )).toList();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppConstants.primaryBlue,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.assignment_ind_rounded, size: 16, color: Colors.white),
                                        SizedBox(width: 6),
                                        Text('Chỉ Định IT Xử Lý', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    ticketService.acceptTicket(
                                      ticket.requestId,
                                      auth.currentUser.userId,
                                      auth.currentUser.fullName,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Admin tiếp nhận tự xử lý sự cố #${ticket.requestId}!')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  ),
                                  child: const Text('Admin Tự Xử Lý'),
                                ),
                              ] else ...[
                                ElevatedButton(
                                  onPressed: () {
                                    ticketService.acceptTicket(
                                      ticket.requestId,
                                      auth.currentUser.userId,
                                      auth.currentUser.fullName,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Đã nhận xử lý yêu cầu hỗ trợ #${ticket.requestId}!')),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  ),
                                  child: const Text('Tiếp Nhận Xử Lý'),
                                ),
                              ],
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
                            ] else if (ticket.status == 'accepted' || ticket.status == 'in_progress') ...[
                              Builder(
                                builder: (context) {
                                  final permService = Provider.of<PermissionService>(context);
                                  final isAdmin = auth.currentUser.role == UserRole.admin || auth.activeRole == UserRole.admin;
                                  final isAssignedToOther = !isAdmin && ticket.assignedItId != null && ticket.assignedItId != auth.currentUser.userId;
                                  final isAssignedToMe = ticket.assignedItId == auth.currentUser.userId;
                                  final hasPerm = isAdmin || permService.hasPermission(auth.currentUser.userId, ticket.deviceId);
                                  final hasRequested = permService.hasRequestedTicket(ticket.requestId);

                                  return Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    alignment: WrapAlignment.end,
                                    children: [
                                      // 1. Nếu đã được một IT khác tiếp nhận
                                      if (isAssignedToOther)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.person_pin_circle_rounded, size: 16, color: Color(0xFF64748B)),
                                              const SizedBox(width: 6),
                                              Text(
                                                'Đã được tiếp nhận bởi: ${ticket.assignedItName ?? "IT khác"}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                      // 2. Nếu là IT được giao hoặc là Admin
                                      if (isAdmin || isAssignedToMe) ...[
                                        if (!hasPerm && !isAdmin)
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              await permService.requestPermission(
                                                itUserId: auth.currentUser.userId,
                                                itName: auth.currentUser.fullName,
                                                deviceId: ticket.deviceId,
                                                deviceName: ticket.deviceName,
                                                vynexId: ticket.vynexId,
                                                requestId: ticket.requestId,
                                                reason: 'Xử lý sự cố ticket #${ticket.requestId}: ${ticket.title}',
                                              );
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Đã gửi yêu cầu cấp quyền cho Ticket #${ticket.requestId} tới Admin!'),
                                                  backgroundColor: const Color(0xFFF59E0B),
                                                ),
                                              );
                                            },
                                            icon: Icon(hasRequested ? Icons.hourglass_top_rounded : Icons.vpn_key_rounded, size: 16),
                                            label: Text(hasRequested ? 'Đã Gửi Yêu Cầu Admin' : 'Yêu Cầu Cấp Quyền'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: hasRequested ? const Color(0xFFD97706) : const Color(0xFFF59E0B),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                            ),
                                          ),
                                        if (isAdmin) ...[
                                          if (ticket.assignedItId != null && !permService.hasPermission(ticket.assignedItId!, ticket.deviceId))
                                            ElevatedButton.icon(
                                              onPressed: () async {
                                                await permService.grantPermission(
                                                  itUserId: ticket.assignedItId!,
                                                  itName: ticket.assignedItName ?? 'Kỹ thuật viên',
                                                  deviceId: ticket.deviceId,
                                                  deviceName: ticket.deviceName,
                                                  vynexId: ticket.vynexId,
                                                  permissionType: 'control',
                                                  durationType: '24h',
                                                  notes: 'Admin duyệt cấp quyền cho ${ticket.assignedItName} (Ticket #${ticket.requestId})',
                                                );
                                                if (!context.mounted) return;
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Admin đã duyệt cấp quyền 24h cho ${ticket.assignedItName}!'),
                                                    backgroundColor: const Color(0xFF10B981),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.verified_user_rounded, size: 16),
                                              label: Text('Duyệt Quyền (${ticket.assignedItName ?? "IT"})'),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF6366F1),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              ),
                                            ),
                                        ],
                                        ElevatedButton.icon(
                                          onPressed: () => _handleItConnect(context, ticket),
                                          icon: const Icon(Icons.cast_connected_rounded, size: 16),
                                          label: Text(isAdmin ? 'Admin Kết Nối Ngay' : (hasPerm ? 'Kết Nối Ngay' : 'Kết Nối')),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: hasPerm ? const Color(0xFF10B981) : AppConstants.primaryBlue,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          ),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Row(
                                                  children: [
                                                    Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
                                                    SizedBox(width: 8),
                                                    Text('Xác nhận hoàn thành'),
                                                  ],
                                                ),
                                                content: Text('Bạn có chắc chắn đã xử lý xong sự cố "${ticket.title}" cho ${ticket.employeeName}?'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Hủy')),
                                                  ElevatedButton(
                                                    onPressed: () => Navigator.pop(ctx, true),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF10B981),
                                                      foregroundColor: Colors.white,
                                                    ),
                                                    child: const Text('Hoàn Thành'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              await ticketService.completeTicket(ticket.requestId);
                                              if (!context.mounted) return;
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Đã hoàn tất Ticket #${ticket.requestId}! Admin và Nhân viên đã được cập nhật.'),
                                                  backgroundColor: const Color(0xFF10B981),
                                                ),
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                                          label: const Text('Hoàn Thành Xử Lý'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF059669),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ] else if (ticket.status == 'completed') ...[
                              Builder(
                                builder: (context) {
                                  final permService = Provider.of<PermissionService>(context);
                                  final isAdmin = auth.currentUser.role == UserRole.admin || auth.activeRole == UserRole.admin;
                                  final activePerm = ticket.assignedItId != null
                                      ? permService.getActivePermissionFor(ticket.assignedItId!, ticket.deviceId)
                                      : null;

                                  return Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    alignment: WrapAlignment.end,
                                    children: [
                                      if (role == UserRole.employee && ticket.rating == null)
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
                                      if (isAdmin && activePerm != null)
                                        ElevatedButton.icon(
                                          onPressed: () async {
                                            await permService.revokePermission(activePerm.permissionId);
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Admin đã thu hồi quyền điều khiển của ${ticket.assignedItName} đối với máy ${ticket.deviceName}!'),
                                                backgroundColor: const Color(0xFFEF4444),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.lock_reset_rounded, size: 16),
                                          label: Text('Thu Hồi Quyền (${ticket.assignedItName ?? "IT"})'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFFDC2626),
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          ),
                                        ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.check_circle_rounded, size: 16, color: Colors.green),
                                            SizedBox(width: 6),
                                            Text('Đã Hoàn Thành',
                                                style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ] else if (ticket.status == 'rejected') ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.cancel_rounded, size: 16, color: Colors.red),
                                    SizedBox(width: 6),
                                    Text('Đã Từ Chối',
                                        style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
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
