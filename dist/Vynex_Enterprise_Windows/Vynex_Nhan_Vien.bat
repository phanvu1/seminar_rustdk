@echo off
chcp 65001 >nul
title Vynex Enterprise Client - Máy Nhân Viên
echo ==========================================================
echo    KHỞI CHẠY VYNEX CLIENT (DÀNH CHO MÁY NHÂN VIÊN)
echo ==========================================================
echo.
echo [*] Đang khởi động Vynex Client Engine...
set SCRIPT_DIR=%~dp0
start "" "%SCRIPT_DIR%Client\vynex.exe"

echo.
echo [+] Vynex Client đã khởi chạy thành công!
echo [+] Vui lòng đọc ID và Mật khẩu trên cửa sổ Vynex cho Kỹ thuật viên IT
echo     để nhận hỗ trợ điều khiển từ xa.
echo ==========================================================
timeout /t 5 >nul
exit
