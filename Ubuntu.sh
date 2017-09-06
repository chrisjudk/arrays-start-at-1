#!/bin/bash
# Get updates
echo "getting updates"
apt-get update
# Install Uncomplicated Firewall (UFW)
echo "installing Uncomplicated firewall"
apt-get install ufw -y
# Upgrade all installed packages
echo "installing updates"
apt-get upgrade -y
# Clean up unnecessary junk
echo "running autoclean and autoremove"
apt-get autoclean
apt-get autoremove -y
# enable UFW
echo "enabling UFW"
ufw enable
# make log dir
echo "creating /var/local"
mkdir /var/local/
# Create/clear log file
echo "creating log file in /var/local"
echo -n "" > /var/local/ASAO.log
# Add additional instructions to log file
echo "adding instructions to log file"
echo "getent group <groupname> |||| Users in group" >> /var/local/ASAO.log
echo "/etc/pam.d/common-password	minlen-8 |||| password length" >> /var/local/ASAO.log
echo "/etc/login.defs |||| Password expiration" >> /var/local/ASAO.log
echo "/etc/ssh/sshd_config	PermitRootLogin no' |||| Disable Root Login" >> /var/local/ASAO.log
echo "Don't Forget to Restart"
echo "more password stuff @ https://www.cyberciti.biz/tips/linux-check-passwords-against-a-dictionary-attack.html"
# Install libpam-cracklib which is used to check passwords
echo "installing libpam-cracklib for passwords"
apt-get install libpam-cracklib -y
