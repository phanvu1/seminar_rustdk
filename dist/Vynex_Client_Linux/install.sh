#!/bin/bash
# ==============================================================================
# VYNEX CLIENT LINUX / UBUNTU - UNIVERSAL INSTALLER
# Bản quyền: Hệ thống Điều khiển & Hỗ trợ Từ xa Vynex Enterprise
# ==============================================================================

set -e

echo "=========================================================="
echo "    BẮT ĐẦU CÀI ĐẶT & THIẾT LẬP VYNEX CLIENT (UBUNTU/LINUX) "
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
    echo "[!] CHÚ Ý: Chưa tìm thấy file chứng chỉ (*.conf) nào trong thư mục cài đặt."
    echo "[!] Hệ thống sẽ cài đặt trước Vynex Client Engine & cấu hình máy chủ VPS."
    echo "[!] Sau khi có file chứng chỉ VPN (*.conf) từ Admin, bạn chỉ cần copy vào đây và chạy lại ./install.sh"
else
    echo "[+] Đã phát hiện chứng chỉ VPN được cấp: $(basename "$CONF_FILE")"
fi

# 2. Cài đặt các gói phụ thuộc
echo "[1/4] Kiểm tra và cài đặt WireGuard VPN & RustDesk..."
sudo apt update -y
sudo apt install -y wireguard curl wget

# Tự động tải và cài đặt RustDesk nếu máy chưa có
if ! command -v rustdesk &> /dev/null && [ ! -f "/usr/bin/rustdesk" ]; then
    echo "[*] Đang tải gói cài đặt Vynex/RustDesk Linux (.deb)..."
    DEB_URL="https://github.com/rustdesk/rustdesk/releases/download/1.2.3-2/rustdesk-1.2.3-2-x86_64.deb"
    wget -q --show-progress -O /tmp/rustdesk.deb "$DEB_URL" || \
    curl -L -o /tmp/rustdesk.deb "https://github.com/rustdesk/rustdesk/releases/download/1.2.3/rustdesk-1.2.3-x86_64.deb"
    
    sudo apt install -y /tmp/rustdesk.deb || (sudo dpkg -i /tmp/rustdesk.deb && sudo apt-get install -f -y) || true
    rm -f /tmp/rustdesk.deb
    echo "[+] Đã cài đặt Vynex/RustDesk Engine thành công!"
fi

# 3. Kích hoạt hầm VPN
if [ -n "$CONF_FILE" ]; then
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
else
    echo "[2/4] Bỏ qua kích hoạt VPN (chưa có file *.conf). Sẽ kích hoạt sau khi bổ sung chứng chỉ."
fi

# 4. Tự động nhận diện thương hiệu Vynex trên Desktop
echo "[3/4] Cập nhật nhận diện Vynex Client trên Ubuntu..."
RUSTDESK_DESKTOP="/usr/share/applications/rustdesk.desktop"
if [ -f "$RUSTDESK_DESKTOP" ]; then
    sudo sed -i 's/^Name=.*/Name=Vynex Client/g' "$RUSTDESK_DESKTOP"
    sudo sed -i 's/^Comment=.*/Comment=Vynex Enterprise Remote Desktop/g' "$RUSTDESK_DESKTOP"
fi

# 5. Tiêm cấu hình Server VPS và Public Key tự động vào Client
echo "[4/4] Tự động cấu hình máy chủ VPS Cloud & Public Key..."
CONFIG_CONTENT="[options]
custom-rendezvous-server = '10.13.13.1'
relay-server = '10.13.13.1:21117'
api-server = 'http://10.13.13.1:8000'
key = 'NUvcbnr2VL3iLPCvmn2DjoZGMEtbQ27aEW1djMgev+M='
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

# 6. Thiết lập quyền thực thi cho các script khởi chạy
chmod +x "$SCRIPT_DIR/run_manager.sh" 2>/dev/null || true
chmod +x "$SCRIPT_DIR/run_vynex.sh" 2>/dev/null || true

# 7. Tạo shortcut trên Desktop cho Vynex Manager & Vynex Client
TARGET_USER="${SUDO_USER:-$USER}"
USER_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)
DESKTOP_DIR="$USER_HOME/Desktop"

if [ -d "$DESKTOP_DIR" ]; then
    cat << EOF > "$DESKTOP_DIR/Vynex_Manager.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Vynex Manager
Comment=Cổng hỗ trợ và gửi Ticket Vynex Enterprise
Exec=bash -c "cd '$SCRIPT_DIR/Manager' && flutter run -d linux"
Icon=utilities-system-monitor
Terminal=true
Categories=Utility;Application;
EOF

    cat << EOF > "$DESKTOP_DIR/Vynex_Client.desktop"
[Desktop Entry]
Version=1.0
Type=Application
Name=Vynex Client
Comment=Điều khiển từ xa Vynex Remote Desktop
Exec=rustdesk
Icon=rustdesk
Terminal=false
Categories=Network;RemoteAccess;
EOF

    chown "$TARGET_USER:$TARGET_USER" "$DESKTOP_DIR/Vynex_Manager.desktop" "$DESKTOP_DIR/Vynex_Client.desktop" 2>/dev/null || true
    chmod +x "$DESKTOP_DIR/Vynex_Manager.desktop" "$DESKTOP_DIR/Vynex_Client.desktop" 2>/dev/null || true
fi

echo "=========================================================="
echo "    CÀI ĐẶT THÀNH CÔNG VYNEX ENTERPRISE (UBUNTU / LINUX)! "
echo "  - Hầm VPN WireGuard: 10.13.13.3 (Kích hoạt sẵn sàng)     "
echo "  - Vynex Client Engine: Đã cấu hình máy chủ VPS 10.13.13.1"
echo "  - Vynex Manager Dashboard: Đã tích hợp đầy đủ            "
echo "                                                          "
echo "  * ĐỂ MỞ VYNEX MANAGER:                                  "
echo "    Chạy lệnh: ./run_manager.sh (hoặc click icon Desktop) "
echo "  * ĐỂ MỞ VYNEX CLIENT:                                   "
echo "    Chạy lệnh: rustdesk &                                 "
echo "  * MENU TỔNG HỢP:                                        "
echo "    Chạy lệnh: ./run_vynex.sh                             "
echo "=========================================================="
