# Arrays start at 1
This project is for the "Arrays start at 1" CP team at greenbrier high school.
# How To Use
## Linux
1. Switch to the /home/\<User\>/Downloads directory
```bash
cd ~/Downloads
```
2. Download the Ubuntu.sh file
	- Stable version
		```bash
		wget https://raw.githubusercontent.com/chrisjudk/arrays-start-at-1/master/Ubuntu.sh
		```
	- Testing version
		```bash
		wget https://raw.githubusercontent.com/chrisjudk/arrays-start-at-1/testing/Ubuntu.sh https://raw.githubusercontent.com/chrisjudk/arrays-start-at-1/testing/Ubuntu.conf
		```
3. Change ownership to root user
```bash
sudo chown root:root ./Ubuntu.sh ./Ubuntu.conf
```
4. Change execute permissions to 770
```bash
sudo chmod 770 ./Ubuntu.sh ./Ubuntu.conf
```
5. Run the file
```bash
sudo ./Ubuntu.sh
```
