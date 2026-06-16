# Compilar Firmware Klipper

## Dentro de WSL

```bash
cd /mnt/d/Python/KLIPPER_WINDOWs   # o la ruta donde tengas el proyecto
sudo bash scripts/build-firmware.sh
```

Esto muestra un menu para seleccionar tu placa. Si no aparece, elegir "Manual" y configurar:

| Opcion | Creality 4.2.2 | Creality 4.2.7 | Creality 4.2.10 |
|--------|---------------|---------------|----------------|
| Microcontroller | STM32F103 | STM32F103 | STM32F401 |
| Bootloader | 28KiB | 72KiB | 64KiB |
| Interface | Serial (USART1) | Serial (USART1) | Serial (USART1) |
| Baud | 250000 | 250000 | 250000 |

## Flashear

1. Formatear tarjeta SD en **FAT32** con tamanio de cluster por defecto (usar la herramienta de Windows: clic derecho > Formatear)
2. Copiar `out/klipper.bin` a la SD y renombrar a **firmware.bin**
3. Apagar impresora, insertar SD, encender
4. Esperar 30 segundos, apagar, sacar SD
5. Si el firmware se cargo bien, el archivo en la SD aparecera como `firmware.cur`

## Sin WSL (solo Windows)

Alternativa usando MSYS2 o compilacion cruzada:
- https://github.com/Klipper3d/klipper/blob/master/docs/Installation.md#building-for-a-mcu
