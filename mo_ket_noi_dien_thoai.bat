@echo off
title CHOUXCHIN - MO CONG KET NOI DIEN THOAI VOI DATABASE LAPTOP
chcp 65001 > nul
echo =====================================================================
echo    CHOUXCHIN - KET NOI DIEN THOAI VOI DATABASE LAPTOP (PGADMIN 4)
echo =====================================================================
echo.
echo [1] Kiem tra Server Choux Chin tren cong 3000...
echo [2] Dang mo duong truyen HTTPS Cloudflare Tunnel...
echo.
echo Luu y: Giu nguyen cua so nay khi ban dang demo tren dien thoai!
echo.
"C:\Program Files (x86)\cloudflared\cloudflared.exe" tunnel --url http://localhost:3000
pause
