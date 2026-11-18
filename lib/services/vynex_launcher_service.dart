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
    if (Platform.isLinux) {
      final linuxPaths = [
        '/usr/bin/vynex',
        '/usr/bin/rustdesk',
        '/usr/local/bin/vynex',
        '/usr/local/bin/rustdesk',
      ];
      for (final p in linuxPaths) {
        if (File(p).existsSync()) return p;
      }
    }

    final List<String> possiblePaths = [
      // 1. Thư mục bundle client chuyên biệt trong build output
      '${Directory.current.path}\\dist\\Vynex_Enterprise_Windows\\Client\\vynex.exe',
      '${Directory.current.path}\\build\\windows\\x64\\runner\\Release\\vynex.exe',
      '${Directory.current.path}\\build\\windows\\x64\\runner\\Release\\vynex_client\\vynex_client.exe',
      '${Directory.current.path}\\dist\\Vynex_Client\\vynex_client.exe',
      // 2. Thư mục build RustDesk Release trong dự án (chứa trọn vẹn DLLs + data)
      '${Directory.current.path}\\rustdesk\\flutter\\build\\windows\\x64\\runner\\Release\\vynex.exe',
      '${Directory.current.path}\\rustdesk\\flutter\\build\\windows\\x64\\runner\\Release\\vynex_client.exe',
      '${Directory.current.path}\\rustdesk\\flutter\\build\\windows\\x64\\runner\\Release\\rustdesk.exe',
      // 3. Thư mục con vynex_client cùng cấp với file vynex_manager.exe đang chạy
      '${Directory.current.path}\\vynex.exe',
      '${Directory.current.path}\\vynex_client\\vynex_client.exe',
      '${Directory.current.path}\\vynex_client.exe',
      '${Directory.current.path}\\rustdesk.exe',
    ];

    // Kiểm tra thư mục chứa file .exe đang chạy (nếu là bản build release)
    try {
      final currentExeDir = File(Platform.resolvedExecutable).parent.path;
      possiblePaths.insert(0, '$currentExeDir\\vynex.exe');
      possiblePaths.insert(0, '$currentExeDir\\vynex_client\\vynex_client.exe');
      possiblePaths.insert(0, '$currentExeDir\\..\\Client\\vynex.exe');
      possiblePaths.insert(0, '$currentExeDir\\..\\Vynex_Client\\vynex_client.exe');
      possiblePaths.insert(0, '$currentExeDir\\..\\Vynex_Enterprise_Windows\\Client\\vynex.exe');
      possiblePaths.insert(0, '$currentExeDir\\vynex_client.exe');
      possiblePaths.insert(0, '$currentExeDir\\rustdesk.exe');
    } catch (_) {}

    for (final path in possiblePaths) {
      if (File(path).existsSync()) {
        return path;
      }
    }
    return null;
  }

  /// Lấy Vynex ID thực tế của máy tính này từ Vynex Client
  static Future<String?> getLocalId() async {
    final clientExe = findClientExecutable();
    if (clientExe == null) return null;

    try {
      final res = await Process.run(
        clientExe,
        ['--get-id'],
        workingDirectory: File(clientExe).parent.path,
      ).timeout(const Duration(seconds: 3));

      if (res.exitCode == 0 && res.stdout.toString().trim().isNotEmpty) {
        final rawId = res.stdout.toString().trim();
        if (rawId.length == 9) {
          return '${rawId.substring(0, 3)} ${rawId.substring(3, 6)} ${rawId.substring(6, 9)}';
        } else if (rawId.length == 10) {
          return '${rawId.substring(0, 3)} ${rawId.substring(3, 6)} ${rawId.substring(6, 10)}';
        }
        return rawId;
      }
    } catch (e) {
      debugPrint('[Vynex Launcher] getLocalId error: $e');
    }
    return null;
  }

  /// Khởi chạy Vynex Client với các tham số ủy quyền bảo mật
  static Future<VynexLaunchResult> launchClient({
    required String vynexId,
    required String token,
    int? itUserId,
    String? password,
    bool isFileTransfer = false,
  }) async {
    final clientExe = findClientExecutable();

    if (clientExe == null) {
      debugPrint(
          '[Vynex Launcher] Không tìm thấy file vynex.exe, vynex_client.exe hoặc rustdesk.exe');
      return VynexLaunchResult(
        success: false,
        message: 'Không tìm thấy file thực thi vynex.exe trên máy tính.',
      );
    }

    try {
      final workingDir = File(clientExe).parent.path;
      final cleanId = vynexId.replaceAll(' ', '');
      debugPrint(
          '[Vynex Launcher] Khởi chạy: $clientExe trong thư mục: $workingDir --connect $cleanId (fileTransfer=$isFileTransfer)');

      final actionFlag = isFileTransfer ? '--file-transfer' : '--connect';
      final args = [
        actionFlag,
        cleanId,
      ];

      // Nếu có mật khẩu tự động (từ nhân viên hoặc hệ thống) -> truyền trực tiếp vào tham số CLI
      if (password != null && password.isNotEmpty) {
        args.addAll(['--password', password]);
      }

      args.addAll([
        '--token',
        token,
        '--it-user',
        (itUserId ?? 0).toString(),
      ]);

      // Khởi chạy tiến trình Vynex Client ở chế độ Detached kèm workingDirectory để nạp đầy đủ DLL
      await Process.start(
        clientExe,
        args,
        workingDirectory: workingDir, // BẮT BUỘC: Đảm bảo Windows nạp đúng DLL
        mode: ProcessStartMode.detached,
      );

      final modeText = isFileTransfer ? 'phiên Truyền Tệp' : 'phiên Điều Khiển Màn Hình';
      return VynexLaunchResult(
        success: true,
        message: 'Đã khởi chạy Vynex Client ($modeText) tới máy $cleanId thành công.',
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
