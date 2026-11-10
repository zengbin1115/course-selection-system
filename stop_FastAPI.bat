@echo off
chcp 65001 >nul

echo =========================================
echo    正在強制關閉 FastAPI 伺服器...
echo =========================================

:: 透過 netstat 尋找佔用 8000 port 的進程 PID，並用 taskkill 強制終止
for /f "tokens=5" %%a in ('netstat -aon ^| findstr ":8000 "') do (
    echo [執行中] 發現伺服器 (PID: %%a)，正在執行關閉程序...
    taskkill /f /pid %%a >nul 2>&1
    echo ✅ 伺服器已成功關閉！
    echo =========================================
    pause
    exit
)

echo ⚠️ 找不到正在運作的伺服器 (Port 8000 目前是空的)。
echo =========================================
pause