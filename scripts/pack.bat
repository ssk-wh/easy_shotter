@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

:: ============================================================
:: SimpleShotter 打包脚本
:: 用法: scripts\pack.bat [Qt路径] [NSIS路径]
:: 示例: scripts\pack.bat D:\Qt\5.15.2\msvc2019_64
:: ============================================================

set "PROJECT_DIR=%~dp0.."
set "QT_DIR=%~1"
set "NSIS_DIR=%~2"

if "%QT_DIR%"=="" set "QT_DIR=D:\Qt\5.15.2\msvc2019_64"
if "%NSIS_DIR%"=="" set "NSIS_DIR=C:\Program Files (x86)\NSIS"

set "BUILD_DIR=%PROJECT_DIR%\build"
set "DIST_DIR=%PROJECT_DIR%\installer\dist"
set "SRC_DIR=%BUILD_DIR%\src\Release"
set "EXE_NAME=SimpleShotter.exe"
set "NSI_SCRIPT=%PROJECT_DIR%\installer\SimpleShotter.nsi"
set "OUTPUT=%PROJECT_DIR%\installer\SimpleShotter-0.2.0-Setup.exe"

:: 检查 Qt 路径
if not exist "%QT_DIR%\bin\Qt5Core.dll" (
    echo [错误] Qt 路径无效: %QT_DIR%
    echo 用法: scripts\pack.bat [Qt路径]
    exit /b 1
)

:: 检查 NSIS
if not exist "%NSIS_DIR%\makensis.exe" (
    echo [错误] NSIS 未安装: %NSIS_DIR%
    exit /b 1
)

echo ============================================================
echo  SimpleShotter 打包流程
echo ============================================================
echo  Qt:   %QT_DIR%
echo  NSIS: %NSIS_DIR%
echo ============================================================

:: Step 1: 编译
echo.
echo [1/4] 编译 Release 版本...
cmake -B "%BUILD_DIR%" -DCMAKE_PREFIX_PATH="%QT_DIR%" "%PROJECT_DIR%"
if errorlevel 1 (echo [错误] CMake 配置失败 & exit /b 1)

cmake --build "%BUILD_DIR%" --config Release --target SimpleShotter
if errorlevel 1 (echo [错误] 编译失败 & exit /b 1)

echo [OK] 编译成功

:: Step 2: 清理并重建 dist 目录
echo.
echo [2/4] 收集文件...
if exist "%DIST_DIR%" rd /s /q "%DIST_DIR%"
mkdir "%DIST_DIR%"

:: 复制 exe
copy /y "%SRC_DIR%\%EXE_NAME%" "%DIST_DIR%\" >nul

:: 复制 Qt DLL（直接从 Qt 安装目录复制，确保位数正确）
for %%f in (Qt5Core Qt5Gui Qt5Widgets Qt5Svg Qt5Concurrent) do (
    copy /y "%QT_DIR%\bin\%%f.dll" "%DIST_DIR%\" >nul
)

:: 复制 Qt 插件
for %%d in (platforms imageformats iconengines styles) do (
    if exist "%QT_DIR%\plugins\%%d" (
        mkdir "%DIST_DIR%\%%d" 2>nul
        copy /y "%QT_DIR%\plugins\%%d\*.dll" "%DIST_DIR%\%%d\" >nul
    )
)

:: 复制应用图标
copy /y "%PROJECT_DIR%\resources\app_icon.ico" "%DIST_DIR%\" >nul

:: 验证位数一致性
echo.
echo   验证 DLL 位数...
set "MISMATCH=0"
for /f "tokens=*" %%f in ('dir /b "%DIST_DIR%\*.dll"') do (
    for /f "tokens=1" %%t in ('powershell -Command "(Get-Content -Path '%DIST_DIR%\%%f' -Encoding Byte -TotalCount 300 | ForEach-Object { '{0:X2}' -f $_ }) -join '' | Select-String -Pattern '504500004C01' -Quiet"') do (
        if "%%t"=="True" (
            echo   [警告] 32位 DLL: %%f
            set "MISMATCH=1"
        )
    )
)
if "%MISMATCH%"=="1" (
    echo   [错误] 存在 32 位 DLL，与 64 位 exe 不匹配！
    exit /b 1
)
echo   [OK] 所有 DLL 位数一致

echo [OK] 文件收集完成

:: Step 3: 生成安装包
echo.
echo [3/4] 生成 NSIS 安装包...
pushd "%PROJECT_DIR%\installer"
"%NSIS_DIR%\makensis.exe" "%NSI_SCRIPT%"
if errorlevel 1 (echo [错误] NSIS 打包失败 & popd & exit /b 1)
popd
echo [OK] 安装包生成成功

:: Step 4: 输出结果
echo.
echo [4/4] 打包完成!
echo ============================================================
for %%f in ("%OUTPUT%") do echo  安装包: %%~dpnxf  (%%~zf bytes)
echo ============================================================
