# Configuraciones de impresora

- Seleccionar el archivo correspondiente a tu impresora y placa durante la instalacion.

## Archivo	Impresora	Placa	MCU
- ender3-creality-4.2.2.cfg	Ender 3 / Pro	Creality 4.2.2	STM32F103
- ender3v2-creality-4.2.2.cfg	Ender 3 V2	Creality 4.2.2	STM32F103
- ender3-creality-4.2.7.cfg	Ender 3 / Pro	Creality 4.2.7	STM32F103
- ender3v2-creality-4.2.7.cfg	Ender 3 V2	Creality 4.2.7	STM32F103
- ender3v3-se-creality-4.2.7.cfg	Ender 3 V3 SE	Creality 4.2.7	STM32F103
- ender3pro-creality-4.2.7.cfg	Ender 3 Pro	Creality 4.2.7	STM32F103

## Como identificar tu placa

- La placa tiene impreso el numero de version (4.2.2 o 4.2.7) en la PCB.
- Abrir la caja electronica de la impresora y buscar el numero en la placa.

## Despues de instalar
- Siempre hacer PID tuning antes de imprimir:
PID_CALIBRATE HEATER=extruder TARGET=200
PID_CALIBRATE HEATER=heater_bed TARGET=60
- Y calibrar el Z offset con un papel entre la boquilla y la cama.
