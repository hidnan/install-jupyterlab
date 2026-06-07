#!/bin/bash

set -e

echo "========================================"
echo "   JupyterLab Auto Installer"
echo "   by: nama_kamu"
echo "========================================"

# Update sistem
echo "[1/5] Update system packages..."
apt-get update -y && apt-get upgrade -y

# Install Python & pip
echo "[2/5] Installing Python & pip..."
apt-get install -y python3 python3-pip python3-venv

# Buat virtual environment
echo "[3/5] Creating virtual environment..."
python3 -m venv /opt/jupyterlab-env
source /opt/jupyterlab-env/bin/activate

# Install JupyterLab
echo "[4/5] Installing JupyterLab..."
pip install --upgrade pip
pip install jupyterlab

# Set password & konfigurasi
echo "[5/5] Configuring JupyterLab..."
mkdir -p /root/.jupyter

# Generate config
jupyter lab --generate-config

# Set agar bisa diakses dari luar
cat >> /root/.jupyter/jupyter_lab_config.py << EOF
c.ServerApp.ip = '0.0.0.0'
c.ServerApp.port = 8888
c.ServerApp.open_browser = False
c.ServerApp.allow_root = True
EOF

# Set password
echo ""
echo "Masukkan password untuk JupyterLab:"
jupyter lab password

# Buat systemd service supaya auto-start
cat > /etc/systemd/system/jupyterlab.service << EOF
[Unit]
Description=JupyterLab Server
After=network.target

[Service]
Type=simple
User=root
ExecStart=/opt/jupyterlab-env/bin/jupyter lab --config=/root/.jupyter/jupyter_lab_config.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable jupyterlab
systemctl start jupyterlab

echo ""
echo "========================================"
echo "✅ JupyterLab berhasil diinstall!"
echo "   Akses di: http://IP_VPS_KAMU:8888"
echo "========================================"
