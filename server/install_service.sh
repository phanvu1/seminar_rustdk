#!/bin/bash
set -e
cat << 'EOF' > /etc/systemd/system/vynex-device-sync.service
[Unit]
Description=Vynex WireGuard Realtime Device Status Daemon
After=docker.service
Requires=docker.service

[Service]
Type=simple
User=lead
ExecStart=/usr/bin/python3 /home/lead/vynex_device_sync.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable vynex-device-sync
systemctl restart vynex-device-sync
systemctl status vynex-device-sync --no-pager
