# ====================================================================
# CHOUX CHIN F&B - LAUNCHER CHO CHỦ QUÁN ĂN VẶT
# Tác giả: Nguyễn Huỳnh Anh Tuấn
# KẾT NỐI TRỰC TIẾP POSTGRESQL (milktea_pos_db)
# ====================================================================

$RootPath = "D:\Doantotnghiep"
$AppDir = Join-Path $RootPath "app_quanly_chouxchin_kiotviet"

# Hàm kiểm tra cổng mạng siêu tốc (< 50ms)
function Test-PortFast([int]$Port) {
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $iar = $client.BeginConnect("127.0.0.1", $Port, $null, $null)
        $connected = $iar.AsyncWaitHandle.WaitOne(250, $false)
        if ($connected -and $client.Connected) {
            $client.EndConnect($iar)
            $client.Close()
            return $true
        }
        $client.Close()
        return $false
    } catch {
        return $false
    }
}

# 1. Kiểm tra và khởi động Server Quản Lý Node.js (Port 3000)
$isNodeRunning = Test-PortFast 3000
if (-not $isNodeRunning) {
    $serverJs = Join-Path $AppDir "server.js"
    Start-Process -FilePath "node.exe" -ArgumentList "`"$serverJs`"" -WorkingDirectory $AppDir -WindowStyle Hidden
    
    # Đợi tối đa 4 giây cho server sẵn sàng
    for ($i = 0; $i -lt 20; $i++) {
        Start-Sleep -Milliseconds 200
        if (Test-PortFast 3000) { break }
    }
}

# 2. Kiểm tra và khởi động Backend Spring Boot (Port 8085 nếu cần)
$isBootRunning = Test-PortFast 8085
if (-not $isBootRunning) {
    $jarPath = Join-Path $RootPath "backend_springboot\target\backend_springboot-0.0.1-SNAPSHOT.jar"
    if (Test-Path $jarPath) {
        Start-Process -FilePath "javaw.exe" -ArgumentList "-jar", "`"$jarPath`"" -WorkingDirectory $RootPath
    }
}

# 3. Khởi động cửa sổ ứng dụng Native App Window (Chrome hoặc Edge)
$AppUrl = "http://localhost:3000/chouxchin/man/?v=20261105_1#/DashBoard"
$ChromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$EdgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

if (Test-Path $ChromePath) {
    Start-Process -FilePath $ChromePath -ArgumentList "--app=`"$AppUrl`"", "--window-size=1440,900"
} elseif (Test-Path $EdgePath) {
    Start-Process -FilePath $EdgePath -ArgumentList "--app=`"$AppUrl`"", "--window-size=1440,900"
} else {
    Start-Process $AppUrl
}
