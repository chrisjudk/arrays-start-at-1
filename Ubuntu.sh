#!/bin/bash
# Get updates
apt-get update
# Install Uncomplicated Firewall (UFW)
apt-get install ufw -y
# Upgrade all installed packages
apt-get upgrade -y
# Clean up unnecessary junk
apt-get autoclean
apt-get autoremove -y
# enable UFW
ufw enable
# make log dir
mkdir /var/local/
# Create/clear log file
echo -n "" > /var/local/cjudkins.log
# Add additional instructions to log file
echo "getent group <groupname> |||| Users in group" >> /var/local/cjudkins.log
echo "/etc/pam.d/common-password	minlen-8 |||| password length" >> /var/local/cjudkins.log
echo "/etc/login.defs |||| Password expiration" >> /var/local/cjudkins.log
echo "/etc/ssh/sshd_config	PermitRootLogin no' |||| Disable Root Login" >> /var/local/cjudkins.log
echo "Don't Forget to Restart"
echo "more password stuff @ https://www.cyberciti.biz/tips/linux-check-passwords-against-a-dictionary-attack.html"
# Install libpam-cracklib which is used to check passwords
# apt-get install libpam-cracklib -y
