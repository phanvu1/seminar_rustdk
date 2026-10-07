# ============================================================
# Script: update-portproxy.ps1
# Mục đích: Tự động cập nhật port proxy khi IP WSL2 thay đổi
# Cách dùng: Chạy PowerShell với quyền Administrator
#           .\update-portproxy.ps1
# ============================================================

# Kiểm tra quyền Admin
if (-NOT ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Vui long chay script voi quyen Administrator!" -ForegroundColor Red
    Write-Host "Chuot phai PowerShell -> Run as administrator" -ForegroundColor Yellow
    pause
    exit
}

Write-Host "=== Cap nhat RustDesk Port Proxy ===" -ForegroundColor Cyan

# Bước 1: Lấy IP WSL2 (IP đầu tiên, bỏ qua Docker bridge)
Write-Host "`n[1/4] Dang lay IP WSL2..." -ForegroundColor Yellow
$wslIps = (wsl hostname -I).Trim() -split '\s+'
$wslIp = $wslIps[0]
Write-Host "      IP WSL2: $wslIp" -ForegroundColor Green

# Bước 2: Xóa port proxy cũ
Write-Host "`n[2/4] Xoa port proxy cu..." -ForegroundColor Yellow
netsh interface portproxy reset | Out-Null
Write-Host "      Da xoa" -ForegroundColor Green

# Bước 3: Tạo port proxy mới cho 5 cổng
Write-Host "`n[3/4] Tao port proxy moi..." -ForegroundColor Yellow
$ports = @(21115, 21116, 21117, 21118, 21119)

foreach ($port in $ports) {
    netsh interface portproxy add v4tov4 `
        listenport=$port `
        listenaddress=0.0.0.0 `
        connectport=$port `
        connectaddress=$wslIp | Out-Null
    Write-Host "      Port $port -> $wslIp" -ForegroundColor Green
}

# Bước 4: Kiểm tra
Write-Host "`n[4/4] Kiem tra ket qua..." -ForegroundColor Yellow
netsh interface portproxy show all

Write-Host "`n=== HOAN THANH ===" -ForegroundColor Cyan
Write-Host "IP WSL2 hien tai: $wslIp" -ForegroundColor Green
Write-Host "Neu IP thay doi, chay lai script nay." -ForegroundColor Yellow