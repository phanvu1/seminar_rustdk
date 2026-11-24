# HƯỚNG DẪN TRIỂN KHAI THỰC TẾ HỆ THỐNG VYNEX ENTERPRISE (3 MÁY)

> **Mô hình thử nghiệm:**  
> 1. **Máy 1: Quản Trị Viên (Admin)** — Windows Host (`10.13.13.2`)  
> 2. **Máy 2: Kỹ Thuật Viên IT (Đạt)** — Windows Client (`10.13.13.4`)  
> 3. **Máy 3: Nhân Viên Kế Toán (Mai)** — Ubuntu Linux 24.04 LTS (`10.13.13.3`)  
> **Server Trung Tâm:** VPS Cloud `34.87.182.49` (WireGuard `10.13.13.1`)

---

## GIAI ĐOẠN 0: TRẠNG THÁI HỆ THỐNG ĐÃ LÀM SẠCH

Cơ sở dữ liệu trên VPS đã được xóa toàn bộ dữ liệu mẫu, chỉ còn duy nhất tài khoản Quản trị:
* **Tài khoản Admin:** `admin` | Mật khẩu: `123`
* **Thiết bị Admin:** `PC-IT-ADMIN (Host Windows)` | IP: `10.13.13.2`

---

## GIAI ĐOẠN 1: TẠO TÀI KHOẢN CHO ĐẠT VÀ MAI (TRÊN MÁY ADMIN)

Admin mở ứng dụng **Vynex Manager** trên máy Windows:

### 1. Tạo tài khoản cho IT Đạt:
1. Vào mục **"Người dùng & Phòng ban"** -> Bấm **"+ Thêm người dùng mới"**.
2. Điền thông tin:
   * **Tên đăng nhập (Username):** `dat`
   * **Họ và tên:** `Nguyễn Thành Đạt`
   * **Email:** `dat@vynex.vn`
   * **Phòng ban:** `Phòng Kỹ thuật & IT` (hoặc Phòng Kỹ thuật)
   * **Vai trò:** Chọn **`Nhân viên IT`**
   * **Mật khẩu khởi tạo:** `123`
3. Bấm **"Lưu người dùng"**.

### 2. Tạo tài khoản cho Nhân viên Mai:
1. Tiếp tục bấm **"+ Thêm người dùng mới"**.
2. Điền thông tin:
   * **Tên đăng nhập (Username):** `mai`
   * **Họ và tên:** `Phạm Thị Mai`
   * **Email:** `mai@vynex.vn`
   * **Phòng ban:** `Phòng Kế toán & Tài chính`
   * **Vai trò:** Chọn **`Nhân viên (Employee)`**
   * **Mật khẩu khởi tạo:** `123` (hoặc `1234`)
3. Bấm **"Lưu người dùng"**.

---

## GIAI ĐOẠN 2: TRIỂN KHAI TRÊN MÁY WINDOWS CỦA IT ĐẠT

### Bước 1: Cài đặt WireGuard VPN trên máy Đạt
1. Tải và cài đặt phần mềm WireGuard cho Windows từ trang chủ: `https://www.wireguard.com/install/`
2. Mở WireGuard -> Chọn **"Add Tunnel"** (Thêm hầm).
3. Chọn file chứng chỉ:  
   📂 **`dist/Admin_VPN_Peers_Vault/peer3_Employee_Windows.conf`**  
   *(IP cấp phát của Đạt: `10.13.13.4`)*
4. Bấm **"Activate"** để kết nối vào mạng riêng ảo VPN. Kiểm tra thấy có dữ liệu `Transfer: ... KiB received` là thành công.

