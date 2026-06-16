@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
title Klipper WSL2 - Instalacion Automatica

:: Color macros
set "C_RED=[91m"
set "C_GREEN=[92m"
set "C_YELLOW=[93m"
set "C_CYAN=[96m"
set "C_RESET=[0m"
set "WSL_DISTRO=Ubuntu"

echo ============================================
echo   Klipper WSL2 - Instalacion Automatica
echo   Windows 10 / 11
echo ============================================
echo.
echo   Ingresar usuario para WSL (dejar vacio = %USERNAME%):
set /p "WSL_USER=   Usuario Linux: "
if not defined WSL_USER set "WSL_USER=%USERNAME%"
echo.

:: ----- Admin check -----
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo %C_RED%[ERROR] Ejecutar como ADMINISTRADOR%C_RESET%
    pause
    exit /b 1
)
echo %C_GREEN%[OK] Administrador%C_RESET%

:: ----- OS check -----
ver | find "10." >nul
if %errorlevel% neq 0 (
    echo %C_RED%[ERROR] Windows 10/11 requerido%C_RESET%
    pause
    exit /b 1
)
echo %C_GREEN%[OK] Windows 10/11%C_RESET%

:: ============================================
::  1. Habilitar WSL
:: ============================================
echo.
echo %C_CYAN%[1/8] Habilitando WSL...%C_RESET%
dism /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /quiet /norestart
echo %C_GREEN%  [OK]%C_RESET%

:: ============================================
::  2. Habilitar VirtualMachinePlatform
:: ============================================
echo.
echo %C_CYAN%[2/8] Habilitando VirtualMachinePlatform...%C_RESET%
dism /online /enable-feature /featurename:VirtualMachinePlatform /quiet /norestart
echo %C_GREEN%  [OK]%C_RESET%

:: ============================================
::  3. WSL2 kernel update
:: ============================================
echo.
echo %C_CYAN%[3/8] Instalando WSL2 kernel update...%C_RESET%
if exist "biblio\wsl_update_x64.msi" (
    msiexec /i "biblio\wsl_update_x64.msi" /quiet /norestart
    echo %C_GREEN%  [OK]%C_RESET%
) else (
    echo   %C_YELLOW[!] No encontrado, se usara el de Windows Update%C_RESET%
)

:: ============================================
::  4. Configurar WSL2 por defecto
:: ============================================
echo.
echo %C_CYAN%[4/8] Configurando WSL2 como version por defecto...%C_RESET%
wsl --set-default-version 2
echo %C_GREEN%  [OK]%C_RESET%

:: ============================================
::  5. Copiar .wslconfig
:: ============================================
echo.
echo %C_CYAN%[5/8] Creando .wslconfig (limite 4GB RAM)...%C_RESET%
copy /Y ".wslconfig" "%USERPROFILE%\.wslconfig" >nul
echo %C_GREEN%  [OK]%C_RESET%

:: ============================================
::  6. Instalar Ubuntu
:: ============================================
echo.
echo %C_CYAN%[6/8] Instalando Ubuntu...%C_RESET%

:: Verificar si Ubuntu ya existe
wsl -d %WSL_DISTRO% -u root -e echo ok >nul 2>&1
if !errorlevel! equ 0 (
    echo %C_GREEN%  [OK] %WSL_DISTRO% ya instalada y funcional%C_RESET%
) else (
    wsl --install -d %WSL_DISTRO%
    if !errorlevel! neq 0 (
        echo %C_YELLOW%  [!] wsl --install fallo. Si ya existe, continuar...%C_RESET%
        echo       https://apps.microsoft.com/detail/9PDXGNCFSCZV
    ) else (
        echo %C_GREEN%  [OK] Ubuntu instalado%C_RESET%
    )
)

:: ============================================
::  7. Instalar usbipd
:: ============================================
echo.
echo %C_CYAN%[7/8] Instalando usbipd-win...%C_RESET%
if exist "biblio\usbipd-win_5.3.0_x64.msi" (
    msiexec /i "biblio\usbipd-win_5.3.0_x64.msi" /quiet /norestart
    echo %C_GREEN%  [OK] Instalado desde biblio\%C_RESET%
) else (
    winget install --silent --accept-package-agreements dorssel.usbipd-win
    if !errorlevel! neq 0 (
        echo %C_YELLOW%  [!] Instalar manual:%C_RESET%
        echo       https://github.com/dorssel/usbipd-win/releases
        pause
    ) else (
        echo %C_GREEN%  [OK]%C_RESET%
    )
)

