#!/usr/bin/env python3
import argparse
import socket
import requests
import sys
from datetime import datetime

# Parse command-line arguments
parser = argparse.ArgumentParser(description="Simple Subdomain Recon Tool")
parser.add_argument("-u", "--url", required=True, help="Target domain (e.g., example.com)")
parser.add_argument("-o", "--output", help="Output file to save results")
args = parser.parse_args()

target = args.url.replace("http://", "").replace("https://", "").rstrip("/")
results = [f"[*] Subdomain Recon on {target} (Started: {datetime.now()})"]

# Common subdomains (small list for demo, extend if needed)
subdomains = [
    "www", "mail", "ftp", "admin", "login", "test", "dev", "api",
    "staging", "blog", "shop", "secure", "vpn", "web", "portal"
]

# Check DNS resolution and HTTP status
for sub in subdomains:
    subdomain = f"{sub}.{target}"
    try:
        # Try resolving subdomain
        ip = socket.gethostbyname(subdomain)
        result = f"[+] {subdomain}: {ip}"
        results.append(result)
        
        # Check HTTP/HTTPS response
        for proto in ["http", "https"]:
            url = f"{proto}://{subdomain}"
            try:
                r = requests.get(url, timeout=3, allow_redirects=False)
                result = f"  └─ {url}: Status {r.status_code}"
                results.append(result)
            except requests.RequestException:
                results.append(f"  └─ {url}: No response")
    except socket.gaierror:
        results.append(f"[-] {subdomain}: No DNS resolution")

results.append("[*] Recon completed!")

# Print to terminal
for line in results:
    print(line)

# Save to file if --output is specified
if args.output:
    try:
        with open(args.output, "w") as f:
            f.write("\n".join(results) + "\n")
        print(f"[+] Results saved to {args.output}")
    except Exception as e:
        print(f"[-] Error saving to file: {e}")
