@echo off
setlocal enabledelayedexpansion
title Seleccion de Impresora
cd /d "%~dp0"

echo ============================================
echo   Seleccion de Impresora y Placa
echo ============================================
echo.
echo   Modelos soportados:
echo.
echo   ENDER 3 / ENDER 3 PRO
echo   ----------------------
echo   1) Ender 3 o Ender 3 Pro  ^|  Placa Creality 4.2.2
echo   2) Ender 3 o Ender 3 Pro  ^|  Placa Creality 4.2.7
echo.
echo   ENDER 3 V2
echo   ----------
echo   3) Ender 3 V2  ^|  Placa Creality 4.2.2
echo   4) Ender 3 V2  ^|  Placa Creality 4.2.7
echo.
echo   ENDER 3 V3
echo   ----------
echo   5) Ender 3 V3 SE  ^|  Placa Creality 4.2.7  (con CR Touch)
echo.
echo   6) Mi impresora no esta en la lista (instala cfg generico)
echo.
echo ============================================
echo   Como saber que placa tengo?
echo   Abrir la caja electronica de la impresora.
echo   La placa tiene impreso el numero (4.2.2 o 4.2.7) en la PCB.
echo ============================================
echo.

set /p "OPT=   Seleccionar opcion [1-6]: "

if "%OPT%"=="1" set CFG=ender3-creality-4.2.2.cfg      & set DESC=Ender 3 / Pro con placa 4.2.2
if "%OPT%"=="2" set CFG=ender3-creality-4.2.7.cfg      & set DESC=Ender 3 / Pro con placa 4.2.7
if "%OPT%"=="3" set CFG=ender3v2-creality-4.2.2.cfg    & set DESC=Ender 3 V2 con placa 4.2.2
if "%OPT%"=="4" set CFG=ender3v2-creality-4.2.7.cfg    & set DESC=Ender 3 V2 con placa 4.2.7
if "%OPT%"=="5" set CFG=ender3v3-se-creality-4.2.7.cfg & set DESC=Ender 3 V3 SE con placa 4.2.7
if "%OPT%"=="6" set CFG=ender3-creality-4.2.2.cfg      & set DESC=Generica (basada en Ender 3 4.2.2, editar manualmente)

if not defined CFG (
    echo   [!] Opcion invalida. Usar 1-6.
    pause
    exit /b 1
)

echo.
echo   Seleccionado: %DESC%
echo.

:: Copiar cfg seleccionado a WSL
set "PROJ=%~dp0"
set "PROJ=%PROJ:\=/%"
set "PROJ=%PROJ::=%"
set "PROJ=/mnt/%PROJ%"

set WSL_DISTRO=Ubuntu

wsl -d %WSL_DISTRO% -e bash -c "cp '%PROJ%configs/%CFG%' ~/printer_data/config/printer.cfg && cp '%PROJ%configs/macros_recovery.cfg' ~/printer_data/config/macros_recovery.cfg && echo OK"
if errorlevel 1 (
    echo   [ERROR] No se pudo copiar el archivo. Verificar que WSL este activo.
    pause
    exit /b 1
)

echo   [OK] printer.cfg instalado: %CFG%
echo.
echo   RECORDAR:
echo   - Verificar el puerto USB en printer.cfg (por defecto /dev/ttyUSB0)
echo   - Hacer PID tuning antes de la primera impresion
echo   - Calibrar el Z offset
echo.
pause
