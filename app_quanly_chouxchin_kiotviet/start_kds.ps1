# ====================================================================
# CHOUX CHIN F&B - LAUNCHER MÀN HÌNH BẾP (KITCHEN DISPLAY SYSTEM)
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
    
    for ($i = 0; $i -lt 20; $i++) {
        Start-Sleep -Milliseconds 200
        if (Test-PortFast 3000) { break }
    }
}

# 2. Khởi động cửa sổ Màn hình Bếp KDS Native App Window
$KdsUrl = "http://localhost:3000/chouxchin/kds/"
$ChromePath = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$EdgePath = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

if (Test-Path $ChromePath) {
    Start-Process -FilePath $ChromePath -ArgumentList "--app=`"$KdsUrl`"", "--window-size=1280,720"
} elseif (Test-Path $EdgePath) {
    Start-Process -FilePath $EdgePath -ArgumentList "--app=`"$KdsUrl`"", "--window-size=1280,720"
} else {
    Start-Process $KdsUrl
}
