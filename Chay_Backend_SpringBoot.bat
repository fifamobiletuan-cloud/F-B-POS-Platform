@echo off
title CHOUX CHIN F&B - BACKEND SPRING BOOT (PORT 8085)
chcp 65001 >nul
cd /d "D:\Doantotnghiep\backend_springboot"
echo ====================================================================
echo   ĐANG KHỞI ĐỘNG BACKEND SPRING BOOT - CHOUX CHIN F^&B (PORT 8085)...
echo   CSDL: PostgreSQL (milktea_pos_db)
echo ====================================================================
java -jar target\backend_springboot-0.0.1-SNAPSHOT.jar
if %errorlevel% neq 0 (
    echo.
    echo Khong tim thay file jar hoac co loi, dang chay truc tiep bang Maven...
    mvn spring-boot:run
)
pause
