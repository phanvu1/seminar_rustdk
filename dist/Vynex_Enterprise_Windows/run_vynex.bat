@echo off
chcp 65001 >nul
title Vynex Enterprise Launcher
echo ==========================================================
echo        HỆ THỐNG ĐIỀU KHIỂN ^& HỖ TRỢ TỪ XA VYNEX
echo ==========================================================
echo.
echo   [1] Máy NHÂN VIÊN (Chỉ mở Vynex Client để nhận hỗ trợ IT)
echo   [2] Máy QUẢN TRỊ / IT (Mở Bảng Điều Khiển Quản Trị ^& Hỗ Trợ)
echo.
echo ==========================================================
set choice=1
set /p choice="Nhập lựa chọn của bạn [1 hoặc 2] (Mặc định: 1): "

if "%choice%"=="2" (
    call "%~dp0Vynex_Quan_Tri_IT.bat"
) else (
    call "%~dp0Vynex_Nhan_Vien.bat"
)
exit