### Bước 2: Cài đặt Vynex Enterprise trên máy Đạt
1. Copy file [dist/portal/Vynex_Enterprise_Windows_v2.0.zip](file:///d:/HKI%202026-2027/Seminar/seminar_rustdk/dist/portal/Vynex_Enterprise_Windows_v2.0.zip) sang máy của Đạt.
2. Giải nén file `.zip`.
3. Chạy file **`Vynex_Quan_Tri_IT.bat`** (hoặc mở `Manager/vynex_manager.exe`).
4. **Đăng nhập:**
   * Tài khoản: `dat`
   * Mật khẩu: `123`
5. Kiểm tra mục **"Quản lý thiết bị"**: Đạt sẽ thấy danh sách thiết bị công ty và trạng thái online của máy Mai khi máy Mai kết nối.

---

## GIAI ĐOẠN 3: TRIỂN KHAI TRÊN MÁY UBUNTU LINUX CỦA MAI

### Cách 1: Tải trực tiếp từ Cổng Web Portal nội bộ (Khuyên dùng)
1. Trên máy Ubuntu của Mai, mở trình duyệt vào địa chỉ:  
   👉 **`http://34.87.182.49:8000/download`**
2. Bấm nút **"Tải về cho Linux / Ubuntu (.tar.gz)"** để tải gói `Vynex_Enterprise_Linux_v2.0.tar.gz`.

### Cách 2: Copy file cài đặt từ máy Admin
* Copy file [dist/portal/Vynex_Enterprise_Linux_v2.0.tar.gz](file:///d:/HKI%202026-2027/Seminar/seminar_rustdk/dist/portal/Vynex_Enterprise_Linux_v2.0.tar.gz) và file chứng chỉ **`dist/Admin_VPN_Peers_Vault/peer2_Employee_Ubuntu.conf`** sang máy Ubuntu.

### Các lệnh cài đặt trên Ubuntu (Chỉ mất 1 phút):
Mở Terminal trên Ubuntu và chạy các lệnh sau:

```bash
# 1. Tạo thư mục và giải nén gói cài đặt
mkdir -p ~/vynex_install && cd ~/vynex_install
tar -xzf /path/to/Vynex_Enterprise_Linux_v2.0.tar.gz -C .

# 2. Đặt file chứng chỉ VPN của Mai vào cùng thư mục này
cp /path/to/peer2_Employee_Ubuntu.conf .

# 3. Phân quyền và chạy script cài đặt tự động
chmod +x install.sh
sudo ./install.sh
```

**Script `install.sh` sẽ tự động 100%:**
* Cài đặt WireGuard VPN và nạp IP `10.13.13.3`.
* Cài đặt RustDesk Engine bản Linux.
* Tự động tiêm cấu hình Server VPS Cloud `10.13.13.1`, Public Key bảo mật.
* **Tự động kích hoạt cổng kết nối siêu tốc nội bộ:** `direct-server = 'Y'`, cổng `21118`.
* Đổi tên ứng dụng thành **Vynex Client** trên menu Ubuntu.

---

## GIAI ĐOẠN 4: KỊCH BẢN KIỂM THỬ THỰC TẾ GIỮA 3 MÁY (TEST SCENARIOS)

### Kịch bản 1: Kiểm thử kết nối siêu tốc cùng mạng (Direct IP Port 21118)
1. Trên máy Đạt (IT - `10.13.13.4`), vào mục **"Quản lý thiết bị"**.
2. Chọn máy **Mai (Ubuntu - `10.13.13.3`)** -> Bấm **"Kết Nối Ngay"**.
3. **Kết quả mong đợi:** 
   * Vynex Launcher nhận diện máy Mai có IP `10.13.13.3` (cùng subnet WireGuard `10.13.13.x`).
   * Launcher tự động gọi RustDesk kết nối thẳng cổng `21118` của máy Mai.
   * Màn hình Ubuntu hiện lên **ngay lập tức** (< 5ms), không bị chờ đục lỗ NAT.

### Kịch bản 2: Kiểm thử Chính sách Bảo vệ Admin (Unidirectional Guard)
1. Trên máy Đạt (IT), thử bấm kết nối vào máy **`PC-IT-ADMIN (Host Windows)`**.
2. **Kết quả mong đợi:** Hệ thống hiện thông báo đỏ cảnh báo:
   > *"Bảo Vệ Máy Quản Trị Viên: Chính sách bảo mật Unidirectional Guard nghiêm cấm mọi tài khoản khác điều khiển máy của Admin dưới bất kỳ hình thức nào!"*  
   Đạt bị chặn đứng, không thể xem hoặc điều khiển máy Admin.

### Kịch bản 3: Kiểm thử Xin quyền & Từ chối quyền
1. Khi máy Mai chưa được Admin duyệt quyền điều khiển vĩnh viễn:
   * Trên máy Đạt, nút máy Mai hiển thị: **`Yêu cầu cấp quyền kết nối`**.
   * Đạt bấm nút -> Nút đổi sang **`Đã gửi yêu cầu`** (màu hổ phách).
2. Trên máy Admin:
   * Hiện thông báo yêu cầu của Đạt.
   * Admin bấm **"Từ Chối"**.
3. Quay lại máy Đạt:
   * Nhận ngay thông báo: *"Admin đã từ chối yêu cầu cấp quyền..."*.
   * Nút máy Mai lập tức chuyển sang **`Bị từ chối (Gửi lại)`** (màu đỏ).
4. Admin bấm **"Duyệt Quyền 24h"**:
   * Nút máy Mai trên máy Đạt chuyển sang màu xanh **`Kết Nối Ngay`**.

### Kịch bản 4: Nhân viên Mai gửi Ticket hỗ trợ
1. Trên máy Mai, gửi yêu cầu: *"Cần hỗ trợ cấu hình máy in phòng kế toán"*.
2. Máy Đạt (IT) nhận được thông báo Ticket mới.
3. Đạt bấm **"Tiếp nhận"** -> Kết nối sửa máy Mai -> Bấm **"Hoàn tất"**.
