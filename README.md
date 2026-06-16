# migrando-de-marlin-a-klipper

Aplicacion que les permite migrar sus impresoras 3D con Marlin a Klipper sin tener raspberry

Hace un tiempo compartí una guía para configurar Marlin en impresoras 3D e incluso adaptarlo para proyectos CNC. Esta vez quiero mostrar algo diferente que me tuvo investigando durante bastante tiempo: la migración de Marlin a Klipper.
Seguramente muchos ya escucharon hablar de Klipper o vieron videos donde las impresoras trabajan más rápido, con menos ruido y obteniendo mejores terminaciones. Eso fue justamente lo que despertó mi curiosidad. Después de probarlo personalmente, entendí por qué tanta gente lo recomienda.
Para quienes nunca escucharon hablar de Klipper, la idea es bastante simple. Normalmente, la placa electrónica de la impresora se encarga de realizar todos los cálculos necesarios para mover motores, controlar temperaturas y ejecutar el código de impresión. Con Klipper, gran parte de ese trabajo pasa a realizarlo una computadora externa (o una Raspberry Pi), mientras que la placa de la impresora se limita a ejecutar las órdenes que recibe.
Dicho de otra manera: la computadora se convierte en el cerebro de la impresora, y la electrónica original pasa a funcionar principalmente como una interfaz para controlar motores, sensores y actuadores.

**¿Y qué ventajas tiene esto?**

Principalmente, un aumento importante en el rendimiento y la calidad de impresión:
- Permite imprimir a mayores velocidades sin perder calidad.
- Reduce vibraciones y el efecto "ghosting" o sombras en las piezas.
- Mejora el control de extrusión para obtener esquinas más limpias y superficies más prolijas.
- Genera movimientos más suaves y silenciosos.
- Facilita enormemente la configuración y el mantenimiento de la impresora.
- Además, incorpora una interfaz web muy cómoda desde donde se puede controlar todo el proceso de impresión usando cualquier navegador, ya sea desde una PC vieja o notebook...

***Entre otras cosas, permite:***
- Subir archivos directamente por red.
- Monitorear temperaturas en tiempo real.
- Iniciar, pausar o cancelar impresiones.
- Modificar configuraciones sin tener que recompilar el firmware.
- Prescindir completamente de las tarjetas microSD.

Hasta acá todo parece perfecto. El problema es que la mayoría de los tutoriales asumen que disponemos de una Raspberry Pi dedicada exclusivamente a la impresora.

En mi caso particular no tenía una Raspberry, así que empecé a investigar alternativas para utilizar únicamente una PC con Windows.

Y ahí comenzaron los dolores de cabeza.

Si bien Windows 10 y Windows 11 incorporan WSL (Windows Subsystem for Linux), que permite ejecutar Linux dentro de Windows, la instalación de Klipper sigue requiriendo varios pasos técnicos, comandos de PowerShell, configuración de USBIPD para compartir el puerto USB con Linux y una serie de procedimientos que pueden resultar bastante frustrantes para quienes no están acostumbrados a trabajar con sistemas Linux.

Después de pasar varias horas peleándome con instalaciones, configuraciones y errores, decidí simplificar todo el proceso creando una pequeña aplicación que automatiza prácticamente cada paso.

El resultado es KLIPPER_WINDOWs, una herramienta que instala y configura automáticamente Klipper, Moonraker y Mainsail sobre Windows 10 y Windows 11 utilizando WSL2, sin necesidad de Raspberry Pi y sin tener que ejecutar manualmente una larga lista de comandos.

`***La idea fue simple:*** que cualquier persona pueda tener Klipper funcionando con apenas unos pocos clics.`

**El instalador se encarga de:**
- Habilitar WSL2.
- Instalar Ubuntu.
- Configurar Klipper.
- Instalar Moonraker.
- Instalar Mainsail.
- Configurar nginx.
- Preparar el entorno completo para comenzar a imprimir.

`Una vez instalado, el launcher diario detecta automáticamente la impresora conectada por USB, inicia todos los servicios necesarios y abre Mainsail en el navegador.`

En pocas palabras, lo que normalmente requiere seguir varios tutoriales, copiar comandos y solucionar errores manualmente, queda reducido a un proceso mucho más simple y accesible.


## 🛠️ Requisitos y Herramientas Recomendadas

Para realizar la migración de forma correcta, es fundamental que utilices las versiones más recientes de los siguientes proyectos oficiales:

