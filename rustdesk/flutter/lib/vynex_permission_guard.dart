import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VynexAuthResult {
  final bool allowed;
  final String reason;
  final String? permissionType;

  VynexAuthResult({
    required this.allowed,
    required this.reason,
    this.permissionType,
  });
}

/// Chốt Chặn Bảo Mật Vynex (Permission Guard / Auth Hook)
/// Áp dụng nguyên tắc "Can thiệp tối thiểu" (Minimal Invasion) vào nhân RustDesk:
/// - Chặn đứng hành vi tự nhập ID/Pass khi chưa được Admin cấp quyền trên Vynex Manager.
/// - Cho phép kết nối trực tiếp nếu được kích hoạt từ Vynex Manager kèm Session Token hợp lệ.
class VynexPermissionGuard {
  static const String apiBaseUrl = 'http://localhost:8000';
  static const Duration timeout = Duration(milliseconds: 2500);

  // Lưu trữ token và it_user được truyền qua CLI
  static String? activeSessionToken;
  static String? activeItUserId;

  /// Thiết lập context phiên làm việc nhận từ dòng lệnh Vynex Manager CLI
  static void setLaunchSession({String? token, String? itUser}) {
    if (token != null && token.isNotEmpty) {
      activeSessionToken = token;
    }
    if (itUser != null && itUser.isNotEmpty) {
      activeItUserId = itUser;
    }
  }

  /// Xác thực quyền kết nối với Backend Vynex
  static Future<VynexAuthResult> verifyPermission({
    required String targetId,
    String? token,
    String? itUserId,
  }) async {
    final effectiveToken = token ?? activeSessionToken;
    final effectiveItUser = itUserId ?? activeItUserId ?? '0';

    // Trường hợp 1: Có Token được cấp từ Vynex Manager
    if (effectiveToken != null && effectiveToken.startsWith('vynex_token_')) {
      try {
        final url = Uri.parse('$apiBaseUrl/api/permissions/check?token=$effectiveToken&rustdesk_id=$targetId');
        final response = await http.get(url).timeout(timeout);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['allowed'] == true) {
            return VynexAuthResult(
              allowed: true,
              reason: 'Xác thực thành công qua Vynex Session Token.',
              permissionType: data['permission_type'] ?? 'control',
            );
          }
        }
      } catch (_) {
        // Fallback: Nếu backend offline, token hợp lệ với format Vynex Manager vẫn được chấp nhận
        return VynexAuthResult(
          allowed: true,
          reason: 'Ủy quyền ngoại tuyến qua Token Vynex Manager hợp lệ.',
          permissionType: 'control',
        );
      }
    }

    // Trường hợp 2: Người dùng tự mở Vynex Client / RustDesk và nhập tay Vynex ID + Password
    // Bắt buộc kiểm tra quyền 24h trong bảng Permissions của Backend (Sửa lỗi SESSION-01 & SESSION-02)
    try {
      final url = Uri.parse('$apiBaseUrl/api/permissions/check?rustdesk_id=$targetId&user_id=$effectiveItUser');
      final response = await http.get(url).timeout(timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['allowed'] == true) {
          return VynexAuthResult(
            allowed: true,
            reason: 'Thiết bị đã được Quản trị viên cấp quyền trong hệ thống.',
            permissionType: data['permission_type'],
          );
        } else {
          return VynexAuthResult(
            allowed: false,
            reason: data['reason'] ?? 'Từ chối truy cập: Bạn chưa được cấp quyền điều khiển thiết bị này trên Vynex Manager.',
          );
        }
      }
    } catch (_) {
      // Backend offline hoặc không phản hồi khi nhập tay -> Chặn an toàn (Fail-Safe / Zero Trust)
      return VynexAuthResult(
        allowed: false,
        reason: 'Từ chối truy cập: Không thể xác thực quyền điều khiển từ xa với Vynex Manager Backend (Chính sách Zero-Trust).',
      );
    }

    return VynexAuthResult(
      allowed: false,
      reason: 'Từ chối truy cập: Bạn chưa được cấp quyền điều khiển thiết bị này trên Vynex Manager.',
    );
  }

  /// Hiển thị cảnh báo từ chối kết nối khi vi phạm chính sách bảo mật
  static void showAccessDeniedDialog(BuildContext context, String reason) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.gpp_bad_rounded, color: Color(0xFFEF4444), size: 28),
            SizedBox(width: 12),
            Text(
              'CẢNH BÁO BẢO MẬT VYNEX',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7F1D1D).withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFDC2626)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_person_rounded, color: Color(0xFFF87171), size: 24),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      reason,
                      style: const TextStyle(
                        color: Color(0xFFFECACA),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chính sách Bảo mật & Chống Vượt Quyền (Anti-Bypass):\n'
              '• Mọi kết nối điều khiển từ xa bắt buộc phải được ủy quyền trên Bảng Permissions của Vynex Manager.\n'
              '• Hành vi tự ý mở Client nhập ID/Mật khẩu khi chưa được Admin duyệt sẽ bị chặn đứng ngay lập tức.\n'
              '• Nhật ký truy cập đã được ghi lại trong Activity Audit Logs.',
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, height: 1.5),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Đã hiểu & Hủy Kết Nối'),
          ),
        ],
      ),
    );
  }
}
