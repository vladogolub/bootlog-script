#!/bin/bash
# bootlog-script installer – now 100% immune to wrong bash path
# run as root on any Ubuntu/Debian box

set -e

# Find where bash actually lives (works everywhere)
BASH_PATH=$(which bash || command -v bash || echo "/bin/bash")  # fallback safety

echo "Installing save-boot-log script (using bash at $BASH_PATH)..."

cat > /usr/local/bin/save-boot-log <<EOF
#!$BASH_PATH
# Clean per-boot journal capture – keeps last 3 boots only

BOOTLOG_DIR="/var/log/boot-logs"
mkdir -p "\$BOOTLOG_DIR"
KEEP=3

CURRENT_BOOT_ID=\$(cat /proc/sys/kernel/random/boot_id 2>/dev/null || echo "unknown")
TIMESTAMP=\$(date +"%Y-%m-%d_%H%M%S")
BOOT_LOG="\$BOOTLOG_DIR/boot-\${TIMESTAMP}_bootid-\${CURRENT_BOOT_ID:0:8}.log"

journalctl --boot --quiet > "\$BOOT_LOG"

cd "\$BOOTLOG_DIR" && \\
    ls -t boot-*.log 2>/dev/null | tail -n +\$((KEEP + 1)) | xargs -r rm -f || true

echo "Boot log saved to \$BOOT_LOG"
EOF

chmod 755 /usr/local/bin/save-boot-log

# systemd service (unchanged)
cat > /etc/systemd/system/save-boot-log.service <<'SERVICE'
[Unit]
Description=Save clean boot log for current boot
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/save-boot-log
StandardOutput=journal

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable --now save-boot-log.service

echo "bootlog-script installed successfully!"
echo "Logs will appear in /var/log/boot-logs/ after next reboot"
echo "You can test right now with: /usr/local/bin/save-boot-log"