* **[Klipper](https://github.com/klipper3d/klipper):** El firmware principal. Asegúrate de descargar las últimas actualizaciones directamente desde el repositorio oficial de @klipper3d y guardalos en la carpeta "biblio".
* **[KIAUH (Klipper Installation And Update Helper)](https://github.com/dw-0/kiauh):** La herramienta recomendada para instalar y mantener tu entorno actualizado. Descarga la última versión desde el repositorio de @dw-0 y guardalos en la carpeta "biblio".

## Características principales
- Instalación completamente automática mediante un único archivo .bat.
- Detección automática de la impresora USB.
- Entorno completo con Klipper, Moonraker y Mainsail.
- Compilador de firmware integrado.
- Perfiles preconfigurados para las placas Creality más comunes y SKR Mini E3.
- Posibilidad de instalación offline utilizando los instaladores incluidos.
- Proyecto portátil que puede ejecutarse desde un pendrive.
- Configuración optimizada para minimizar el impacto sobre Windows.

**Requisitos mínimos**
- Windows 10 (Build 2004 o superior) o Windows 11.
- 8 GB de memoria RAM.
- Impresora compatible con Klipper.
- Python 3.10.
- Conexión a Internet para la primera instalación.

### Configuraciones incluidas

Esta versión incorpora perfiles preconfigurados para varias impresoras de la familia Ender, facilitando enormemente la puesta en marcha:
- Ender 3 con Creality 4.2.2
- Ender 3 con Creality 4.2.7
- Ender 3 Pro con Creality 4.2.7
- Ender 3 V2 con Creality 4.2.2
- Ender 3 V2 con Creality 4.2.7
- Ender 3 V3 SE con Creality 4.2.7

`Por defecto, el sistema queda configurado para una Ender 3 con placa Creality 4.2.2, aunque posteriormente se puede cambiar de modelo sin necesidad de reinstalar todo el entorno.`

***Mi objetivo con este proyecto no fue reinventar Klipper ni reemplazar los métodos tradicionales de instalación. Simplemente quise eliminar la parte más tediosa del proceso para que cualquier usuario pueda probar Klipper en una PC con Windows sin necesidad de convertirse en experto en Linux durante el intento.***

# 📚 KLIPPER_WINDOWs — Guía de uso

***Requisitos previos***
- Windows 10 (build 2004 o superior) o Windows 11
- 8 GB de RAM mínimo
- Impresora 3D Ender 3 / Pro / V2 / V3 SE con placa Creality 4.2.2 o 4.2.7
- Conexión a internet para la primera instalación
- Python 3.10 o superior

---

## 🔧 1. Instalación
- Descomprimir el zip en cualquier carpeta (también funciona desde un pendrive)
- Copiar los archivos de biblio/ desde la versión anterior si los tenés: wsl_update_x64.msi, usbipd-win_5.3.0_x64.msi y kiauh-master.zip
- Hacer clic derecho sobre install.bat → Ejecutar como Administrador
- El instalador va a pedir un nombre de usuario para Linux (se puede dejar vacío para usar el mismo de Windows)
- El proceso instala WSL2, Ubuntu, Klipper, Moonraker y Mainsail automáticamente. Tarda entre 5 y 15 minutos según la velocidad de internet
- Al finalizar aparece el menú de selección de impresora — elegir el modelo y placa que corresponda
- Reiniciar la PC cuando el instalador lo indique

---

## 🔨 2. Compilar el firmware

Antes de conectar la impresora hay que compilar y flashear el firmware de Klipper en la placa.
- Ejecutar Compilar_Firmware.bat
- Seleccionar el modelo de placa en el menú (tiene que coincidir con lo elegido en la instalación)
- Esperar que compile — el archivo klipper.bin queda guardado automáticamente en la carpeta firmwares/
- Copiar klipper.bin a una tarjeta microSD, renombrarlo a firmware.bin
- Con la impresora apagada insertar la SD y encender — la placa flashea sola en unos segundos
- La impresora queda lista cuando el archivo en la SD se renombra solo a FIRMWARE.CUR

Ver `firmwares/README.md` para más detalles sobre el proceso de flasheo según placa.

---

## 🚀 3. Uso diario
- Conectar la impresora por USB
- Ejecutar `Iniciar_Klipper.bat` desde el escritorio
- El launcher detecta automáticamente la impresora USB, la conecta a WSL e inicia todos los servicios
- Se abre el navegador con Mainsail en http://localhost
- ***Desde Mainsail se controla todo:*** home, temperatura, subir archivos y lanzar impresiones
- Mantener abierta la ventana de terminal mientras se imprime. Cerrarla detiene los servicios.

---

## 🎯 4. Primera vez — calibración obligatoria

Antes de la primera impresión hacer estos pasos desde la consola de Mainsail:

- PID tuning del hotend: `PID_CALIBRATE HEATER=extruder TARGET=200`
- PID tuning de la cama: `PID_CALIBRATE HEATER=heater_bed TARGET=60`
- Calibrar Z offset con un papel entre la boquilla y la cama: `PROBE_CALIBRATE`

o ajustar manualmente el `position_endstop` en `printer.cfg`.
- Después de cada calibración guardar con: `SAVE_CONFIG`

---

### 🔄 Recuperación ante cortes de luz o cuelgues

El sistema guarda automáticamente el estado de la impresión cada 5 segundos. Si hay un corte o cuelgue:

- Ejecutar Iniciar_Klipper.bat normalmente
- En la consola de Mainsail ejecutar `SHOW_SAVED_STATE` para ver dónde quedó
- Ejecutar `RECOVER_PRINT` para reanudar desde el último punto guardado
- Si la recuperación no es exacta, usar `SET_RECOVERY_STATE` con las coordenadas del log y luego `RECOVER_PRINT`
- Al terminar la impresión ejecutar `CLEAR_RECOVERY` para limpiar el estado guardado

---

## 6. Cambiar la configuración de impresora

Si se cambia de impresora o placa, ejecutar configs/seleccionar_impresora.bat y elegir el nuevo modelo. No hace falta reinstalar todo.