:: ============================================
::  8. Crear usuario + ejecutar setup en WSL
:: ============================================
echo.
echo %C_CYAN%[8/8] Configurando Klipper dentro de WSL...%C_RESET%
echo   Esto puede tardar 5-10 minutos segun tu internet.
echo   No cerrar esta ventana.
echo.

:: Esperar que WSL termine de instalarse
echo   Esperando que WSL arranque...
wsl --terminate %WSL_DISTRO% >nul 2>&1
timeout /t 3 /nobreak >nul

:: Crear usuario Linux automaticamente
echo   Creando usuario %WSL_USER%...
wsl -d %WSL_DISTRO% -u root -e bash -c "
    if ! id %WSL_USER% &>/dev/null; then
        useradd -m -s /bin/bash %WSL_USER%
        echo '%WSL_USER% ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
    fi
    echo OK
" >nul 2>&1
if %errorlevel% neq 0 (
    echo %C_YELLOW%  [!] Error creando usuario. Reintento manual...%C_RESET%
    echo   Abriendo WSL para configuracion inicial...
    start /WAIT wsl -d %WSL_DISTRO%
    wsl -d %WSL_DISTRO% -u root -e bash -c "
        id %WSL_USER% &>/dev/null || {
            useradd -m -s /bin/bash %WSL_USER%
            echo '%WSL_USER% ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
        }
    " >nul 2>&1
)
echo %C_GREEN%  [OK] Usuario %WSL_USER% listo%C_RESET%

:: Configurar WSL para que arranque con ese usuario
wsl -d %WSL_DISTRO% -u root -e bash -c "echo '[user]' > /etc/wsl.conf; echo 'default=%WSL_USER%' >> /etc/wsl.conf" >nul 2>&1

:: Copiar script de setup a WSL
set "PROJ_DIR=%~dp0"
set "PROJ_DIR=%PROJ_DIR:~0,-1%"
set "WSL_PATH=%PROJ_DIR:\=/%"
set "WSL_PATH=%WSL_PATH::=%"
set "WSL_PATH=/mnt/%WSL_PATH%"
echo   Copiando script a WSL...
wsl -d %WSL_DISTRO% -u root -e bash -c "mkdir -p /home/%WSL_USER%/install && cp '%WSL_PATH%/scripts/setup-klipper.sh' /home/%WSL_USER%/install/setup-klipper.sh && chmod +x /home/%WSL_USER%/install/setup-klipper.sh && chown %WSL_USER%:%WSL_USER% /home/%WSL_USER%/install -R"

:: Ejecutar setup como usuario normal
echo   Instalando Klipper + Moonraker + Mainsail...
echo   (descargando e instalando, puede tomar varios minutos)
wsl -d %WSL_DISTRO% -u %WSL_USER% -e bash /home/%WSL_USER%/install/setup-klipper.sh
if %errorlevel% neq 0 (
    echo %C_RED%  [ERROR] El setup fallo. Revisa los logs.%C_RESET%
    pause
) else (
    echo %C_GREEN%  [OK] Klipper instalado%C_RESET%
)

:: Limpiar
wsl -d %WSL_DISTRO% -u root -e bash -c "rm -rf /home/%WSL_USER%/install" >nul 2>&1

:: ============================================
::  FIN - Copiar accesos directos
:: ============================================
echo.
echo %C_CYAN%Creando accesos directos en el escritorio...%C_RESET%
copy /Y "Iniciar_Klipper.bat" "%USERPROFILE%\OneDrive\Escritorio\Iniciar_Klipper.bat" >nul 2>&1
if %errorlevel% neq 0 (
    copy /Y "Iniciar_Klipper.bat" "%USERPROFILE%\Desktop\Iniciar_Klipper.bat" >nul
)
copy /Y "Compilar_Firmware.bat" "%USERPROFILE%\OneDrive\Escritorio\Compilar_Firmware.bat" >nul 2>&1
if %errorlevel% neq 0 (
    copy /Y "Compilar_Firmware.bat" "%USERPROFILE%\Desktop\Compilar_Firmware.bat" >nul
)
echo %C_GREEN%  [OK]%C_RESET%

:: ============================================
::  Seleccion de impresora
:: ============================================
echo.
echo %C_CYAN%Seleccionando configuracion de impresora...%C_RESET%
call "%~dp0configs\seleccionar_impresora.bat"

echo.
echo ============================================
echo   Instalacion completada!
echo ============================================
echo.
echo %C_YELLOW%PASOS FINALES:%C_RESET%
echo.
echo   1. REINICIAR LA PC
echo.
echo   2. Conectar la impresora USB
echo.
echo   3. Ejecutar Iniciar_Klipper.bat del escritorio
echo      (detecta el USB automaticamente)
echo.
pause
