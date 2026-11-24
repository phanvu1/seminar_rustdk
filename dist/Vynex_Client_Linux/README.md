# HƯỚNG DẪN CÀI ĐẶT VYNEX CLIENT TRÊN UBUNTU / LINUX (MÁY MAI)

Gói `Vynex_Enterprise_Linux_v2.0.tar.gz` là **BỘ CÀI VẠN NĂNG TỰ ĐỘNG 100%** cho nhân viên sử dụng hệ điều hành Ubuntu / Linux.
Chứng chỉ VPN WireGuard (`peer2_Employee_Ubuntu.conf` - IP `10.13.13.3`) **ĐÃ ĐƯỢC TÍCH HỢP SẴN** bên trong gói.

---

### CÁC BƯỚC CÀI ĐẶT 1 CHẠM TRÊN UBUNTU:

1. **Mở Terminal (phím tắt `Ctrl + Alt + T`) và giải nén:**
   ```bash
   tar -xzf Vynex_Enterprise_Linux_v2.0.tar.gz
   ```

2. **Cấp quyền và chạy script cài đặt:**
   ```bash
   chmod +x install.sh
   sudo ./install.sh
   ```

---

### KẾT QUẢ TỰ ĐỘNG SAU KHI CHẠY:
Script sẽ tự động hoàn toàn:
1. Cài đặt WireGuard VPN và tự động tải/cài Vynex/RustDesk Engine nếu máy chưa có.
2. Tự động nhận diện chứng chỉ `peer2_Employee_Ubuntu.conf` và kích hoạt hầm VPN `10.13.13.3`.
3. Tự động cấu hình máy chủ VPS Cloud `10.13.13.1`, Relay `10.13.13.1:21117`, API Server và Public Key.
4. Đổi tên ứng dụng thành **Vynex Client** trên menu ứng dụng Ubuntu.
5. Cửa sổ Vynex Client xuất hiện với **Chấm xanh (Ready)** và mã Vynex ID (9 chữ số) để IT Đạt hỗ trợ từ xa!
