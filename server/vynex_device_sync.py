#!/usr/bin/env python3
import subprocess
import time
import sys

def get_wireguard_status():
    try:
        out = subprocess.check_output(
            ["docker", "exec", "vynex-wireguard", "wg", "show", "wg0", "dump"],
            universal_newlines=True,
            timeout=5
        )
        status_map = {}
        now = int(time.time())
        lines = out.strip().splitlines()
        for line in lines[1:]:
            parts = line.split('\t')
            if len(parts) >= 5:
                allowed_ips = parts[3]
                handshake = int(parts[4])
                ip = allowed_ips.split('/')[0]
                # Coi là online nếu có bắt tay trong vòng 180s (3 phút)
                is_online = (handshake > 0) and ((now - handshake) < 180)
                status_map[ip] = is_online
        return status_map
    except Exception as e:
        return {}

def update_mysql(status_map):
    for ip, is_online in status_map.items():
        st = "online" if is_online else "offline"
        sql = f"UPDATE RemoteDesktopDB_v3.Devices SET status = '{st}', last_online = IF('{st}'='online', NOW(), last_online) WHERE ip_address = '{ip}' AND status != '{st}';"
        try:
            subprocess.run(
                ["docker", "exec", "vynex_db", "mysql", "-uroot", "-pvynex123", "-e", sql],
                check=False,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
        except Exception:
            pass

def main():
    print("Vynex WireGuard Device Status Sync Daemon Started", flush=True)
    while True:
        try:
            status_map = get_wireguard_status()
            if status_map:
                update_mysql(status_map)
        except Exception:
            pass
        time.sleep(5)

if __name__ == "__main__":
    main()
