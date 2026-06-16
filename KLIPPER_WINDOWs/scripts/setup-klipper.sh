#!/bin/bash
set -e

WSL_USER=$(whoami)
export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

echo "============================================"
echo "  Instalando Klipper + Moonraker + Mainsail"
echo "============================================"
echo ""

# ----- 1. Update packages -----
echo "[1/7] Actualizando paquetes..."
sudo apt update -qq && sudo apt upgrade -y -qq
echo "  [OK]"

# ----- 2. Install dependencies -----
echo "[2/7] Instalando dependencias..."
sudo apt install -y -qq python3 python3-pip python3-venv git make gcc \
    avr-libc gcc-avr pkg-config libncurses-dev flex bison \
    libusb-1.0-dev libpth-dev gettext curl wget nginx \
    python3-serial python3-cffi
echo "  [OK]"

# ----- 3. Klipper -----
echo "[3/7] Instalando Klipper..."
if [ -d ~/klipper/.git ]; then
    cd ~/klipper && git pull -q
else
    git clone -q https://github.com/Klipper3d/klipper.git ~/klipper
fi
python3 -m venv ~/klipper-env
~/klipper-env/bin/pip install -q --upgrade pip
~/klipper-env/bin/pip install -q -r ~/klipper/scripts/klippy-requirements.txt
mkdir -p ~/printer_data/{config,logs,gcodes}
echo "  [OK]"

# ----- 4. Moonraker -----
echo "[4/7] Instalando Moonraker..."
if [ -d ~/moonraker ]; then
    cd ~/moonraker && git pull -q
else
    git clone -q https://github.com/Arksine/moonraker.git ~/moonraker
fi
# Install Moonraker dependencies
~/moonraker/scripts/install-moonraker.sh -c /dev/null -f -l /dev/null -q 2>/dev/null || true
echo "  [OK]"

