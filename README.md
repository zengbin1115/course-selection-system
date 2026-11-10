# 東海大學通識選課系統 (Course Selection Recommendation System)

## 📖 專案簡介
本專案為解決大學生選課痛點所開發之智慧推薦系統。透過整合使用者的 CPAS 職業適性診斷測驗結果，運用自定義雙軌演算法分析核心職能的強弱項，並自動推薦最合適的通識課程，協助學生實現適性發展與弱項補強的教育目標。

## 🚀 系統架構與核心技術 (Tech Stack)
本系統採用前後端分離與微服務架構設計，確保系統的高可用性與可擴展性：
*   **後端框架 (Laravel 11 / PHP)：** 採用 MVC 架構，負責核心商業邏輯、路由分發、中介層 (Middleware) 權限控管與表單驗證。
*   **微服務運算 (FastAPI / Python)：** 獨立運作於 `python_api` 模組，將高耗能的 PDF 檔案解析、OCR 辨識與矩陣內積推薦演算法與主伺服器解耦。
*   **前端渲染 (Vue.js + Vite)：** 透過 `vite.config.ts` 進行模組化建置，處理非同步表單請求 (JSON/FormData) 與動態互動介面。
*   **資料庫 (MySQL)：** 遵循 3NF 正規化設計，應用 Transaction 與底層鎖定 (Locking) 機制，確保高併發選課情境下的資料一致性，防範資源超賣。

## 📂 核心目錄結構 (Directory Structure)
本儲存庫的程式碼結構規劃如下：
*   `app/Http/Controllers/`：存放 Laravel 核心邏輯，如處理 PDF 上傳與呼叫演算法的 `CpasResultController.php`。
*   `python_api/`：存放 FastAPI 應用程式、PDF 解析模組與強/弱關係推薦演算法腳本 (`strong.py`, `weak.py`)。
*   `database/`：包含資料庫遷移檔 (Migrations) 與資料填充 (Seeders)，實現資料庫版本控制。
*   `resources/` & `public/`：存放 Vue 視圖組件與編譯後的靜態前端資源。

## 🛠️ 本地端快速啟動 (Quick Start)
為提升協同開發效率，本專案已封裝自動化啟動腳本。
1. 安裝 PHP 與 Node.js 依賴套件：
   ```bash
   composer install
   npm install
