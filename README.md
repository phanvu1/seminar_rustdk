# RustDesk Việt Hóa & Triển Khai Server Riêng

> **Đồ án Seminar – Tuần 1**  
> Nhiệm vụ: Tải mã nguồn, tìm hiểu cấu trúc RustDesk và triển khai RustDesk Server trên Docker Desktop.

---

## 📌 Tổng quan

Trong tuần 1, nhóm tập trung vào việc tiếp cận mã nguồn **RustDesk**, tìm hiểu cấu trúc dự án, xác định các thành phần công nghệ chính và bước đầu triển khai hệ thống RustDesk Server bằng Docker Desktop.

### 🎯 Mốc bàn giao tuần 1

> **Kết nối thành công 2 máy thông qua RustDesk Server riêng.**

Kết quả cuối tuần: **Đã kết nối 2 máy thành công.** ✅

---

## 1. 📥 Tải mã nguồn RustDesk

Mã nguồn được lấy trực tiếp từ repository chính thức của RustDesk:

```bash
git clone https://github.com/rustdesk/rustdesk.git
```

Sau khi clone, nhóm tiến hành khảo sát cấu trúc source code để xác định vị trí của giao diện người dùng, tài nguyên ngôn ngữ và các thành phần phục vụ build.

---

## 2. 🏗️ Thành phần & công nghệ

| Thành phần | Công nghệ |
|---|---|
| Ngôn ngữ chính | **Rust** |
| Giao diện cũ | **Rust + Sciter** |
| Giao diện mới | **Flutter / Dart** |
| Build system cho Rust | **Cargo** |
| Build system cho UI mới | **Flutter SDK** |

### 📂 Các thư mục quan trọng

#### Giao diện người dùng

- `src/ui/` — giao diện cũ, sử dụng **Sciter**
- `flutter/lib/` — giao diện mới, sử dụng **Flutter**

#### Tài nguyên ngôn ngữ

```text
src/lang/
```

Đây là vị trí tài nguyên ngôn ngữ/bản dịch của giao diện cũ.

#### Build trên Windows

Hướng dẫn build trên Windows được tham khảo trong:

```text
Readme.md
```

của repository RustDesk.

---

## 3. 🎨 Các chức năng dự kiến tùy biến

Dựa trên định hướng của đồ án Seminar, nhóm dự kiến tùy biến một số thành phần của RustDesk:

| STT | Chức năng dự kiến tùy biến | Mục đích |
|---:|---|---|
| 1 | 🇻🇳 Giao diện tiếng Việt hoàn chỉnh tương tự AnyDesk | Phục vụ người dùng Việt |
| 2 | 🖥️ Màn hình cấu hình server riêng mặc định | Phục vụ việc triển khai server riêng |
| 3 | 🏷️ Logo và tên thương hiệu riêng | Phù hợp với đồ án Seminar |
| 4 | 🔐 Tích hợp VPN bảo mật | Tăng cường bảo mật kết nối |
| 5 | 🧹 Ẩn các tính năng không sử dụng | Đơn giản hóa giao diện cho doanh nghiệp |

> **Lưu ý:** Đây là các chức năng **dự kiến tùy biến**, chưa phải toàn bộ các chức năng đã hoàn thành trong tuần 1.

---

## 4. 🐳 Triển khai RustDesk Server

Trong quá trình triển khai, nhóm đã thành công chạy được hai container quan trọng của RustDesk Server:

```text
hbbs
hbbr
```

### Vai trò

- **hbbs** — RustDesk ID / rendezvous server.
- **hbbr** — RustDesk relay server.

Việc triển khai được thực hiện trên **Docker Desktop**.
![alt text](image.png)
---

## 5. ⚠️ Khó khăn gặp phải

### Mô hình mạng ban đầu

Trong quá trình thử nghiệm, nhóm gặp vấn đề khi cho máy ảo VMware kết nối đến RustDesk Server đang chạy trong WSL2 thông qua Docker Desktop.

Mô hình mạng phát sinh nhiều lớp NAT:

```text
VMware VM
   │
   │ VMware NAT
   ▼
Windows Host
   │
   │ WSL2 NAT
   ▼
WSL2
   │
   │ Docker NAT
   ▼
Docker Container
   │
   ├── hbbs
   └── hbbr
```

Cụ thể:

```text
VMware VM: 192.168.106.x
        ↓
Windows Host
        ↓
WSL2: 172.x.x.x
        ↓
Docker Container
```

### Nguyên nhân

Docker Desktop không tự động mở các port của container để các máy trong mạng/LAN hoặc máy ảo VMware có thể truy cập trực tiếp theo mô hình triển khai trên.

