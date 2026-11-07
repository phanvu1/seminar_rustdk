import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants.dart';
import '../../models/support_request_model.dart';
import '../../models/device_model.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../../services/support_ticket_service.dart';
import '../../shared/widgets/status_badge.dart';

class EmployeeSupportPage extends StatefulWidget {
  final String viewMode; // 'create' or 'history'
  final ValueChanged<String> onSwitchView;

  const EmployeeSupportPage({
    Key? key,
    required this.viewMode,
    required this.onSwitchView,
  }) : super(key: key);

  @override
  State<EmployeeSupportPage> createState() => _EmployeeSupportPageState();
}

class _EmployeeSupportPageState extends State<EmployeeSupportPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int? _selectedDeviceId;
  String _selectedPriority = 'normal';
  bool _isSubmitting = false;
  String _historyFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SupportTicketService>(context, listen: false).fetchTickets();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  /// Gửi form tạo yêu cầu hỗ trợ (Khắc phục triệt để Lỗi 2.5)
  Future<void> _handleSubmitRequest() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tiêu đề sự cố cần hỗ trợ!'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    final auth = Provider.of<AuthService>(context, listen: false);
    final ticketService = Provider.of<SupportTicketService>(context, listen: false);
    final mock = MockDataService();

    // 1. Xác định thiết bị của nhân viên
    DeviceModel? targetDevice;
    if (_selectedDeviceId != null) {
      targetDevice = mock.devices.firstWhere(
        (d) => d.deviceId == _selectedDeviceId,
        orElse: () => mock.devices.first,
      );
    } else {
      // Tìm thiết bị gán cho nhân viên hoặc phòng ban nhân viên
      final userDev = mock.devices.where((d) => d.userId == auth.currentUser.userId).toList();
      targetDevice = userDev.isNotEmpty ? userDev.first : mock.devices.first;
    }

    setState(() => _isSubmitting = true);

    try {
      // 2. Gán đúng employee_id của user đang đăng nhập và device_id tương ứng
      await ticketService.createTicket(
        employeeId: auth.currentUser.userId,
        employeeName: auth.currentUser.fullName,
        deviceId: targetDevice.deviceId,
        deviceName: targetDevice.name,
        vynexId: targetDevice.vynexId,
        title: title,
        description: _descController.text.trim(),
        priority: _selectedPriority,
      );

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      // 3. Reset form
      _titleController.clear();
      _descController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã gửi yêu cầu hỗ trợ thành công tới bộ phận IT!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );

      // 4. Tự động chuyển ngay sang tab "Lịch sử yêu cầu của tôi"
      widget.onSwitchView('employee_my_tickets');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi gửi yêu cầu: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  /// Hủy yêu cầu khi đang ở trạng thái pending
  Future<void> _handleCancelRequest(SupportRequestModel ticket) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận hủy yêu cầu'),
        content: Text('Bạn có chắc chắn muốn hủy yêu cầu hỗ trợ #${ticket.requestId}: "${ticket.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Hủy yêu cầu'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final ticketService = Provider.of<SupportTicketService>(context, listen: false);
      await ticketService.cancelTicket(ticket.requestId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã hủy yêu cầu #${ticket.requestId} thành công!')),
      );
    }
  }

  /// Chấm điểm và đánh giá 1-5 sao khi đã completed
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
                  Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 28),
                  SizedBox(width: 8),
                  Text('Đánh Giá Chất Lượng Hỗ Trợ'),
                ],
              ),
              content: SizedBox(
                width: 440,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yêu cầu #${ticket.requestId}: "${ticket.title}" đã hoàn thành bởi IT ${ticket.assignedItName ?? "Kỹ thuật viên"}. Vui lòng đánh giá mức độ hài lòng:',
                      style: const TextStyle(fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          final star = index + 1;
                          return IconButton(
                            icon: Icon(
                              star <= currentRating ? Icons.star_rounded : Icons.star_border_rounded,
                              size: 36,
                              color: const Color(0xFFFBBF24),
                            ),
                            onPressed: () => setRatingState(() => currentRating = star),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: feedbackController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Nhận xét thêm về tốc độ hỗ trợ và giải pháp của IT...',
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
                        content: Text('Cảm ơn bạn đã đánh giá chất lượng phục vụ của IT!'),
                        backgroundColor: Color(0xFF10B981),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFBBF24),
                    foregroundColor: Colors.black87,
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
    final isCreateMode = widget.viewMode == 'employee_create_ticket';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
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
                    isCreateMode ? 'Tạo Yêu Cầu Hỗ Trợ Kết Nối' : 'Lịch Sử Yêu Cầu Hỗ Trợ Của Tôi',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCreateMode
                        ? 'Gửi thông báo sự cố máy tính đến bộ phận IT để được hỗ trợ từ xa qua Vynex'
                        : 'Theo dõi tiến độ tiếp nhận, xử lý sự cố và đánh giá chất lượng hỗ trợ của IT',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  widget.onSwitchView(isCreateMode ? 'employee_my_tickets' : 'employee_create_ticket');
                },
                icon: Icon(isCreateMode ? Icons.history_rounded : Icons.add_circle_outline_rounded, size: 18),
                label: Text(isCreateMode ? 'Xem Lịch Sử Của Tôi' : 'Tạo Yêu Cầu Mới'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (isCreateMode) _buildCreateForm(context, isDark) else _buildHistoryList(context, isDark),
        ],
      ),
    );
  }

  /// GIAO DIỆN 1: FORM TẠO YÊU CẦU HỖ TRỢ KẾT NỐI
  Widget _buildCreateForm(BuildContext context, bool isDark) {
    final auth = Provider.of<AuthService>(context);
    final mock = MockDataService();
    final user = auth.currentUser;

    // Lọc danh sách thiết bị phù hợp
    final availableDevices = mock.devices;
    if (_selectedDeviceId == null && availableDevices.isNotEmpty) {
      final myDev = availableDevices.where((d) => d.userId == user.userId).toList();
      _selectedDeviceId = myDev.isNotEmpty ? myDev.first.deviceId : availableDevices.first.deviceId;
    }

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 720),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppConstants.primaryBlue.withOpacity(0.15),
                    child: const Icon(Icons.person_rounded, color: AppConstants.primaryBlue, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Mã NV: #${user.userId} • Tài khoản: ${user.username} • Vai trò: Nhân viên',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Đang hoạt động',
                      style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Thiết bị
            const Text('Thiết bị gặp sự cố (*):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            DropdownButtonFormField<int>(
              value: _selectedDeviceId,
              isExpanded: true,
              decoration: const InputDecoration(isDense: true),
              items: availableDevices.map((d) {
                final isMyMachine = d.userId == user.userId;
                return DropdownMenuItem<int>(
                  value: d.deviceId,
                  child: Text('${d.name} (${d.vynexId}) ${isMyMachine ? "• [Máy của bạn]" : ""}'),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedDeviceId = v);
              },
            ),
            const SizedBox(height: 18),

            // Tiêu đề sự cố
            const Text('Tiêu đề sự cố (*):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Ví dụ: Không mở được phần mềm kế toán, Lỗi mạng nội bộ, Máy tính bị đơ...',
                isDense: true,
              ),
            ),
            const SizedBox(height: 18),

            // Mức độ ưu tiên
            const Text('Mức độ ưu tiên:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(isDense: true),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('🟢 Thấp (Low) - Có thể hỗ trợ trong ngày')),
                DropdownMenuItem(value: 'normal', child: Text('🔵 Bình thường (Normal) - Xử lý trong 1-2 giờ')),
                DropdownMenuItem(value: 'high', child: Text('🟠 Cao (High) - Ảnh hưởng tiến độ công việc')),
                DropdownMenuItem(value: 'urgent', child: Text('🔴 Khẩn cấp (Urgent) - Ngưng trệ hoạt động')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _selectedPriority = v);
              },
            ),
            const SizedBox(height: 18),

            // Mô tả chi tiết
            const Text('Mô tả chi tiết hiện tượng / lỗi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Mô tả chi tiết sự cố gặp phải, thao tác trước khi xảy ra lỗi hoặc thông báo lỗi hiển thị trên màn hình...',
                isDense: true,
              ),
            ),
            const SizedBox(height: 28),

            // Nút bấm gửi
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _handleSubmitRequest,
                icon: _isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  _isSubmitting ? 'Đang gửi yêu cầu...' : 'Gửi Yêu Cầu Hỗ Trợ Tới IT',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// GIAO DIỆN 2: DANH SÁCH LỊCH SỬ YÊU CẦU CỦA CHÍNH NHÂN VIÊN
  Widget _buildHistoryList(BuildContext context, bool isDark) {
    final auth = Provider.of<AuthService>(context);
    final ticketService = Provider.of<SupportTicketService>(context);
    final currentUserId = auth.currentUser.userId;

    // CHỈ HIỂN THỊ YÊU CẦU CỦA CHÍNH NHÂN VIÊN ĐANG ĐĂNG NHẬP
    List<SupportRequestModel> myTickets = ticketService.tickets.where((t) => t.employeeId == currentUserId).toList();

    if (_historyFilter != 'all') {
      myTickets = myTickets.where((t) => t.status == _historyFilter).toList();
    }

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bộ lọc trạng thái
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('Tất cả (${ticketService.tickets.where((t) => t.employeeId == currentUserId).length})', 'all'),
              const SizedBox(width: 8),
              _buildFilterChip('Chờ xử lý (Pending)', 'pending'),
              const SizedBox(width: 8),
              _buildFilterChip('Đã tiếp nhận (Accepted)', 'accepted'),
              const SizedBox(width: 8),
              _buildFilterChip('Đang hỗ trợ (In Progress)', 'in_progress'),
              const SizedBox(width: 8),
              _buildFilterChip('Hoàn thành (Completed)', 'completed'),
              const SizedBox(width: 8),
              _buildFilterChip('Đã hủy (Cancelled)', 'cancelled'),
            ],
          ),
        ),
        const SizedBox(height: 18),

        if (myTickets.isEmpty)
          Container(
            padding: const EdgeInsets.all(48),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.inbox_rounded, size: 56, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                const SizedBox(height: 16),
                Text(
                  'Bạn chưa có yêu cầu hỗ trợ nào trong danh mục này',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Khi gặp sự cố máy tính, hãy bấm "Tạo Yêu Cầu Mới" để gửi thông báo cho IT.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => widget.onSwitchView('employee_create_ticket'),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Tạo Yêu Cầu Hỗ Trợ Ngay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: myTickets.length,
            itemBuilder: (context, index) {
              final ticket = myTickets[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Priority Pill Icon
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(ticket.priority).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.support_agent_rounded,
                        color: _getPriorityColor(ticket.priority),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Ticket Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '#${ticket.requestId}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppConstants.primaryBlue),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ticket.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ),
                              StatusBadge(status: ticket.status),
                            ],
                          ),
                          const SizedBox(height: 6),
                          if (ticket.description != null && ticket.description!.isNotEmpty) ...[
                            Text(
                              ticket.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                          Row(
                            children: [
                              Icon(Icons.computer_rounded, size: 14, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Text(
                                '${ticket.deviceName} (${ticket.vynexId})',
                                style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.access_time_rounded, size: 14, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                              const SizedBox(width: 4),
                              Text(
                                dateFormat.format(ticket.createdAt),
                                style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                              ),
                              if (ticket.assignedItName != null) ...[
                                const SizedBox(width: 16),
                                const Icon(Icons.engineering_rounded, size: 14, color: Color(0xFF10B981)),
                                const SizedBox(width: 4),
                                Text(
                                  'IT: ${ticket.assignedItName}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ],
                          ),
                          // Rating display if rated
                          if (ticket.rating != null) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text('Đánh giá của bạn: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                Row(
                                  children: List.generate(
                                    ticket.rating!,
                                    (_) => const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFBBF24)),
                                  ),
                                ),
                                if (ticket.feedback != null && ticket.feedback!.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '"${ticket.feedback}"',
                                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Actions
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (ticket.status == 'pending') ...[
                          OutlinedButton.icon(
                            onPressed: () => _handleCancelRequest(ticket),
                            icon: const Icon(Icons.cancel_outlined, size: 14),
                            label: const Text('Hủy Yêu Cầu'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                              side: const BorderSide(color: Color(0xFFFCA5A5)),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ] else if (ticket.status == 'completed' && ticket.rating == null) ...[
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
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _historyFilter == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) {
        setState(() => _historyFilter = value);
      },
      selectedColor: AppConstants.primaryBlue.withOpacity(0.2),
      checkmarkColor: AppConstants.primaryBlue,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected
            ? AppConstants.primaryBlue
            : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return const Color(0xFFEF4444);
      case 'high':
        return const Color(0xFFF59E0B);
      case 'normal':
        return const Color(0xFF3B82F6);
      case 'low':
      default:
        return const Color(0xFF10B981);
    }
  }
}
