#!/bin/bash
set -e

cd ~/klipper

echo "============================================"
echo "  Compilador de Firmware Klipper"
echo "============================================"
echo ""
echo "Selecciona tu placa:"
echo ""
echo "  1) Creality 4.2.2  (Ender 3 / Ender 3 V2)"
echo "     STM32F103, 28KiB bootloader, USART1, 250000"
echo ""
echo "  2) Creality 4.2.7  (Ender 3 Pro / V2)"  
echo "     STM32F103 RET6, 72KiB bootloader, USART1, 250000"
echo ""
echo "  3) Creality 4.2.10 (Ender 3 V2 / S1)"
echo "     STM32F401, 64KiB bootloader, USART1, 250000"
echo ""
echo "  4) SKR Mini E3 V2/V3"
echo "     STM32F103, 28KiB bootloader, USB"
echo ""
echo "  5) Otra / Manual (abre menuconfig)"
echo ""
echo "  6) Salir"
echo ""
read -p "Opcion [1-6]: " opt

case $opt in
    1)
        echo "Aplicando config para Creality 4.2.2..."
        cat > .config << EOF
CONFIG_MACH_STM32=y
CONFIG_MACH_STM32F103=y
CONFIG_STM32_FLASH_START_7000=y
CONFIG_STM32_SERIAL_USART1=y
CONFIG_CLOCK_REF_8M=y
CONFIG_SERIAL_BAUD=250000
EOF
        ;;
    2)
        echo "Aplicando config para Creality 4.2.7..."
        cat > .config << EOF
CONFIG_MACH_STM32=y
CONFIG_MACH_STM32F103=y
CONFIG_STM32_FLASH_START_10000=y
CONFIG_STM32_SERIAL_USART1=y
CONFIG_CLOCK_REF_8M=y
CONFIG_SERIAL_BAUD=250000
EOF
        ;;
    3)
        echo "Aplicando config para Creality 4.2.10..."
        cat > .config << EOF
CONFIG_MACH_STM32=y
CONFIG_MACH_STM32F401=y
CONFIG_STM32_FLASH_START_8000=y
CONFIG_STM32_SERIAL_USART1=y
CONFIG_CLOCK_REF_8M=y
CONFIG_SERIAL_BAUD=250000
EOF
        ;;
    4)
        echo "Aplicando config para SKR Mini E3..."
        cat > .config << EOF
CONFIG_MACH_STM32=y
CONFIG_MACH_STM32F103=y
CONFIG_STM32_FLASH_START_7000=y
CONFIG_STM32_USB=y
CONFIG_CLOCK_REF_8M=y
EOF
        ;;
    5)
        echo "Abriendo menuconfig manual..."
        make menuconfig
        # Si cancelo, salir
        if [ ! -f .config ]; then exit 0; fi
        ;;
    *)
        echo "Saliendo."
        exit 0
        ;;
esac

# Completar opciones por defecto
make olddefconfig

echo ""
echo "Compilando firmware..."
make clean
make -j$(nproc)

echo ""
echo "============================================"
echo "  Firmware compilado!"
echo "============================================"
echo ""
echo "  Output: ~/klipper/out/klipper.bin"
echo ""

# Copiar al proyecto en Windows
for d in /mnt/*/KLIPPER_WINDOWs /mnt/*/*/KLIPPER_WINDOWs; do
    if [ -d "$d/firmwares" ]; then
        cp out/klipper.bin "$d/firmwares/"
        echo "  Copiado a: $d/firmwares/klipper.bin"
        echo ""
        echo "  Renombrar a firmware.bin y copiar a SD."
        exit 0
    fi
done

echo "  No se encontro firmwares/ en /mnt/"
echo "  Copia manual: cp ~/klipper/out/klipper.bin [PROYECTO]/firmwares/"
