# TEMPer Zabbix

Zabbix template and script to monitor temperatures returned by a TEMPer usb stick. This could be useful to check datacenter temperature or as a remote thermometer plugged to a raspberry pi.

## Requirement
- A TEMPer usb stick
- urwen's temper.py script : https://github.com/urwen/temper
- jq
- zabbix sender
- A working Zabbix client with a configured Zabbix agent.

## Setup
### On Zabbix server
- Import the template `template_temper.xml` on the server, then add it to the host equipped with the TEMPer usb device.
### On Zabbix client
- Install the script
```
git clone https://github.com/ThibautPlg/TEMPer-Zabbix.git

mkdir -p /etc/zabbix/scripts

cp TEMPer-Zabbix/TEMPer_zabbix.sh /etc/zabbix/scripts/
chmod 750 /etc/zabbix/scripts/TEMPer_zabbix.sh
chgrp zabbix /etc/zabbix/scripts/TEMPer_zabbix.sh
```
- Customize `TEMPer_zabbix.sh` to match your environment if needed
```
vim /etc/zabbix/scripts/TEMPer_zabbix.sh
```
- Add a crontab entry (user zabbix or root required)
```
# Zabbix TEMPer USB probe
*/1 * * * * /etc/zabbix/scripts/TEMPer_zabbix.sh 1>/dev/null 2>/dev/null
```
