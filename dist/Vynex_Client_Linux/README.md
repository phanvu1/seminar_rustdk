# HƯỚNG DẪN CẤP PHÁT THIẾT BỊ CHO NHÂN VIÊN LINUX / UBUNTU

Thư mục `Vynex_Client_Linux` là **BỘ CÀI VẠN NĂNG (UNIVERSAL INSTALLER)** dùng chung cho toàn bộ nhân viên dùng Linux.
Nó hoàn toàn KHÔNG chứa bất kỳ file cấu hình VPN cố định nào bên trong.

### QUY TRÌNH CẤP PHÁT CHO NHÂN VIÊN MỚI:

1. Admin copy thư mục `Vynex_Client_Linux` vào USB (hoặc gửi file nén cho nhân viên).
2. Admin vào thư mục `Admin_VPN_Peers_Vault`, lấy **đúng 1 file cấu hình** của nhân viên đó (ví dụ: `peer2_Employee_Ubuntu.conf`), đổi tên thành `peer.conf` (hoặc giữ nguyên) và **thả vào cùng thư mục `Vynex_Client_Linux`**.
3. Cắm USB vào máy nhân viên Ubuntu, mở Terminal tại thư mục đó và gõ:
   ```bash
   chmod +x install.sh
   ./install.sh
   ```
4. **Kết quả:** Script tự động:
   - Phát hiện file `.conf` đặt cạnh nó.
   - Cài đặt và bật WireGuard kết nối tới VPS Cloud `34.87.182.49`.
   - Nạp cấu hình Server nội bộ `10.13.13.1` và Public Key `NUvcbnr2...`.
   - Mở app Vynex lên là hiện **Chấm xanh (Ready)** ngay lập tức!

