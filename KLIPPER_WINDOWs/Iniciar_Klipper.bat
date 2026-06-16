@echo off
setlocal enabledelayedexpansion
title Klipper Launcher
cd /d "%~dp0"

set WSL_DISTRO=Ubuntu

echo ============================================
echo   Klipper + Mainsail Launcher
echo ============================================
echo.

:: ============================================
::  [0] Plan de energia: Alto Rendimiento
:: ============================================
echo [0/4] Plan de energia Alto Rendimiento...
for /f "tokens=*" %%a in ('powercfg /getactivescheme') do set "ACTIVE_PLAN=%%a"
echo   Actual: %ACTIVE_PLAN%
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1
if errorlevel 1 (
    echo   [!] No se pudo cambiar plan de energia
) else (
    echo   [OK] Alto Rendimiento activado
)

:: ============================================
::  [1] Iniciar WSL
:: ============================================
echo [1/4] Iniciando %WSL_DISTRO%...
start "" wsl -d %WSL_DISTRO%

echo   Esperando conexion...
set "WSL_OK="
for /l %%i in (1,1,30) do (
    wsl -d %WSL_DISTRO% -u root -e bash -c "echo ok" >nul 2>&1
    if not errorlevel 1 set WSL_OK=1 & goto wsl_ready
    timeout /t 1 /nobreak >nul
)
:wsl_ready
if not defined WSL_OK (
    echo   [!] WSL no arranca. Ejecutar manual: wsl -d %WSL_DISTRO%
    pause
    exit /b
)
echo   [OK] %WSL_DISTRO% activo

:: ============================================
::  [2] Detectar USB automaticamente
:: ============================================
echo [2/4] Detectando impresora USB...

set USB_BUSID=
set USB_LIST=

:: Buscar dispositivo CH340 / USB-SERIAL (Shared o Attached)
for /f "tokens=1,*" %%a in ('usbipd list 2^>nul') do (
    echo %%a %%b | findstr /R "^[0-9]" >nul && (
        echo %%a %%b | find /I "USB-SERIAL" >nul 2>&1 || echo %%a %%b | find /I "CH340" >nul 2>&1 || echo %%a %%b | find /I "serial" >nul 2>&1
        if not errorlevel 1 (
            echo %%a %%b | find /I "Shared" >nul 2>&1 || echo %%a %%b | find /I "Attached" >nul 2>&1
            if not errorlevel 1 (
                set USB_BUSID=%%a
                echo %%a %%b | find /I "Attached" >nul 2>&1
                if not errorlevel 1 set USB_ALREADY_ATTACHED=1
            )
        )
    )
)

if defined USB_BUSID (
    echo   [OK] USB detectado: %USB_BUSID%
) else (
    echo   [!] No se detecto automaticamente.
    echo   Dispositivos disponibles:
    usbipd list 2>nul | findstr /V "^$"
    echo.
    set /p USB_BUSID="   Ingresar BUSID (ej: 2-1) o Enter para saltar: "
)

:: Adjuntar solo si no esta ya attached
if defined USB_BUSID (
    if defined USB_ALREADY_ATTACHED (
        echo   [OK] USB ya adjuntado anteriormente
    ) else (
        usbipd attach --wsl %WSL_DISTRO% --busid %USB_BUSID% --auto-attach >nul 2>&1
        if errorlevel 1 (
            echo   [!] Error al adjuntar USB
        ) else (
            echo   [OK] USB adjuntado
        )
    )
)

:: ============================================
::  [3] Iniciar servicios
:: ============================================
echo [3/4] Iniciando servicios...
wsl -d %WSL_DISTRO% -u root -e systemctl start klipper moonraker nginx >nul 2>&1
timeout /t 3 /nobreak >nul

:: ============================================
::  [4] Abrir Mainsail
:: ============================================
echo [4/4] Abriendo Mainsail...
start "" http://localhost/

echo.
echo   OK - Mantener abiertas esta ventana y la terminal WSL
echo.
pause
