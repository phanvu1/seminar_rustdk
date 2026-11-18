@echo off
chcp 65001 >nul
title Vynex Enterprise - Quản Trị & IT Support
echo ==========================================================
echo    KHỞI CHẠY VYNEX ENTERPRISE (DÀNH CHO ADMIN / KỸ THUẬT IT)
echo ==========================================================
echo.
set SCRIPT_DIR=%~dp0

echo [1/2] Đang kiểm tra tiến trình nền Vynex Client Engine...
tasklist /FI "IMAGENAME eq vynex.exe" 2>NUL | find /I /N "vynex.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [+] Vynex Client Engine đang chạy sẵn sàng!
) else (
    echo [*] Đang khởi động Vynex Client Engine...
    start "" "%SCRIPT_DIR%Client\vynex.exe"
)

echo.
echo [2/2] Đang mở Dashboard Quản Trị & Hỗ Trợ Vynex Manager...
start "" "%SCRIPT_DIR%Manager\vynex_manager.exe"

echo.
echo ==========================================================
echo    HỆ THỐNG QUẢN TRỊ ĐÃ SẴN SÀNG!
echo ==========================================================
timeout /t 3 >nul
exit
