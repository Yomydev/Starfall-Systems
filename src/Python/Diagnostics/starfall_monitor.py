import os
import platform
import socket
import subprocess

# [STARFALL CORE SYSTEMS]
# Module: IT Diagnostic Utility
# Description: Validates local environment health and connectivity to game services.

def get_system_info():
    print("--- STARFALL STUDIOS SYSTEM CHECK ---")
    print(f"OS: {platform.system()} {platform.release()}")
    print(f"Processor: {platform.processor()}")
    print(f"Local IP: {socket.gethostbyname(socket.gethostname())}")
    print("-" * 37)

def ping_service(host):
    """Returns True if host responds to a ping request"""
    # Determine parameter based on OS (Windows uses '-n', Unix uses '-c')
    param = "-n" if platform.system().lower() == "windows" else "-c"
    command = ["ping", param, "1", host]
    
    return subprocess.call(command, stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT) == 0

def run_diagnostics():
    get_system_info()
    
    services = {
        "Roblox API": "api.roblox.com",
        "GitHub": "github.com",
        "Discord Gateway": "gateway.discord.gg"
    }

    for name, url in services.items():
        status = "ONLINE" if ping_service(url) else "OFFLINE"
        print(f"[#] {name:15}: {status}")

if __name__ == "__main__":
    run_diagnostics()
