@echo off
chcp 65001 >nul
echo ==========================================================
echo    KHỞI CHẠY HỆ THỐNG VYNEX ENTERPRISE (WINDOWS)
echo ==========================================================

set SCRIPT_DIR=%~dp0

echo [1/2] Đang kiểm tra tiến trình nền Vynex Client Engine...
tasklist /FI "IMAGENAME eq vynex.exe" 2>NUL | find /I /N "vynex.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [+] Vynex Client Engine đang chạy sẵn sàng!
) else (
    echo [*] Đang khởi động Vynex Client Engine chạy ngầm...
    start "" "%SCRIPT_DIR%Client\vynex.exe"
)

echo [2/2] Đang khởi động Vynex Management Dashboard...
start "" "%SCRIPT_DIR%Manager\vynex_manager.exe"

echo ==========================================================
echo    HỆ THỐNG ĐÃ SẴN SÀNG!
echo ==========================================================
exit

