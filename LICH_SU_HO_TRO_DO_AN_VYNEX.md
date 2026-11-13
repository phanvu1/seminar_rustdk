# TỔNG HỢP TOÀN BỘ LỊCH SỬ HỖ TRỢ & GIẢI PHÁP ĐỒ ÁN VYNEX
**Dự án:** Hệ thống Quản trị & Hỗ trợ Từ xa Doanh nghiệp Vynex (Custom RustDesk Engine + WireGuard VPN + FastAPI Backend)  
**Thời gian ghi nhận:** Ngày 07 - 08 tháng 11 năm 2026  
**Mục đích tài liệu:** Lưu trữ chi tiết toàn bộ quá trình xử lý kỹ thuật, cấu hình mạng, sửa lỗi mã nguồn và kiến trúc triển khai để làm tài liệu tham khảo cho các phiên làm việc tiếp theo hoặc bàn giao cho thành viên nhóm/chat khác.

---

## MỤC LỤC
1. [Vấn đề 1: Bỏ qua (Bypass) chốt chặn quyền Vynex khi phát triển Client](#1-vấn-đề-1-bỏ-qua-bypass-chốt-chặn-quyền-vynex-khi-phát-triển-client)
2. [Vấn đề 2: Đổi tên file nhị phân đầu ra thành `vynex.exe` thay vì `rustdesk.exe`](#2-vấn-đề-2-đổi-tên-file-nhị-phân-đầu-ra-thành-vynexexe-thay-vì-rustdeskexe)
3. [Vấn đề 3: Khắc phục lỗi "Máy ảo Ubuntu báo máy Windows Ngoại tuyến"](#3-vấn-đề-3-khắc-phục-lỗi-máy-ảo-ubuntu-báo-máy-windows-ngoại-tuyến)
4. [Vấn đề 4: Định hướng kiến trúc WireGuard VPN bảo vệ Client theo yêu cầu Giảng viên](#4-vấn-đề-4-định-hướng-kiến-trúc-wireguard-vpn-bảo-vệ-client-theo-yêu-cầu-giảng-viên)
5. [Vấn đề 5: Hướng dẫn triển khai thực tế toàn bộ hệ thống lên VPS Server](#5-vấn-đề-5-hướng-dẫn-triển-khai-thực-tế-toàn-bộ-hệ-thống-lên-vps-server)
6. [Vấn đề 6: Thiết lập thực tế & Kiểm chứng dữ liệu mã hóa qua WireGuard VPN](#6-vấn-đề-6-thiết-lập-thực-tế--kiểm-chứng-dữ-liệu-mã-hóa-qua-wireguard-vpn)
7. [Vấn đề 7: Xử lý lỗi "Bị chặn quyền" & "Không thể kết nối máy chủ chuyển tiếp (Relay)"](#7-vấn-đề-7-xử-lý-lỗi-bị-chặn-quyền--không-thể-kết-nối-máy-chủ-chuyển-tiếp-relay)
8. [Tổng kết: Phân biệt bản chất giữa Môi trường Lab và Môi trường VPS Production](#8-tổng-kết-phân-biệt-bản-chất-giữa-môi-trường-lab-và-môi-trường-vps-production)

---

## 1. VẤN ĐỀ 1: BỎ QUA (BYPASS) CHỐT CHẶN QUYỀN VYNEX KHI PHÁT TRIỂN CLIENT

### Bối cảnh
Người dùng mở file `rustdesk.exe` trong `rustdesk\flutter\build\windows\x64\runner\Release` nhưng bị chốt chặn `VynexPermissionGuard` yêu cầu phải có quyền từ hệ thống quản trị Vynex Manager mới cho phép kết nối. Quá trình phát triển cần bỏ qua bước này để test nhanh.

### Phân tích kỹ thuật
* Trong `rustdesk/flutter/lib/vynex_permission_guard.dart`, hàm `verifyPermission` kiểm tra 2 trường hợp:
  1. Nếu có token phiên làm việc bắt đầu bằng `vynex_token_` (gồm >= 4 thành phần cách nhau bởi dấu `_`): Hệ thống tự động chấp nhận (kể cả khi offline).
  2. Nếu người dùng nhập tay ID/Password: Gửi request `GET http://localhost:8000/api/permissions/check?rustdesk_id=...`.
* Trong `api/main.py`: Hàm `check_permission` thẩm định quyền trong bảng `Permissions` trên CSDL MySQL.

### Giải pháp
* **Cách 1 (Không sửa code, không build lại):** Chạy lệnh kèm tham số token hợp lệ:
  ```powershell
  .\rustdesk.exe --token vynex_token_dev_bypass_all
  ```
* **Cách 2 (Sửa Backend API - Khuyên dùng):** Thêm cờ cho phép bypass ngay đầu hàm `check_permission` tại `api/main.py`:
  ```python
  @app.get("/api/permissions/check")
  @app.get("/api/permissions/verify")
  @app.get("/api/permissions/verify-access")
  def check_permission(user_id: int = 0, rustdesk_id: str = "", device_id: int = 0, token: str = "", db: Session = Depends(get_db)):
      return {
          "allowed": True,
          "permission_type": "control",
          "reason": "Bypass thành công cho môi trường test"
      }
  ```
* **Cách 3 (Sửa trực tiếp trong Flutter):** Trong `rustdesk/flutter/lib/vynex_permission_guard.dart`, return ngay `VynexAuthResult(allowed: true, reason: 'Bypass')`.

---

## 2. VẤN ĐỀ 2: ĐỔI TÊN FILE NHỊ PHÂN ĐẦU RA THÀNH `vynex.exe` THAY VÌ `rustdesk.exe`

### Bối cảnh
Người dùng đã đổi tên ứng dụng sang Vynex nhưng khi build Flutter Release trên Windows, file sinh ra vẫn là `rustdesk.exe`.

### Nguyên nhân
Trong Flutter Desktop cho Windows, tên file thực thi (`.exe`) do **CMake quyết định 100%**, chứ không phụ thuộc vào `pubspec.yaml` hay file ở thư mục gốc. Trước đó người dùng đã sửa `windows/CMakeLists.txt` ở root (vốn là của `vynex_manager.exe`), trong khi Client nằm riêng tại `rustdesk/flutter/windows/CMakeLists.txt` vẫn đang để `set(BINARY_NAME "rustdesk")`.

### Các vị trí bắt buộc sửa:
1. **`rustdesk/flutter/windows/CMakeLists.txt`:**
   * Dòng 3: `project(vynex LANGUAGES CXX)`
   * Dòng 7: `set(BINARY_NAME "vynex")` (hoặc `"vynex_client"`)
2. **`rustdesk/flutter/windows/runner/Runner.rc`:**
   * Dòng 94: `VALUE "InternalName", "vynex" "\0"`
   * Dòng 96: `VALUE "OriginalFilename", "vynex.exe" "\0"`
3. **`rustdesk/flutter/windows/runner/main.cpp`:**
   * Dòng 83: `std::wstring app_name = L"Vynex";`
4. **Lưu ý sống còn về CMake Cache:**
   CMake trên Windows cache lại tên target rất chặt. Trước khi build lại bắt buộc phải xóa cache:
   ```powershell
   cd "D:\HKI 2026-2027\Seminar\seminar_rustdk\rustdesk\flutter"
   Remove-Item -Recurse -Force "build\windows\x64" -ErrorAction SilentlyContinue
   flutter build windows --release
   ```

---

## 3. VẤN ĐỀ 3: KHẮC PHỤC LỖI "MÁY ẢO UBUNTU BÁO MÁY WINDOWS NGOẠI TUYẾN"

### Hiện tượng
Windows kết nối sang Ubuntu (bằng cách vượt quyền) thì thành công. Nhưng khi kết nối chiều ngược lại (Ubuntu -> Windows) thì Ubuntu báo máy Windows đang "Ngoại tuyến" (Offline).

### Nguyên nhân cốt lõi phát hiện từ tiến trình thực tế:
1. **Tiến trình khởi động có tham số CLI:**
   Tiến trình Windows được chạy với: `vynex.exe --token vynex_token_dev_bypass_all`.
   Trong mã nguồn Rust Core (`rustdesk/src/core_main.rs` dòng 207-218):
   ```rust
   if args.is_empty() || crate::common::is_empty_uni_link(&args[0]) {
       std::thread::spawn(move || crate::start_server(false, no_server));
   }
   ```
   RustDesk quy định: **Chỉ khi `args` rỗng (mở app thông thường)** thì mới chạy tiến trình nền `start_server` để lắng nghe kết nối đến và gửi gói tin nhịp tim (UDP keepalive) lên `hbbs`. Khi có tham số `--token`, `start_server` **bị bỏ qua**, máy Windows không hề đăng ký với `hbbs` -> Ubuntu hỏi `hbbs` thì server trả về "Ngoại tuyến".
2. **Xung đột Windows Portproxy:**
   Lệnh `netsh interface portproxy` trước đó đã chiếm cổng `21116` trỏ về IP WSL2 cũ. Portproxy của Windows chỉ hỗ trợ TCP, không hỗ trợ UDP trong khi RustDesk bắt buộc dùng UDP 21116 để giữ trạng thái Online.

### Cách xử lý:
1. Reset portproxy trên Windows: `netsh interface portproxy reset`.
2. Không chạy app kèm `--token` nữa mà dùng bypass ở Backend `api/main.py`. Mở `vynex.exe` trực tiếp không tham số để `start_server` hoạt động bình thường.

---

## 4. VẤN ĐỀ 4: ĐỊNH HƯỚNG KIẾN TRÚC WIREGUARD VPN BẢO VỆ CLIENT THEO YÊU CẦU GIẢNG VIÊN

### Yêu cầu của Giảng viên hướng dẫn:
* Không sử dụng Web Dashboard (yêu cầu app native -> Nhóm đã làm `vynex_manager.exe`).
* **Các Client (máy nhân viên và máy IT) cũng phải được VPN bảo vệ**, không chỉ riêng mỗi tài khoản Admin.

### Cơ sở khoa học & Kiến trúc đề xuất:
* **Lý do của Thầy:** Nếu để Client kết nối tự do qua Internet thông thường tới RustDesk Server, bắt buộc phải mở các cổng 21115, 21116, 21117 ra toàn bộ Internet -> Nguy cơ bị scan IP, tấn công dò mật khẩu và DDoS.
* **Mô hình Remote Access VPN (Site-to-Client):**
  * Toàn bộ máy Client (IT Support tại chi nhánh B, nhân viên tại chi nhánh A, C) đều cài WireGuard Client và nhận một cấu hình riêng (`peer1.conf` đến `peer20.conf`).
  * Tất cả cùng kết nối về VPS Server trung tâm qua cổng duy nhất `51820/UDP`.
  * Các cổng RustDesk (`hbbs`, `hbbr`) và Backend API (`8000`) trên VPS **đóng kín 100% với Internet**, chỉ lắng nghe trên giao diện mạng VPN `10.13.13.1`.
  * Luồng điều khiển Remote Desktop được mã hóa 2 lớp: Lớp 1 bởi WireGuard (ChaCha20-Poly1305) và Lớp 2 bởi RustDesk Core (NaCl/Ed25519).

---

## 5. VẤN ĐỀ 5: HƯỚNG DẪN TRIỂN KHAI THỰC TẾ TOÀN BỘ HỆ THỐNG LÊN VPS SERVER

### Thông số máy chủ VPS:
* Hệ điều hành: `Ubuntu 22.04 LTS` hoặc `24.04 LTS`.
* Cấu hình đề xuất: 1-2 vCPU, 2GB RAM, 20GB SSD. IP Public giả định: `203.0.113.88`.

### Các bước triển khai:
1. **Cài đặt Docker trên VPS:**
   ```bash
   sudo apt update && sudo apt install -y curl ufw
   curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh
   ```
2. **File cấu hình `compose.yml` trên VPS:**
   ```yaml
   services:
     wireguard:
       image: linuxserver/wireguard:latest
       container_name: vynex-wireguard
       cap_add:
         - NET_ADMIN
         - SYS_MODULE
       environment:
         - PUID=1000
         - PGID=1000
         - TZ=Asia/Ho_Chi_Minh
         - SERVERURL=203.0.113.88     # Thay bằng IP Public của VPS
         - SERVERPORT=51820
         - PEERS=20                  # Tự động sinh 20 profiles cho 20 nhân viên
         - PEERDNS=auto
         - INTERNAL_SUBNET=10.13.13.0/24
       volumes:
         - ./wireguard-config:/config
         - /lib/modules:/lib/modules
       ports:
         - "51820:51820/udp"         # CỔNG DUY NHẤT MỞ RA INTERNET
       sysctls:
         - net.ipv4.conf.all.src_valid_mark=1
       restart: unless-stopped
       networks:
         rustdesk-net:
           ipv4_address: 10.13.13.1

     hbbs:
       container_name: vynex-hbbs
       image: rustdesk/rustdesk-server:latest
       command: hbbs -r 10.13.13.1:21117
       volumes:
         - ./data:/root
       restart: unless-stopped
       depends_on:
         - wireguard
         - hbbr
       network_mode: "service:wireguard"  # Dùng chung network stack của WireGuard

     hbbr:
       container_name: vynex-hbbr
       image: rustdesk/rustdesk-server:latest
       command: hbbr
       volumes:
         - ./data:/root
       restart: unless-stopped
       depends_on:
         - wireguard
       network_mode: "service:wireguard"

   networks:
     rustdesk-net:
       driver: bridge
       ipam:
         config:
           - subnet: 10.13.13.0/24
   ```
3. **Cấu hình Firewall (UFW):**
   ```bash
   sudo ufw allow 22/tcp       # SSH quản trị
   sudo ufw allow 51820/udp    # Duy nhất cổng WireGuard
   sudo ufw enable
   docker compose up -d
   ```
4. **Phân phối chứng chỉ:**
   * Tải các file `.conf` trong `./wireguard-config/` về (`peer1.conf` -> `peer20.conf`).
   * Giao cho IT và các nhân viên import vào ứng dụng WireGuard Client trên máy tính cá nhân.

---

## 6. VẤN ĐỀ 6: THIẾT LẬP THỰC TẾ & KIỂM CHỨNG DỮ LIỆU MÃ HÓA QUA WIREGUARD VPN

### Kiểm tra kết nối VPN từ máy Ubuntu:
* Chạy VPN: `sudo wg-quick up wg0`
* Ping kiểm tra Gateway: `ping 10.13.13.1` -> Phản hồi thành công `time=1.74 ms`.
* Kiểm tra bắt tay: `sudo wg show`:
  ```text
  endpoint: 192.168.106.1:51820
  latest handshake: 18 seconds ago
  transfer: 476 B received, 564 B sent
  ```
  => Bắt tay thành công 100%.

### Phương pháp kiểm chứng "Dữ liệu thực sự được bảo vệ qua VPN":
1. Trước khi kết nối điều khiển, gõ `sudo wg show` ghi lại lượng `transfer`.
2. Mở phiên Remote Desktop điều khiển màn hình (di chuột, mở video, lướt web).
3. Gõ lại `sudo wg show`:
   * **Nếu qua VPN:** Lượng `transfer` lập tức nhảy vọt lên **hàng Megabytes (MiB received / MiB sent)** theo dữ liệu hình ảnh truyền tải.
   * **Nếu không qua VPN:** Lượng `transfer` đứng yên ở mức vài trăm bytes.
4. Thử ngắt VPN (`sudo wg-quick down wg0`): Toàn bộ phiên Remote Desktop lập tức bị đứt kết nối và báo Offline.

---

## 7. VẤN ĐỀ 7: XỬ LÝ LỖI "BỊ CHẶN QUYỀN" & "KHÔNG THỂ KẾT NỐI MÁY CHỦ CHUYỂN TIẾP (RELAY)"

### 1. Lỗi "Bị chặn quyền" khi bấm Connect:
* **Nguyên nhân:** Tiến trình Backend FastAPI (`uvicorn`) trên cổng 8000 bị tắt. Chốt chặn bảo mật Zero-Trust trong `vynex_permission_guard.dart` không kết nối được tới `http://localhost:8000` nên kích hoạt Fail-Safe tự động từ chối kết nối.
* **Khắc phục:** Khởi động Backend API:
  ```powershell
  cd "D:\HKI 2026-2027\Seminar\seminar_rustdk\api"
  .\.venv-new\Scripts\Activate.ps1
  uvicorn main:app --host 0.0.0.0 --port 8000
  ```

### 2. Lỗi "Không thể kết nối máy chủ chuyển tiếp" (Relay Server):
* **Hiện tượng:** Cả 2 máy Windows và Ubuntu đều hiện **Chấm Xanh (Ready)**, nhưng khi bấm Connect thì báo lỗi không kết nối được máy chủ chuyển tiếp.
* **Nguyên nhân:**
  * Kiểm tra socket bằng `netstat` phát hiện gói tin: `TCP 192.168.1.2 -> 10.13.13.1:21117 SYN_SENT`.
  * Trong `server/compose.yml`, cờ chạy `hbbs` được khai báo là: `-r 10.13.13.1:21117`.
  * Khi cần Relay, `hbbs` bảo máy Windows tìm đến `10.13.13.1:21117`. Nhưng do máy Windows là host đứng ngoài dải VPN, Windows không định tuyến được vào `10.13.13.1`, dẫn đến timeout gói tin.
* **Khắc phục triệt để:**
  * Sửa lệnh khởi động `hbbs` trong `server/compose.yml` thành:
    `command: hbbs -r 192.168.106.1:21117`
  * Tái khởi động container `hbbs`:
    ```powershell
    cd "D:\HKI 2026-2027\Seminar\seminar_rustdk\server"
    docker compose up -d --force-recreate hbbs
    ```
  * Địa chỉ `192.168.106.1:21117` là cổng gateway chung mà cả Windows và Ubuntu đều truy cập được, lỗi lập tức biến mất!

---

## 8. TỔNG KẾT: PHÂN BIỆT BẢN CHẤT GIỮA MÔI TRƯỜNG LAB VÀ MÔI TRƯỜNG VPS PRODUCTION

| Đặc điểm | Môi trường Thử nghiệm Lab (Hiện tại) | Môi trường Triển khai Thực tế (VPS) |
| :--- | :--- | :--- |
| **Vị trí Server** | Chạy Docker ngay trên máy Windows cá nhân. | Chạy Docker trên máy chủ Cloud/VPS riêng biệt có IP Public. |
| **Vai trò máy Windows** | Vừa là Server (Docker), vừa là Client sử dụng. | Là máy Client độc lập của nhân viên IT (tại nhà/trụ sở B). |
| **Vai trò máy Ubuntu** | Là máy ảo VMware trên cùng máy tính vật lý. | Là máy Client độc lập của nhân viên (tại trụ sở A/C). |
| **Hiện tượng Loopback** | Có nguy cơ bị xung đột cổng `51820` và Docker Hairpin NAT. | **Không bao giờ xảy ra** vì tất cả là máy độc lập trên Internet. |
| **Cấu hình Relay `hbbs -r`** | Dùng IP chung `192.168.106.1:21117` để máy host kết nối được. | Dùng IP VPN `10.13.13.1:21117` vì mọi Client đều đã bật WireGuard. |
| **Bảo mật mạng** | Cổng Docker được bind phục vụ kiểm thử. | Toàn bộ cổng đóng kín khỏi Internet; duy nhất `51820/UDP` được mở. |

---
*Tài liệu được tổng hợp tự động để phục vụ báo cáo seminar, chuyển giao ngữ cảnh và triển khai đồ án.*
