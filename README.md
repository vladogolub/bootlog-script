# bootlog-script  
because i got sick of digging through 10-year-old mixed syslog garbage when something breaks on boot

### what it does
- after every reboot it saves a **clean** journal of exactly that boot  
- keeps only the last 3 boots (so /var/log/boot-logs stays tiny)  
- names them like `boot-2025-11-29_142305_bootid-c3a8f1e2.log`  
- zero dependencies, works on Ubuntu, Debian, whatever still uses systemd

### how to install on any machine (as root, one line)
```bash
curl -Ls https://raw.githubusercontent.com/vladogolub/bootlog-script/main/setup.sh | bash