Do đó:

> **VMware VM không thể trực tiếp kết nối đến RustDesk Server đang chạy trong WSL2/Docker.**

---

## 6. 🔧 Cách khắc phục

Nhóm đã thực hiện cấu hình lại `compose.yml`, đồng thời mở các port cần thiết trên Windows Firewall.

### 6.1. Mở port Windows Firewall

Đối với **hbbs**:

```powershell
New-NetFirewallRule -DisplayName "RustDesk hbbs" `
-Direction Inbound `
-Protocol TCP `
-LocalPort <các port> `
-Action Allow
```

Đối với **hbbr**:

```powershell
New-NetFirewallRule -DisplayName "RustDesk hbbr" `
-Direction Inbound `
-Protocol TCP `
-LocalPort <các port> `
-Action Allow
```

Việc cấu hình Firewall cho phép VMware VM và các máy trong LAN truy cập vào các port cần thiết của RustDesk Server.

---

### 6.2. Thiết lập Port Proxy

Nhóm sử dụng `netsh interface portproxy` để chuyển tiếp port từ Windows Host đến địa chỉ IP của WSL2:

```powershell
netsh interface portproxy add v4tov4 `
listenport=<port> `
listenaddress=0.0.0.0 `
connectport=<port> `
connectaddress=<WSL_IP>
```

Mô hình sau khi cấu hình:

```text
VMware VM / LAN
       │
       ▼
Windows Host
       │
       │ Port Proxy
       ▼
WSL2
       │
       ▼
Docker
       │
       ├── hbbs
       └── hbbr
```

---

## 7. ✅ Kết quả tuần 1

### Checklist

- [x] Clone mã nguồn RustDesk
- [x] Tìm hiểu ngôn ngữ và công nghệ sử dụng
- [x] Tìm hiểu cấu trúc giao diện RustDesk
- [x] Xác định vị trí tài nguyên ngôn ngữ
- [x] Tìm hiểu hướng dẫn build trên Windows
- [x] Xác định các chức năng dự kiến tùy biến
- [x] Triển khai container `hbbs`
- [x] Triển khai container `hbbr`
- [x] Xử lý vấn đề kết nối giữa VMware → WSL2 → Docker
- [x] Cấu hình Windows Firewall
- [x] Cấu hình `netsh portproxy`
- [x] **Kết nối thành công 2 máy**

### 🟢 Trạng thái

**HOÀN THÀNH MỐC TUẦN 1**

> RustDesk Server đã được triển khai và hai máy đã kết nối thành công thông qua hệ thống server được cấu hình riêng.

---

## 8. 📊 Tiến độ

```text
Tải mã nguồn                 ████████████████████  100%
Tìm hiểu cấu trúc RustDesk   ████████████████████  100%
Triển khai hbbs              ████████████████████  100%
Triển khai hbbr              ████████████████████  100%
Xử lý kết nối mạng           ████████████████████  100%
Kết nối 2 máy                ████████████████████  100%
```

---

## 9. 🚀 Định hướng tiếp theo

Sau khi hoàn thành mốc kết nối 2 máy, nhóm có thể tiếp tục triển khai các nội dung theo phạm vi đồ án:

- Việt hóa giao diện RustDesk.
- Tùy biến logo và tên thương hiệu.
- Hoàn thiện màn hình cấu hình server riêng.
- Tiếp tục nghiên cứu cơ chế kết nối và relay của RustDesk.
- Nghiên cứu phương án bảo mật/VPN.
- Xác định và ẩn các tính năng không cần thiết.
- Tiếp tục kiểm thử hệ thống trong các mô hình mạng khác nhau.

---

## 👥 Thông tin dự án

**Tên đề tài:** Việt hóa và xây dựng công cụ Remote Access như AnyDesk từ RustDesk

**Môn học:** Seminar chuyên đề

**Nền tảng:** RustDesk

**Ngôn ngữ chính:** Rust

**UI:** Flutter / Dart, Sciter

**Server:** RustDesk `hbbs` / `hbbr`

**Container:** Docker

---

## 📝 Nhật ký tuần 1

| Hạng mục | Trạng thái |
|---|---|
| Khảo sát source code | ✅ Hoàn thành |
| Khảo sát công nghệ | ✅ Hoàn thành |
| Khảo sát UI | ✅ Hoàn thành |
| Docker `hbbs` | ✅ Hoàn thành |
| Docker `hbbr` | ✅ Hoàn thành |
| Xử lý NAT | ✅ Hoàn thành |
| Firewall | ✅ Hoàn thành |
| Port Proxy | ✅ Hoàn thành |
| Kết nối 2 máy | ✅ Thành công |

