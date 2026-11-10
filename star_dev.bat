@echo off
chcp 65001 >nul

echo =========================================
echo    🚀 正在啟動 CPAS 選課推薦系統 開發環境...
echo =========================================

:: 1. 啟動 Python FastAPI 伺服器 (Port 8000)
echo [1/3] 啟動 Python 伺服器 (Port 8000)...
start cmd /k "cd python_api && python -m uvicorn main:app --reload"

:: 2. 啟動 Laravel 後端伺服器 (Port 8001)
echo [2/3] 啟動 Laravel 伺服器 (Port 8001)...
start cmd /k "php artisan serve --port 8001"

:: 3. 啟動 Vue/Vite 前端熱更新
echo [3/3] 啟動 Vite 前端熱更新...
start cmd /k "npm run dev"

:: 稍微等待 5 秒，讓三個伺服器有時間啟動，避免瀏覽器太早打開找不到網頁
echo 正在等待伺服器暖機...
timeout /t 5 /nobreak >nul

:: 4. 自動打開瀏覽器並進入首頁
echo [完成] 正在開啟瀏覽器...
start http://localhost:8001/index

echo =========================================
echo    🎉 所有環境已啟動！祝你開發順利！
echo =========================================