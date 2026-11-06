import 'dart:io';
import 'package:flutter/foundation.dart';

class VynexLaunchResult {
  final bool success;
  final String message;
  final String? executablePath;

  VynexLaunchResult({
    required this.success,
    required this.message,
    this.executablePath,
  });
}

/// Dịch vụ khởi chạy liên tiến trình (IPC / CLI Launcher)
/// Kết nối giữa Vynex Manager (.exe) và Vynex Client (.exe)
class VynexLauncherService {
  /// Tìm kiếm vị trí thực thi của Vynex Client (RustDesk)
  static String? findClientExecutable() {
    final List<String> possiblePaths = [
      // 1. Thư mục bundle client chuyên biệt trong build output
      '${Directory.current.path}\\build\\windows\\x64\\runner\\Release\\vynex_client\\vynex_client.exe',
      // 2. Thư mục build RustDesk Release trong dự án (chứa trọn vẹn DLLs + data)
      'D:\\Dabeo\\work\\seminar_rustdk\\rustdesk\\flutter\\build\\windows\\x64\\runner\\Release\\vynex_client.exe',
      'D:\\Dabeo\\work\\seminar_rustdk\\rustdesk\\flutter\\build\\windows\\x64\\runner\\Release\\rustdesk.exe',
      '${Directory.current.path}\\rustdesk\\flutter\\build\\windows\\x64\\runner\\Release\\vynex_client.exe',
      '${Directory.current.path}\\rustdesk\\flutter\\build\\windows\\x64\\runner\\Release\\rustdesk.exe',
      // 3. Thư mục con vynex_client cùng cấp với file vynex_manager.exe đang chạy
      '${Directory.current.path}\\vynex_client\\vynex_client.exe',
      '${Directory.current.path}\\vynex_client.exe',
      '${Directory.current.path}\\rustdesk.exe',
    ];

    // Kiểm tra thư mục chứa file .exe đang chạy (nếu là bản build release)
    try {
      final currentExeDir = File(Platform.resolvedExecutable).parent.path;
      possiblePaths.insert(0, '$currentExeDir\\vynex_client\\vynex_client.exe');
      possiblePaths.insert(1, '$currentExeDir\\vynex_client.exe');
      possiblePaths.insert(2, '$currentExeDir\\rustdesk.exe');
    } catch (_) {}

    for (final path in possiblePaths) {
      if (File(path).existsSync()) {
        return path;
      }
    }
    return null;
  }

  /// Khởi chạy Vynex Client với các tham số ủy quyền bảo mật
  static Future<VynexLaunchResult> launchClient({
    required String vynexId,
    required String token,
    int? itUserId,
  }) async {
    final clientExe = findClientExecutable();

    if (clientExe == null) {
      debugPrint('[Vynex Launcher] Không tìm thấy file vynex_client.exe hoặc rustdesk.exe');
      return VynexLaunchResult(
        success: false,
        message: 'Không tìm thấy file thực thi vynex_client.exe trên máy tính.',
      );
    }

    try {
      final workingDir = File(clientExe).parent.path;
      debugPrint('[Vynex Launcher] Khởi chạy: $clientExe trong thư mục: $workingDir --connect $vynexId --token $token --it-user $itUserId');

      // Khởi chạy tiến trình Vynex Client ở chế độ Detached kèm workingDirectory để nạp đầy đủ DLL
      await Process.start(
        clientExe,
        [
          '--connect',
          vynexId,
          '--token',
          token,
          '--it-user',
          (itUserId ?? 0).toString(),
        ],
        workingDirectory: workingDir, // BẮT BUỘC: Đảm bảo Windows nạp đúng DLL
        mode: ProcessStartMode.detached,
      );

      return VynexLaunchResult(
        success: true,
        message: 'Đã khởi chạy Vynex Client kết nối tới máy $vynexId thành công.',
        executablePath: clientExe,
      );
    } catch (e) {
      debugPrint('[Vynex Launcher] Lỗi khởi chạy: $e');
      return VynexLaunchResult(
        success: false,
        message: 'Lỗi khi gọi tiến trình Vynex Client: $e',
      );
    }
  }
}
