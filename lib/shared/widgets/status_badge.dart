import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String? customLabel;
  final bool isSmall;

  const StatusBadge({
    Key? key,
    required this.status,
    this.customLabel,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label = customLabel ?? status;
    IconData? icon;

    switch (status.toLowerCase()) {
      case 'online':
      case 'active':
      case 'completed':
      case 'success':
        bg = const Color(0xFFDCFCE7); // Green light
        fg = const Color(0xFF15803D);
        icon = Icons.check_circle_rounded;
        if (customLabel == null) {
          label = status.toLowerCase() == 'online'
              ? 'Trực tuyến'
              : (status.toLowerCase() == 'completed' ? 'Hoàn thành' : 'Hoạt động');
        }
        break;
      case 'offline':
      case 'inactive':
      case 'disabled':
        bg = const Color(0xFFF1F5F9); // Gray
        fg = const Color(0xFF64748B);
        icon = Icons.radio_button_unchecked_rounded;
        if (customLabel == null) {
          label = status.toLowerCase() == 'offline' ? 'Ngoại tuyến' : 'Tạm dừng';
        }
        break;
      case 'pending':
        bg = const Color(0xFFFEF3C7); // Yellow
        fg = const Color(0xFFB45309);
        icon = Icons.hourglass_top_rounded;
        if (customLabel == null) label = 'Đang chờ';
        break;
      case 'accepted':
      case 'in_progress':
      case 'started':
        bg = const Color(0xFFDBEAFE); // Blue
        fg = const Color(0xFF1D4ED8);
        icon = Icons.sync_rounded;
        if (customLabel == null) {
          label = status.toLowerCase() == 'accepted' ? 'Đã nhận' : 'Đang xử lý';
        }
        break;
      case 'rejected':
      case 'failed':
      case 'revoked':
      case 'expired':
        bg = const Color(0xFFFEE2E2); // Red
        fg = const Color(0xFFB91C1C);
        icon = Icons.cancel_rounded;
        if (customLabel == null) {
          label = status.toLowerCase() == 'rejected'
              ? 'Đã từ chối'
              : (status.toLowerCase() == 'expired' ? 'Hết hạn' : 'Đã thu hồi');
        }
        break;
      case 'urgent':
      case 'high':
        bg = const Color(0xFFFFEDD5); // Orange/Red
        fg = const Color(0xFFC2410C);
        icon = Icons.warning_amber_rounded;
        if (customLabel == null) label = status.toLowerCase() == 'urgent' ? 'Khẩn cấp' : 'Cao';
        break;
      case 'normal':
      case 'low':
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF4338CA);
        if (customLabel == null) label = status.toLowerCase() == 'normal' ? 'Bình thường' : 'Thấp';
        break;
      default:
        bg = const Color(0xFFF1F5F9);
        fg = const Color(0xFF475569);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isSmall ? 12 : 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
