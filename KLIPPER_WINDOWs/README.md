# Klipper WSL2 Installer (Portable)

Instalador automatico de Klipper + Moonraker + Mainsail sobre WSL2 en Windows 10/11.

Un solo clic. Sin comandos manuales.

## Como usar

1. Ejecutar `install.bat` como **Administrador**
2. **Reiniciar la PC**
3. Conectar la impresora USB
4. Ejecutar `Iniciar_Klipper.bat` del escritorio

## Que hace install.bat 

- Activa WSL2 y VirtualMachinePlatform
- Instala Ubuntu + usbipd-win
- Crea el usuario Linux y configura sudo sin password
- Instala Klipper, Moonraker y Mainsail automaticamente
- Configura nginx, servicios systemd y auto-arranque
- Crea acceso directo en el escritorio

## Que hace Iniciar_Klipper.bat

- Inicia WSL2 (mantiene la VM activa)
- Detecta la impresora USB automaticamente (CH340/Serial)
- Adjunta el USB a WSL
- Inicia Klipper + Moonraker + nginx
- Abre Mainsail en Chrome

## Requisitos

- Windows 10 (build 2004+) o Windows 11
- 8 GB RAM minimo
- Impresora 3D con placa compatible

## Estructura

```
KLIPPER_WINDOWs/
├── install.bat              # Instalador (ejecutar como Admin)
├── Iniciar_Klipper.bat      # Launcher diario (auto-detect USB)
├── .wslconfig               # Limite 4GB RAM
├── .gitignore
├── README.md
├── scripts/
│   ├── setup-klipper.sh     # Setup automatico (corre solo)
│   └── build-firmware.sh    # Compilador de firmware
├── configs/                 # printer.cfg de ejemplo
├── firmwares/
│   └── README.md            # Guia de flasheo
└── biblio/                  # Instaladores offline
    ├── wsl_update_x64.msi
    ├── usbipd-win_5.3.0_x64.msi
    └── kiauh-master/
```

## Compilar Firmware

```bash
sudo bash scripts/build-firmware.sh
```

## FAQ

**P: Se puede llevar en un USB?**
R: Si, rutas relativas. La carpeta se puede copiar a cualquier lado.

**P: Que pasa si no tengo internet?**
R: Los instaladores estan en biblio/. Instalacion 100% offline.