# ----- 5. Mainsail -----
echo "[5/7] Instalando Mainsail..."
mkdir -p ~/mainsail/site
MAINSALL_URL="https://github.com/mainsail-crew/mainsail/releases/latest/download/mainsail.zip"
# Buscar zip local primero (biblio montado en /mnt/)
for d in /mnt/*/KLIPPER_WINDOWs /mnt/*/*/KLIPPER_WINDOWs /mnt/*/Python/KLIPPER_WINDOWs; do
    if [ -f "$d/biblio/mainsail.zip" ]; then
        MAINSALL_URL="$d/biblio/mainsail.zip"
        break
    fi
done
wget -q -O /tmp/mainsail.zip "$MAINSALL_URL" 2>/dev/null || curl -sL -o /tmp/mainsail.zip "$MAINSALL_URL" 2>/dev/null || true
if [ -f /tmp/mainsail.zip ] && [ -s /tmp/mainsail.zip ]; then
    unzip -q -o /tmp/mainsail.zip -d ~/mainsail/site/
    rm /tmp/mainsail.zip
    echo "  [OK]"
else
    echo "  [!] No se pudo descargar Mainsail"
    echo "  Creando pagina placeholder..."
    cat > ~/mainsail/site/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html><head><title>Klipper</title></head>
<body><h2>Klipper + Moonraker activos</h2>
<p>Mainsail no se descargo automaticamente.</p>
<p>Accede a <a href="http://localhost:7125/">Moonraker API</a></p></body></html>
HTMLEOF
fi

# ----- 6. Config files -----
echo "[6/7] Generando configuracion..."

# printer.cfg base
cat > ~/printer_data/config/printer.cfg << 'CFGEOF'
# printer.cfg - Configuracion base generada por Klipper WSL Installer
# IMPORTANTE: Editar los pines segun tu placa

[stepper_x]
step_pin: PC2
dir_pin: PB9
enable_pin: !PC3
microsteps: 16
rotation_distance: 40
endstop_pin: ^PA5
position_endstop: 0
position_max: 235
homing_speed: 50

[stepper_y]
step_pin: PB8
dir_pin: PB7
enable_pin: !PC3
microsteps: 16
rotation_distance: 40
endstop_pin: ^PA6
position_endstop: 0
position_max: 235
homing_speed: 50

[stepper_z]
step_pin: PB6
dir_pin: !PB5
enable_pin: !PC3
microsteps: 16
rotation_distance: 8
endstop_pin: ^PA7
position_endstop: 0
position_max: 250

[extruder]
step_pin: PB4
dir_pin: PB3
enable_pin: !PC3
microsteps: 16
rotation_distance: 34.406
nozzle_diameter: 0.400
filament_diameter: 1.750
heater_pin: PA1
sensor_pin: PA0
sensor_type: EPCOS 100K B57560G104F
control: pid
pid_Kp: 22.2
pid_Ki: 1.08
pid_Kd: 114
min_temp: 0
max_temp: 260

[heater_bed]
heater_pin: PA2
sensor_pin: PA4
sensor_type: EPCOS 100K B57560G104F
control: pid
pid_Kp: 690.34
pid_Ki: 111.47
pid_Kd: 1068.67
min_temp: 0
max_temp: 120

[fan]
pin: PA3

[mcu]
serial: /dev/ttyUSB0
baud: 250000
restart_method: command

[printer]
kinematics: cartesian
max_velocity: 300
max_accel: 3000
max_z_velocity: 5
max_z_accel: 100

[display]
lcd_type: st7920
cs_pin: PB12
sclk_pin: PB13
sid_pin: PB15
encoder_pins: ^PB14, ^PB10
click_pin: ^!PB2

[output_pin beeper]
pin: PC6
pwm: True
value: 0
shutdown_value: 0
cycle_time: 0.001

[force_move]
enable_force_move: True

[static_digital_output stepper_enable]
pins: !PA8, !PA9, !PA10, !PA11

[board_pins]
aliases:
    EXP1_1=PB14, EXP1_2=PB13, EXP1_3=PB12, EXP1_4=PB15,
    EXP1_5=PB2,  EXP1_6=PB10, EXP1_7=?,   EXP1_8=?,
    EXP2_1=PA15, EXP2_2=?,    EXP2_3=PA1, EXP2_4=PA3,
    EXP2_5=PA2,  EXP2_6=?,    EXP2_7=?,   EXP2_8=?

[save_variables]
filename: ~/printer_data/config/variables.cfg

[display_status]
[pause_resume]
[virtual_sdcard]
path: ~/printer_data/gcodes
CFGEOF

# moonraker.conf
cat > ~/printer_data/config/moonraker.conf << MOONEOF
[server]
host: 0.0.0.0
port: 7125
klippy_uds_address: ~/printer_data/comms/klippy.sock
config_path: ~/printer_data/config
log_path: ~/printer_data/logs

[authorization]
trusted_clients:
    127.0.0.0/8
    192.168.0.0/16
    172.16.0.0/12
    ::1/128
cors_domains:
    *://localhost
    *://localhost:*
    *.local

[octoprint_compat]

[history]

[update_manager]
refresh_interval: 168

[update_manager mainsail]
type: web
path: ~/mainsail
repo: mainsail-crew/mainsail
channel: stable
MOONEOF

# nginx config
sudo tee /etc/nginx/sites-available/mainsail > /dev/null << NGINXEOF
server {
    listen 80;
    server_name localhost;
    access_log /home/$WSL_USER/printer_data/logs/access.log;
    error_log /home/$WSL_USER/printer_data/logs/error.log;
    location / {
        root /home/$WSL_USER/mainsail/site;
        index index.html;
        try_files \$uri \$uri/ /index.html;
    }
    location /websocket {
        proxy_pass http://127.0.0.1:7125/websocket;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_read_timeout 86400;
    }
    location /printer/ {
        proxy_pass http://127.0.0.1:7125/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    location /server/ {
        proxy_pass http://127.0.0.1:7125/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    location /api/ {
        proxy_pass http://127.0.0.1:7125/;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
NGINXEOF
sudo ln -sf /etc/nginx/sites-available/mainsail /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
echo "  [OK]"

# ----- 7. Systemd services -----
echo "[7/7] Configurando servicios systemd..."
sudo tee /etc/systemd/system/klipper.service > /dev/null << KLEOF
[Unit]
Description=Klipper
After=network.target

[Service]
Type=simple
User=$WSL_USER
ExecStart=/home/$WSL_USER/klipper-env/bin/python /home/$WSL_USER/klipper/klippy/klippy.py /home/$WSL_USER/printer_data/config/printer.cfg -l /home/$WSL_USER/printer_data/logs/klippy.log
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
KLEOF

sudo tee /etc/systemd/system/moonraker.service > /dev/null << MOONEOF
[Unit]
Description=Moonraker
After=network.target

[Service]
Type=simple
User=$WSL_USER
ExecStart=/home/$WSL_USER/moonraker-env/bin/python /home/$WSL_USER/moonraker/moonraker/moonraker.py -c /home/$WSL_USER/printer_data/config/moonraker.conf
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
MOONEOF

sudo systemctl daemon-reload
sudo systemctl enable klipper moonraker nginx

# Iniciar servicios ahora
sudo systemctl start klipper moonraker nginx

echo "  [OK]"
echo ""
echo "============================================"
echo "  Instalacion completada!"
echo "============================================"
echo ""
echo "  Servicios activos:"
echo "    - Klipper  (puerto 7125)"
echo "    - Moonraker (puerto 7125)"
echo "    - nginx    (puerto 80)"
echo ""
echo "  Proximo paso: editar printer.cfg y USB_BUSID"
