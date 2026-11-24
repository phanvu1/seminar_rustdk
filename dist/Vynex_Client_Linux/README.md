# HƯỚNG DẪN CÀI ĐẶT & KHỞI CHẠY VYNEX ENTERPRISE (UBUNTU / LINUX)

Trọn bộ cài đặt bao gồm cả **Vynex Client (Engine điều khiển từ xa)** và **Vynex Manager (Bảng điều khiển & Gửi Ticket hỗ trợ của Nhân viên)**.

---

### BƯỚC 1: CÀI ĐẶT TỰ ĐỘNG (CHẠY 1 LẦN DUY NHẤT)

Tại thư mục này, mở Terminal và chạy lệnh cài đặt:
```bash
chmod +x install.sh
sudo ./install.sh
```

**Script `install.sh` sẽ tự động thực hiện:**
1. Kích hoạt VPN WireGuard với chứng chỉ `peer2_Employee_Ubuntu.conf` (IP `10.13.13.3`).
2. Cài đặt và cấu hình Vynex/RustDesk Engine kết nối máy chủ VPS `10.13.13.1`.
3. Tự động tạo 2 biểu tượng trên Desktop và cấp quyền chạy cho hệ thống:
   - 🖥️ **Vynex Client**
   - 🎫 **Vynex Manager**

---

### BƯỚC 2: KHỞI CHẠY ỨNG DỤNG

Sau khi cài đặt xong, bạn có thể chạy bằng bất kỳ cách nào dưới đây:

#### 1. Chạy Vynex Manager (Giao diện Nhân viên / IT Dashboard):
* **Từ Terminal:**
  ```bash
  chmod +x run_manager.sh
  ./run_manager.sh
  ```
  *(Hoặc click đúp vào file icon **Vynex Manager** trên Desktop)*
* **Đăng nhập:**
  - Tài khoản: `mai` (hoặc `admin` / `dat`)
  - Mật khẩu: `123`

#### 2. Chạy Vynex Client (Nhận điều khiển từ xa):
* **Từ Terminal:**
  ```bash
  rustdesk &
  ```
  *(Cửa sổ hiện lên với Chấm xanh Ready và mã ID 9 chữ số)*

#### 3. Chạy Menu tổng hợp (Giống Windows):
```bash
chmod +x run_vynex.sh
./run_vynex.sh
```
Lựa chọn [1] để mở Manager hoặc [2] để mở Client.
