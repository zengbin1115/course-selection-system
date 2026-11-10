@echo off
chcp 65001 >nul

echo =========================================
echo    正在啟動 選課推薦系統 開發環境...
echo =========================================

:: 1. 走進地下室並透過 python 呼叫 uvicorn
echo [1/2] 啟動 Python 伺服器...
start cmd /k "cd python_api && python -m uvicorn main:app --reload"

:: 2. 自動打開瀏覽器並進入上傳畫面
echo [2/2] 開啟瀏覽器...
start http://course_select.test/cpas/首頁0607

echo 完成！祝你開發順利！🎉