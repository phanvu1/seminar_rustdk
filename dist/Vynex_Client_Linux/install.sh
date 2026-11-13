#!/bin/bash
# ==============================================================================
# VYNEX CLIENT LINUX - UNIVERSAL INSTALLER (BỘ CÀI VẠN NĂNG)
# Bản quyền: Đồ án Vynex Enterprise Remote Desktop
# ==============================================================================

set -e

echo "=========================================================="
echo "    BẮT ĐẦU CÀI ĐẶT & THIẾT LẬP VYNEX CLIENT (LINUX)      "
echo "=========================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Tự động tìm kiếm file cấu hình WireGuard (*.conf) đặt cùng thư mục
CONF_FILE=""
for f in "$SCRIPT_DIR"/*.conf; do
    if [ -f "$f" ]; then
        CONF_FILE="$f"
        break
    fi
done

if [ -z "$CONF_FILE" ]; then
    echo "[-] CẢNH BÁO: Không tìm thấy file chứng chỉ (*.conf) nào trong thư mục cài đặt!"
    echo "[-] Vui lòng copy file do Admin cấp (ví dụ: peer2.conf) vào cùng thư mục này rồi chạy lại."
    exit 1
fi

echo "[+] Đã phát hiện chứng chỉ VPN được cấp: $(basename "$CONF_FILE")"

# 2. Cài đặt các gói phụ thuộc
echo "[1/4] Kiểm tra và cài đặt WireGuard VPN..."
sudo apt update -y
sudo apt install -y wireguard curl

# 3. Kích hoạt hầm VPN
echo "[2/4] Nạp chứng chỉ và kích hoạt hầm VPN bảo vệ..."
sudo mkdir -p /etc/wireguard
sudo cp "$CONF_FILE" /etc/wireguard/wg0.conf
sudo chmod 600 /etc/wireguard/wg0.conf

# Đảm bảo AllowedIPs định tuyến nội bộ để không mất mạng ngoài
sudo sed -i 's/AllowedIPs = 0.0.0.0\/0, ::\/0/AllowedIPs = 10.13.13.0\/24/g' /etc/wireguard/wg0.conf

sudo wg-quick down wg0 2>/dev/null || true
sudo wg-quick up wg0

echo "[*] Trạng thái bắt tay VPN:"
sudo wg show

# 4. Tự động nhận diện thương hiệu Vynex trên Desktop
echo "[3/4] Cập nhật nhận diện Vynex Client..."
RUSTDESK_DESKTOP="/usr/share/applications/rustdesk.desktop"
if [ -f "$RUSTDESK_DESKTOP" ]; then
    sudo sed -i 's/^Name=.*/Name=Vynex Client/g' "$RUSTDESK_DESKTOP"
    sudo sed -i 's/^Comment=.*/Comment=Vynex Enterprise Remote Desktop/g' "$RUSTDESK_DESKTOP"
fi

# 5. Tiêm cấu hình Server VPS và Public Key tự động vào Client
echo "[4/4] Tự động cấu hình máy chủ VPS Cloud & Public Key..."
CONFIG_CONTENT="[options]
custom-rendezvous-server = '10.13.13.1'
key = 'NUvcbnr2VL3iLPCvmn2DjoZGMEtbQ27aEW1djMgev+M='
relay-server = '10.13.13.1:21117'
api-server = ''
allow-auto-disconnect = 'N'
verification-method = 'both'"

# Áp dụng cho cấp hệ thống
sudo mkdir -p /etc/rustdesk
echo "$CONFIG_CONTENT" | sudo tee /etc/rustdesk/RustDesk2.toml > /dev/null

# Áp dụng cho user hiện tại
mkdir -p "$HOME/.config/rustdesk"
echo "$CONFIG_CONTENT" > "$HOME/.config/rustdesk/RustDesk2.toml"

# Khởi động lại service client
sudo systemctl restart rustdesk 2>/dev/null || true

echo "=========================================================="
echo "    CÀI ĐẶT THÀNH CÔNG VYNEX CLIENT CHO NHÂN VIÊN!       "
echo "  - Chứng chỉ đã nạp: $(basename "$CONF_FILE")            "
echo "  - Máy chủ kết nối: VPS Cloud 10.13.13.1                  "
echo "  - Phần mềm Vynex/RustDesk hiện đã sẵn sàng (Chấm xanh)   "
echo "=========================================================="