---

> **Cập nhật:** Tuần 1  
> **Trạng thái:** 🟢 Hoàn thành  
> **Mục tiêu quan trọng:** Kết nối thành công 2 máy qua RustDesk Server riêng.


---

---

## 10. 🛠️ Tuần 2: Build RustDesk Client gốc

> **Mốc bàn giao tuần 2:** Build thành công file `rustdesk.exe` từ mã nguồn trên Windows.

### 🎯 Mục tiêu tuần 2

- Cập nhật `compose.yml` có chú thích rõ ràng.
- Viết script tự động cập nhật port proxy.
- Xây dựng môi trường build hoàn chỉnh.
- **Build thành công RustDesk Client gốc.**

### ✅ Kết quả cuối tuần 2

> **Đã build thành công `rustdesk.exe` (release mode) sau khi vượt qua 5 lỗi lớn.**

---

### 10.1. 🧰 Cài đặt môi trường build

| Bước | Công cụ | Ghi chú |
|---|---|---|
| 1 | **Rust (rustup)** | Cài qua `rustup-init.exe`, chọn default |
| 2 | **Visual Studio Build Tools 2022** | Tick `Desktop development with C++`, `Windows 10/11 SDK`, `C++ CMake tools for Windows` (~5GB) |
| 3 | **LLVM** | Tải từ releases.llvm.org, **tick "Add LLVM to system PATH"** |
| 4 | **Flutter SDK** | Giải nén vào `D:\enviroment\flutter`, thêm vào System PATH |
| 5 | **vcpkg** | Clone về `D:\enviroment\vcpkg`, chạy `bootstrap-vcpkg.bat` |

**Cấu hình biến môi trường:**

```powershell
# Thêm vcpkg vào PATH
$machinePath = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
[System.Environment]::SetEnvironmentVariable('Path', "$machinePath;D:\enviroment\vcpkg", 'Machine')

# Trỏ tới libclang
setx LIBCLANG_PATH "D:\enviroment\LLVM\bin"

# Trỏ tới vcpkg root
setx VCPKG_ROOT "D:\enviroment\vcpkg"
```

> ⚠️ **Lưu ý:** Sau khi `setx`, phải đóng và mở lại PowerShell (hoặc khởi động lại máy) để biến môi trường có hiệu lực.

### 10.2. 📦 Cài đặt các thư viện C++ phụ trợ qua vcpkg

RustDesk cần một số thư viện C++ để xử lý video/audio. Mở PowerShell với quyền Administrator và chạy:

```powershell
cd D:\enviroment\vcpkg

# Cài các thư viện cho chế độ build tĩnh (static)
.\vcpkg install libvpx:x64-windows-static
.\vcpkg install opus:x64-windows-static
.\vcpkg install libyuv:x64-windows-static
.\vcpkg install aom:x64-windows-static

# Tích hợp vcpkg vào hệ thống
.\vcpkg integrate install
```

⏱️ **Thời gian:** Quá trình này có thể mất 1.5 – 2 giờ tùy cấu hình máy. Riêng `aom` mất khoảng 1.1 giờ vì phải biên dịch từ mã nguồn.

### 10.3. 🚀 Lệnh build chính thức

```powershell
cd "D:\HKI 2026-2027\Seminar\seminar_rustdk\rustdesk"

# Dọn dẹp cache cũ (nếu đã từng build lỗi)
cargo clean

# Build release KHÔNG dùng cờ --features "inline"
cargo build --release
```

**Kết quả thành công:**

```text
Finished `release` profile [optimized] target(s) in 1m 09s
```

**File thành phẩm nằm tại:**

```text
D:\HKI 2026-2027\Seminar\seminar_rustdk\rustdesk\target\release\rustdesk.exe
```

**Các file đi kèm quan trọng:**

- `rustdesk.exe` — Giao diện chính
- `service.exe` — Chạy ngầm dưới quyền SYSTEM
- `naming.exe` — Công cụ đặt tên thiết bị
- `librustdesk.dll` và các file `.dll` phụ trợ khác

### 10.4. ⚠️ Khó khăn gặp phải & Cách khắc phục

Quá trình build gặp 5 lỗi lớn liên tiếp, đòi hỏi phải xử lý từng bước:

#### 🔴 Lỗi 1: LNK1108: cannot write file at 0x0

**Triệu chứng:**

```text
error: linking with `link.exe` failed: exit code: 1108
fatal error LNK1108: cannot write file at 0x0
```

**Nguyên nhân:** Trình liên kết `link.exe` không ghi được file tạm, thường do:

