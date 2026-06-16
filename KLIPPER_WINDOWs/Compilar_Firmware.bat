@echo off
title Compilar Firmware Klipper
cd /d "%~dp0"

set WSL_DISTRO=Ubuntu

echo ============================================
echo   Compilador de Firmware Klipper
echo ============================================
echo.

:: Verificar WSL
echo [1/3] Verificando WSL...
wsl -d %WSL_DISTRO% -u root -e bash -c "echo ok" >nul 2>&1
if errorlevel 1 (
    echo   [!] WSL no activo. Iniciando...
    start /MIN "" wsl -d %WSL_DISTRO%
    timeout /t 10 /nobreak >nul
)
echo   [OK]

:: Calcular ruta del proyecto
set "PROJ=%~dp0"
set "PROJ=%PROJ:\=/%"
set "PROJ=%PROJ::=%"
set "PROJ=/mnt/%PROJ%"

:: Ejecutar compilador
echo [2/3] Ejecutando compilador...
echo.
wsl -d %WSL_DISTRO% -e bash %PROJ%/scripts/build-firmware.sh
echo.

:: Final
echo [3/3] Firmware compilado
echo.
echo   Buscar el archivo en: firmwares\klipper.bin
echo   Renombrar a firmware.bin y copiar a SD.
echo.
pause
