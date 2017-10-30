#!/bin/bash
if [ -r Ubuntu.conf ]; then
  #Load Config Values
  source Ubuntu.conf

  # Get updates
  if [ "$UPDATES" = true ]; then
    echo "getting updates"
    apt-get update
  fi
  #Install and enable auditing
  if [ "$AUDITING" = true ]; then
    echo "Installing auditing daemon"
    apt-get install auditd
    echo "enabling auditing"
    auditctl -e 1 > /var/local/audit.log
  fi

  # Install Uncomplicated Firewall (UFW)
  if [ "$FIREWALL" = true ]; then
    echo "installing Uncomplicated firewall"
    apt-get install ufw -y
  fi

  # Install openssh-server
  if [ "$INSTALL_SSH_SERVER" = true ]; then
    apt-get install openssh-server -y
  fi
  # Upgrade all installed packages
  if [ "$UPGRADES" = true ]; then
  echo "installing updates"
  apt-get upgrade -y
  fi

  # Clean up unnecessary junk
  if [ "$CLEAN" = true ]; then
    echo "running autoclean and autoremove"
    apt-get autoclean
    apt-get autoremove -y
  fi

  # enable UFW
  if [ "$FIREWALL" = true ]; then
    echo "enabling UFW"
    ufw enable
  fi

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
  echo "edit /etc/audit/auditd.conf" >> /var/local/ASAO.log
  echo "Don't Forget to Restart" >> /var/local/ASAO.log
  echo "more password stuff @ https://www.cyberciti.biz/tips/linux-check-passwords-against-a-dictionary-attack.html" >> /var/local/ASAO.log

  # Install libpam-cracklib which is used to check passwords
  if [ "$LPAMCLIB" = true ]; then
    echo "installing libpam-cracklib for passwords"
    apt-get install libpam-cracklib -y
  fi

  # Pam config
  if [ "$PAMCONF" = true ]; then
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
  fi

  # Password aging policy
  if [ "$PSAGE" = true ]; then
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
  fi

  # Password Lockout
  if [ "$PSLOCKOUT" = true ]; then
    echo "auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800" >> /etc/pam.d/common-auth
  fi

  # SSH daemon config
  if [ "$DISABLE_ROOT_SSH" = true ]; then
    echo "disabling root login"
    # get the line number of the PermitRootLogin line
    PRL="$(grep -n 'PermitRootLogin' etc/ssh/sshd_config | grep -v '#' | cut -f1 -d:)"
    sed -e "${PRL}s/.*/PermitRootLogin no/" /etc/ssh/sshd_config> /var/local/temp1.txt
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.old
    mv /var/local/temp1.txt /etc/ssh/sshd_config
  fi

  # Disable the guest account
  if [ "$DISABLE_GUEST" = true ]; then
    echo "disabling guest account"
    echo "allow-guest=false" >> /etc/lightdm/lightdm.conf
  fi

  # Find all video files
  if [ "$MEDIA_LOCATIONS" = true ]; then
    echo "Finding Media Files"
    echo "||||Video Files||||" >> /var/local/mediafiles.log
    locate *.mkv *.webm *.flv *.vob *.ogv *.drc *.gifv *.mng *.avi$ *.mov *.qt *.wmv *.yuv *.rm *.rmvb *.asf *.amv *.mp4$ *.m4v *.mp *.m?v *.svi *.3gp *.flv *.f4v >> /var/local/mediafiles.log
    echo "||||Audo Files||||" >> /var/local/mediafiles.log
    locate *.3ga *.aac *.aiff *.amr *.ape *.arf *.asf *.asx *.cda *.dvf *.flac *.gp4 *.gp5 *.gpx *.logic *.m4a *.m4b *.m4p *.midi *.mp3 *.pcm *.rec *.snd *.sng *.uax *.wav *.wma *.wpl *.zab >> /var/local/mediafiles.log
  fi

  # Lists all cronjobs & output to /var/local/cronjoblist.log
  if [ "$LOG_CRON" = true ]; then
    echo "Outputting cronjobs to /var/local/cronjoblist.log"
    crontab -l >> /var/local/cronjoblist.log
  fi

  # List all connections, open or listening
  if [ "$LOG_NETSTAT" = true ]; then
    echo "finding open connections and outputting to /var/local/netstat.log"
    ss -an4 > /var/local/netstat.log
  fi

  # Install clam antivirus
  if [ "$INSTALL_CLAM" = true ]; then
    echo "installing clam antivirus"
    apt-get install clamav -y
  fi

  # Run clamav
  if [ "$CLAM_HOME" = true ]; then
    # Update clam signatures
    echo "updating clam signatures"
    freshclam

    # Run a full scan of the "/home" directory
    echo "running full scan of /home directory"
    clamscan -r /home
  fi
elif [ -f Ubuntu.conf ]; then
  echo "The file 'Ubuntu.conf' exists but is not readable to the script"
else
  echo "The file 'Ubuntu.conf' is missing. Please download it before running the script"
fi
