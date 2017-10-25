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

# Create/clear log files
echo "creating log files in /var/local"
echo -n "" > /var/local/netstat.log
echo -n "" > /var/local/ASAO.log
echo -n "" > /var/local/mediafiles.log
echo -n "" > /var/local/cronjoblist.log

# Add additional instructions to log file
echo "adding instructions to log file"
echo "getent group <groupname> |||| Users in group" >> /var/local/ASAO.log
echo "Don't Forget to Restart" >> /var/local/ASAO.log
echo "more password stuff @ https://www.cyberciti.biz/tips/linux-check-passwords-against-a-dictionary-attack.html" >> /var/local/ASAO.log

# Install libpam-cracklib which is used to check passwords
echo "installing libpam-cracklib for passwords"
apt-get install libpam-cracklib -y

# Pam config
echo "changing PAM config"
# grep for 'pam_unix.so' and get line number
PAMUNIX="$(grep -n 'pam_unix.so' /etc/pam.d/common-password | grep -v '#' | cut -f1 -d:)"
sed -e "${PAMUNIX}s/.*/password	[success=1 default=ignore]	pam_unix.so obscure use_authtok try_first_pass sha512 remember=5/" /etc/pam.d/common-password > /var/local/temp.txt
#grep for 'pam_cracklib.so' and get line number
PAMCRACKLIB="$(grep -n 'pam_cracklib.so' /etc/pam.d/common-password | grep -v '#' | cut -f1 -d:)"
sed -e "${PAMCRACKLIB}s/.*/password	requisite	pam_cracklib.so retry=3 minlen=8 difok=3 ucredit=-1 1credit=-2 ocredit=-1/" /var/local/temp.txt > /var/local/temp2.txt
rm /var/local/temp.txt
cp /etc/pam.d/common-password /etc/pam.d/common-password.old
mv /var/local/temp2.txt /etc/pam.d/common-password

# Password aging policy
echo "setting passwords to reset after 30 days"
PASSMAX="$(grep -n 'PASS_MAX_DAYS' /etc/login.defs | grep -v '#' | cut -f1 -d:)"
sed -e "${PASSMAX}s/.*/PASS_MAX_DAYS	90/" /etc/login.defs > /var/local/temp1.txt
PASSMIN="$(grep -n 'PASS_MIN_DAYS' /etc/login.defs | grep -v '#' | cut -f1 -d:)"
sed -e "${PASSMIN}s/.*/PASS_MIN_DAYS	10/" /var/local/temp1.txt > /var/local/temp2.txt
PASSWARN="$(grep -n 'PASS_WARN_AGE' /etc/login.defs | grep -v '#' | cut -f1 -d:)"
sed -e "${PASSWARN}s/.*/PASS_WARN_AGE	7/" /var/local/temp2.txt > /var/local/temp3.txt
cp /etc/login.defs /etc/login.defs.old
mv /var/local/temp3.txt /etc/login.defs
rm /var/local/temp1.txt /var/local/temp2.txt

# Password Lockout
echo "auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800" >> /etc/pam.d/common-auth

# SSH daemon config
echo "disabling root login"
# get the line number of the PermitRootLogin line
PRL="$(grep -n 'PermitRootLogin' etc/ssh/sshd_config | grep -v '#' | cut -f1 -d:)"
sed -e "${PRL}s/.*/PermitRootLogin no/" /etc/ssh/sshd_config> /var/local/temp1.txt
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.old
mv /var/local/temp1.txt /etc/ssh/sshd_config

# Disable the guest account
echo "disabling guest account"
echo "allow-guest=false" >> /etc/lightdm/lightdm.conf

# Find all video files
echo "Finding Media Files"
echo "||||Video Files||||" >> /var/local/mediafiles.log
locate *.mkv *.webm *.flv *.vob *.ogv *.drc *.gifv *.mng *.avi$ *.mov *.qt *.wmv *.yuv *.rm *.rmvb *.asf *.amv *.mp4$ *.m4v *.mp *.m?v *.svi *.3gp *.flv *.f4v >> /var/local/mediafiles.log
echo "||||Audo Files||||" >> /var/local/mediafiles.log
locate *.3ga *.aac *.aiff *.amr *.ape *.arf *.asf *.asx *.cda *.dvf *.flac *.gp4 *.gp5 *.gpx *.logic *.m4a *.m4b *.m4p *.midi *.mp3 *.pcm *.rec *.snd *.sng *.uax *.wav *.wma *.wpl *.zab >> /var/local/mediafiles.log

# Lists all cronjobs & output to /var/local/cronjoblist.log
echo "Outputting cronjobs to /var/local/cronjoblist.log"
crontab -l >> /var/local/cronjoblist.log

# List all connections, open or listening
echo "finding open connections and outputting to /var/local/netstat.log"
ss -an4 > /var/local/netstat.log

# Install clam antivirus
echo "installing clam antivirus"
apt-get install clamav -y

# Update clam signatures
echo "updating clam signatures"
freshclam

# Run a full scan of the "/home" directory
echo "running full scan of /home directory"
clamscan -r /home
