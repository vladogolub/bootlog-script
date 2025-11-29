#!/bin/bash
# Boot-log installer – run as root on any Ubuntu/Debian machine

cat > /usr/local/bin/save-boot-log <<'SCRIPT'
#!/usr/bin/bash
BOOTLOG_DIR="/var/log/boot-logs"
mkdir -p "$BOOTLOG_DIR"
KEEP=3
CURRENT_BOOT_ID=$(cat /proc/sys/kernel/random/boot_id 2>/dev/null || echo "unknown")
TIMESTAMP=$(date +"%Y-%m-%d_%H%M%S")
BOOT_LOG="$BOOTLOG_DIR/boot-${TIMESTAMP}_bootid-${CURRENT_BOOT_ID:0:8}.log"
journalctl --boot --quiet > "$BOOT_LOG"
cd "$BOOTLOG_DIR" && ls -t boot-*.log 2>/dev/null | tail -n +$((KEEP + 1)) | xargs -r rm -f
echo "Boot log saved to $BOOT_LOG"
SCRIPT

chmod +x /usr/local/bin/save-boot-log

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
echo "Boot-log setup complete – reboot to test"
