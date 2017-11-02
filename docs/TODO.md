# To Do
## Linux
- [ ] automate adding users and changing passwords?
- [x] correct the sed command for "Permit root login"
- [x] append the following to /etc/pam.d/common-auth
    ```bash
    auth required pam_tally2.so deny=5 onerr=fail unlock_time=1800
    ```
- [ ] add check for sudoers
- [x] edit /etc/lightdm/users.conf
    ```bash
    allow-guest=false
    ```
- [x] create a ~~menu system~~ config file rather than just autorun
- [ ] setup auditing
  - [x] Install auditd
  - [ ] configure /etc/audit/auditd.conf
- [ ] group management
## Windows
- [ ] start working on powershell script
