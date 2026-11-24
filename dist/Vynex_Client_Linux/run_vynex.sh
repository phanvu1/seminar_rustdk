#!/bin/bash
# ==============================================================================
# VYNEX ENTERPRISE LINUX LAUNCHER
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================================="
echo "       HỆ THỐNG ĐIỀU KHIỂN & HỖ TRỢ TỪ XA VYNEX (LINUX)   "
echo "=========================================================="
echo ""
echo "  [1] Mở Vynex Manager (Giao diện Nhân viên / Gửi Ticket hỗ trợ)"
echo "  [2] Mở Vynex Client (Engine nhận điều khiển từ xa IT)"
echo "  [3] Cài đặt tự động & Kích hoạt VPN WireGuard (install.sh)"
echo ""
echo "=========================================================="
read -p "Nhập lựa chọn của bạn [1, 2 hoặc 3] (Mặc định: 1): " choice
choice=${choice:-1}

case "$choice" in
    2)
        echo "[*] Đang khởi động Vynex Client Engine..."
        rustdesk &
        ;;
    3)
        chmod +x "$SCRIPT_DIR/install.sh"
        sudo "$SCRIPT_DIR/install.sh"
        ;;
    *)
        chmod +x "$SCRIPT_DIR/run_manager.sh"
        "$SCRIPT_DIR/run_manager.sh"
        ;;
esac
