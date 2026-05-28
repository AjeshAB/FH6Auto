@echo off
chcp 65001 >nul
setlocal

cd /d "%~dp0"

set APP_NAME=FH6Auto
set MAIN_FILE=main.py

echo.
echo ==============================
echo Building %APP_NAME%
echo ==============================
echo.

where uv >nul 2>nul
if errorlevel 1 (
    echo [ERROR] 'uv' was not found. Please install uv first.
    echo powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    pause
    exit /b 1
)

echo.
echo [1/4] Installing required packages...

uv pip install ^
    pyinstaller ^
    customtkinter ^
    opencv-python ^
    numpy ^
    pyautogui ^
    pydirectinput ^
    requests ^
    pynput ^
    pillow ^
    pywin32

if errorlevel 1 (
    echo.
    echo [ERROR] Failed to install packages!
    pause
    exit /b 1
)

echo.
echo [2/4] Cleaning old build files...
if exist build rmdir /s /q build
if exist dist rmdir /s /q dist
if exist "%APP_NAME%.spec" del /f /q "%APP_NAME%.spec"

echo.
echo [3/4] Running PyInstaller...

uv run python -m PyInstaller ^
    -n "%APP_NAME%" ^
    -F ^
    -w ^
    --uac-admin ^
    "%MAIN_FILE%" ^
    --icon=assets/icon.ico ^
    --add-data "images;images" ^
    --add-data "assets;assets"

if errorlevel 1 (
    echo.
    echo [ERROR] Build failed!
    pause
    exit /b 1
)

echo.
echo [4/4] Build completed successfully!
echo Output:
echo dist\%APP_NAME%.exe
echo.
pause