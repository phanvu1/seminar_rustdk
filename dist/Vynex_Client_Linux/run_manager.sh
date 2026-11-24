#!/bin/bash
# ==============================================================================
# KHỞI CHẠY VYNEX MANAGER - GIAO DIỆN NHÂN VIÊN & QUẢN TRỊ (LINUX)
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MANAGER_DIR="$SCRIPT_DIR/Manager"

echo "=========================================================="
echo "    KHỞI CHẠY VYNEX MANAGER DASHBOARD (UBUNTU / LINUX)    "
echo "=========================================================="

# Kiểm tra Flutter đã cài đặt chưa
if ! command -v flutter &> /dev/null; then
    echo "[*] Chưa phát hiện Flutter SDK trên máy. Đang cài đặt nhanh qua snap..."
    sudo snap install flutter --classic
    sudo apt update -y && sudo apt install -y clang cmake ninja-build pkg-config libgtk-3-dev
fi

cd "$MANAGER_DIR"

echo "[*] Đang nạp gói phụ thuộc Flutter..."
flutter pub get

echo "[*] Đang khởi chạy ứng dụng Vynex Manager..."
flutter run -d linux
