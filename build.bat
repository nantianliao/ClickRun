@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion
title ClickRun Build Script

echo ========================================
echo   ClickRun - One Click Build
echo ========================================
echo.

REM Auto-detect Visual Studio
set VCVARS=

REM VS2022 paths
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat" set VCVARS="C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
if exist "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat" set VCVARS="C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"

REM VS2019
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat" set VCVARS="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars64.bat"

REM VS2017
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat" set VCVARS="C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars64.bat"

if not defined VCVARS (
    echo [ERROR] Visual Studio 2022/2019/2017 not found.
    echo Please install Visual Studio with C++ workload.
    pause
    exit /b 1
)

echo [INFO] Visual Studio found.

:select_mode
echo.
echo Select configuration:
echo   [1] Release (x64) - recommended
echo   [2] Debug   (x64)
echo   [3] Release (Win32)
echo   [4] Debug   (Win32)
set /p CHOICE="Enter (1/2/3/4, default 1): "
if "%CHOICE%"=="" set CHOICE=1

set CONFIG=Release
set PLATFORM=x64
set VARCH=x64
if "%CHOICE%"=="2" set CONFIG=Debug
if "%CHOICE%"=="3" set PLATFORM=Win32 & set VARCH=x86
if "%CHOICE%"=="4" set CONFIG=Debug & set PLATFORM=Win32 & set VARCH=x86

if "%CHOICE%" NEQ "1" if "%CHOICE%" NEQ "2" if "%CHOICE%" NEQ "3" if "%CHOICE%" NEQ "4" (
    echo Invalid choice, please try again.
    goto select_mode
)

echo.
echo Building: %CONFIG% ^| %PLATFORM%
echo.

REM Switch to 32-bit vcvars if needed
if "%VARCH%"=="x86" (
    set VCVARS=%VCVARS:vcvars64=vcvars32%
)

call %VCVARS%
if errorlevel 1 (
    echo [ERROR] Failed to initialize VC environment.
    pause
    exit /b 1
)

msbuild ClickRun.sln /t:Rebuild /p:Configuration=%CONFIG% /p:Platform=%PLATFORM% /nologo /v:q

if %errorlevel% EQU 0 (
    echo.
    echo ========================================
    echo   BUILD SUCCESS
    echo ========================================
    set OUTDIR=ClickRun\x64\%CONFIG%
    if "%PLATFORM%"=="Win32" set OUTDIR=ClickRun\%CONFIG%
    if exist "%OUTDIR%\ClickRun.exe" (
        echo Output: %OUTDIR%\ClickRun.exe
        echo.
        echo To run: %OUTDIR%\ClickRun.exe
    ) else (
        echo Binary not found at %OUTDIR%\ClickRun.exe
        echo Check build output manually.
    )
) else (
    echo.
    echo ========================================
    echo   BUILD FAILED (code: %errorlevel%)
    echo ========================================
)

echo.
pause