- Ổ cứng đầy (thư mục `D:\cargo-target` rất ngốn dung lượng).
- Phần mềm diệt virus chặn file `.tmp`.
- Thư mục `%TEMP%` bị lỗi.

**Cách khắc phục:**

- Dọn dẹp ổ cứng, đảm bảo còn ít nhất 20GB trống.
- Tắt tạm thời Windows Defender hoặc thêm `D:\cargo-target` vào danh sách loại trừ.
- Xóa toàn bộ file trong `%TEMP%` (nhấn `Win+R` → gõ `%temp%` → Enter).
- Chạy `cargo clean` rồi build lại.

#### 🔴 Lỗi 2: Unable to find libclang

**Triệu chứng:**

```text
Unable to find libclang: "couldn't find any valid shared libraries matching:
['clang.dll', 'libclang.dll'], set the `LIBCLANG_PATH` environment variable..."
```

**Nguyên nhân:** Thư viện `bindgen` (dùng để chuyển C++ header sang Rust) cần `libclang` nhưng chưa tìm thấy.

**Cách khắc phục:**

- Tải LLVM từ releases.llvm.org.
- Cài đặt, tick chọn **Add LLVM to the system PATH**.
- Set biến môi trường:

```powershell
setx LIBCLANG_PATH "D:\enviroment\LLVM\bin"
```

- Khởi động lại máy hoặc đóng/mở PowerShell mới.
- Kiểm tra file `libclang.dll` có tồn tại trong `D:\enviroment\LLVM\bin` không.

#### 🔴 Lỗi 3: `vpx/vp8.h` file not found và `opus/opus_multistream.h` file not found

**Triệu chứng:**

```text
fatal error: 'vpx/vp8.h' file not found
fatal error: 'opus/opus_multistream.h' file not found
```

**Nguyên nhân:** Thiếu thư viện xử lý video (`libvpx`) và âm thanh (`opus`).

**Cách khắc phục:**

```powershell
cd D:\enviroment\vcpkg
.\vcpkg install libvpx:x64-windows-static
.\vcpkg install opus:x64-windows-static
.\vcpkg install libyuv:x64-windows-static
```

#### 🔴 Lỗi 4: `aom/aom.h` file not found

**Triệu chứng:**

```text
fatal error: 'aom/aom.h' file not found
panicked at libs\scrap\build.rs:161:18
```

**Nguyên nhân:** Thư viện `scrap` (chụp màn hình) cần codec AV1 (`aom`).

**Cách khắc phục:**

```powershell
cd D:\enviroment\vcpkg
.\vcpkg install aom:x64-windows-static
.\vcpkg integrate install
```

⏱️ **Lưu ý:** `aom` mất khoảng 1.1 giờ để build xong.

#### 🔴 Lỗi 5: file not found for module `inline`

**Triệu chứng:**

```text
error[E0583]: file not found for module `inline`
  --> src\ui.rs:21:1
   |
21 | pub mod inline;
   | ^^^^^^^^^^^^^^^
```

**Nguyên nhân:** Cờ `--features "inline"` yêu cầu module `inline` (dùng cho Web Client) mà mã nguồn tải về không có.

**Cách khắc phục:** Bỏ cờ `--features "inline"` trong lệnh build.

```powershell
# SAI
cargo build --release --features "inline"

# ĐÚNG
cargo build --release
```

### 10.5. 📋 Tổng kết hành trình xử lý lỗi

| # | Lỗi | Cách khắc phục | Trạng thái |
|---:|---|---|---|
| 1 | LNK1108 - `link.exe` | Dọn ổ cứng, tắt antivirus, xóa `%TEMP%` | ✅ |
| 2 | `libclang` not found | Cài LLVM + set `LIBCLANG_PATH` | ✅ |
| 3 | `vpx/opus` not found | `vcpkg install libvpx opus libyuv` | ✅ |
| 4 | `aom` not found | `vcpkg install aom` | ✅ |
| 5 | `inline` module not found | Bỏ cờ `inline` | ✅ |

### 🟢 Trạng thái tuần 2

> **HOÀN THÀNH MỐC TUẦN 2**

RustDesk Client đã được build thành công từ mã nguồn trên Windows, sẵn sàng cho giai đoạn tùy biến.

---

## 11. 📊 Tiến độ tổng thể

```text
Tuần 1:
Tải mã nguồn                 ████████████████████  100%
Triển khai hbbs/hbbr         ████████████████████  100%
Kết nối 2 máy                ████████████████████  100%

Tuần 2:
Cài môi trường build         ████████████████████  100%
Cài vcpkg + dependencies     ████████████████████  100%
Build rustdesk.exe           ████████████████████  100%
```
