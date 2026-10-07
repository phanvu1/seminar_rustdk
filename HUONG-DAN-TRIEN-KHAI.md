# Hướng dẫn triển khai RustDesk Server

## Yêu cầu
- Windows 11
- Docker Desktop (đã bật WSL2 Integration)
- Quyền Administrator

## Các bước triển khai

### Bước 1: Khởi động server
```powershell
cd D:\rustdesk-server <vị trí thư mục lưu git của bạn>
docker compose up -d
docker compose ps
### Bước 2: Cập nhật proxy
cd D:\rustdesk-server\scripts
.\update-portproxy.ps1
### Bước 3: Lấy public key
xem trong logs của docker desktop ở hbbs có phần key
### Bước 4: Cấu hình client
mở rustdk vào phần setting -> network -> câu hình 
ID Server: <IP_Windows_VMnet8>:21116
Relay Server: <IP_Windows_VMnet8>:21117
Key: <public key ở bước 3>
![alt text](image-1.png)