@echo off
title TẮT BACKEND CHOUX CHIN F&B
chcp 65001 >nul
echo ====================================================================
echo   ĐANG DỪNG TIẾN TRÌNH BACKEND SPRING BOOT (PORT 8085)...
echo ====================================================================

:: Dừng tiến trình chiếm cổng 8085
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8085') do (
    taskkill /F /PID %%a >nul 2>&1
)
taskkill /F /IM java.exe >nul 2>&1
taskkill /F /IM javaw.exe >nul 2>&1

echo [V] Đã tắt sạch Backend Spring Boot (Cổng 8085).
echo.
echo ====================================================================
echo   BẠN CÓ MUỐN TẮT LUÔN BACKEND APP QUẢN LÝ & KDS (CỔNG 3000)?
echo ====================================================================
set /p opt="Nhập Y để tắt cổng 3000, hoặc bấm Enter để giữ nguyên: "
if /i "%opt%"=="Y" (
    for /f "tokens=5" %%b in ('netstat -aon ^| findstr :3000') do (
        taskkill /F /PID %%b >nul 2>&1
    )
    echo [V] Đã tắt Backend Node.js cổng 3000.
)

echo.
echo Hoàn tất! Bấm phím bất kỳ để đóng cửa sổ.
pause >nul
