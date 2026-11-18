# HƯỚNG DẪN CÀI ĐẶT VYNEX CLIENT TRÊN UBUNTU / LINUX

Gói `Vynex_Enterprise_Linux_v2.0.tar.gz` là **BỘ CÀI VẠN NĂNG** cho nhân viên sử dụng hệ điều hành Ubuntu / Linux.

### CÁC BƯỚC THỰC HIỆN TRÊN MÁY UBUNTU:

1. **Giải nén gói cài đặt:**
   ```bash
   tar -xvf Vynex_Enterprise_Linux_v2.0.tar.gz
   cd Vynex_Client_Linux
   ```

2. **Copy file chứng chỉ WireGuard VPN (*.conf):**
   - Lấy file chứng chỉ VPN do Admin cấp (ví dụ: `peer2_Employee_Ubuntu.conf` hoặc `peer2.conf`) đặt vào **cùng thư mục** với file `install.sh`.

3. **Chạy script cài đặt:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

4. **Kết quả:**
   Script sẽ tự động:
   - Cài đặt WireGuard VPN và tự động tải cài RustDesk Engine nếu máy chưa có.
   - Kích hoạt hầm VPN an toàn kết nối tới VPS Cloud `34.87.182.49`.
   - Cấu hình sẵn máy chủ nội bộ `10.13.13.1`, Relay `10.13.13.1:21117`, API `http://34.87.182.49:8000` và Public Key.
   - Vynex Client sẽ hiện **Chấm xanh (Ready)** và sẵn sàng nhận hỗ trợ từ IT!
