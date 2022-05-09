#!/bin/bash
#
# init_env.sh v2.0
#
# author: Parker J Swierzewski
# date: 05/09/22
# language: bash
# desc: The script is mainly used to setup my hacking environment. Please note, this script is only meant to be run once and requires 
#        no user interaction (besides executing it). Please be sure to read through the script and make changes to fields that need it (i.e. Github/Git).

# Colors
# Used to make the prompt look nice.
CLEAR=`tput sgr0`
RED=`tput setaf 1`
GREEN=`tput setaf 2`
CYAN=`tput setaf 7`

# Global variables
SCRIPT="init_env"	# The name of the script
USER="username"		# The name of the user.
GROUP=${USER}		# The name of the group.
NAME="NAME"   # Your name (Used for Git).
EMAIL="EMAIL"	    # Your email (Used for Git).
TOKEN="TOKEN HERE" # Github token (Used for authorizing with Github)       

install_package() {
: '
This function will determine if a package is already installed on the
system or not. If it is not installed, it will install it.

@param - A package to be installed.
@return - None.
'
	if [ $(dpkg-query -W -f='${Status}' $1 2>/dev/null | grep -c "ok installed") -eq 0 ];
	then
		printf "[!] ${CYAN}Installing $1...${CLEAR}\n"
		sudo apt install $1 -y
	else
		printf "[!] ${GREEN}$1 is already installed!${CLEAR}\n"
	fi
}

# Root?
# This script makes changes to the system and installs packages. Root privileges are required.
if [ $(whoami) != "root" ]
then
	printf "${RED}This requires root level privileges${CLEAR}!\n"
	printf "${RED}Execute 'sudo bash ${SCRIPT}${CLEAR}!\n"
	exit 1
fi

install_package apt-transport-https
install_package curl
install_package wget

# Sublime Text
# I use Sublime for writing reports and documentation.
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add - &>/dev/null
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list &>/dev/null

# Github (gh)
# Used to authenticate with Github later.
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg &>/dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# First update for the system.
sudo apt update &>/dev/null

# Installs packages
# Some of these packages are installed by default on Kali, but are added just in case.
install_package cherrytree
install_package docker.io
install_package exiftool
install_package freerdp2-x11
install_package gh
install_package git
install_package gobuster
install_package gzip
install_package python3-pip
install_package seclists
install_package socat
install_package sshuttle
install_package sublime-text
install_package terminator
install_package vim
install_package zaproxy

# Popular C2
install_package powershell-empire starkiller

gem install evil-winrm &>/dev/null

# Final update for the system. Just to verify everything is up to date.
sudo apt update &>/dev/null

# Docker
printf "[!] ${CYAN}Verifying docker installed properly...${CLEAR}\n"
sudo systemctl start docker --now
sudo docker run hello-world
printf "[!] ${CYAN}Adding ${USER} to the Docker group${CLEAR}\n"
sudo usermod -aG docker ${USER}

# Unzip Rockyou.txt
printf "[!] ${CYAN}Creating rockyou.txt backup...${CLEAR}\n"
cd /usr/share/wordlists
cp rockyou.txt.gz rockyou.backup.gz
printf "[!] ${CYAN}Unzipping rockyou.txt${CLEAR}\n"
gzip -d rockyou.txt.gz 

# Downloads Useful Tools
cd /opt/
printf "[!] ${GREEN}Downloading linPEAS to /opt/${CLEAR}\n"
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh &>/dev/null
chown ${USER}:${GROUP} linpeas.sh
chmod 700 linpeas.sh

printf "[!] ${GREEN}Downloading winPEAS to /opt/winPEAS${CLEAR}\n"
mkdir winPEAS
cd winPEAS
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winpeas.bat &>/dev/null
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winpeasx64.exe &>/dev/null
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winpeasx86.exe &>/dev/null
cd ..

printf "[!] ${GREEN}Downloading Windows Exploiter Suggester to /opt/windowsexploiter${CLEAR}\n"
mkdir windowsexploiter
cd windowsexploiter
curl -o old-windows-exploit-suggester.py https://raw.githubusercontent.com/AonCyberLabs/Windows-Exploit-Suggester/master/windows-exploit-suggester.py &>/dev/null
./old-windows-exploit-suggester.py –update
git clone https://github.com/bitsadmin/wesng --depth 1
cd wesng
./wes.py --update
cd /opt/

printf "[!] ${GREEN}Downloading PowerUp.ps1 to /opt/${CLEAR}\n"
wget https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1 &>/dev/null
chown ${USER}:${GROUP} PowerUp.ps1
chmod 700 PowerUp.ps1

printf "[!]${GREEN}Downloading PHP reverse shell to /opt/${CLEAR}\n"
curl -o rshell.php https://raw.githubusercontent.com/pentestmonkey/php-reverse-shell/master/php-reverse-shell.php &>/dev/null
chown ${USER}:${GROUP} rshell.php
chmod 700 rshell.php

printf "[!]${GREEN}Downloading Chisel to /opt/chisel${CLEAR}\n"
mkdir chisel
cd chisel
wget https://github.com/jpillora/chisel/releases/download/v1.7.3/chisel_1.7.3_linux_amd64.gz -q &>/dev/null
wget https://github.com/jpillora/chisel/releases/download/v1.7.3/chisel_1.7.3_windows_amd64.gz -q &>/dev/null
gunzip * &>/dev/null
cd ..

printf "[!]${GREEN}Downloading GitTools to /opt/GitTools${CLEAR}\n"
git clone https://github.com/internetwache/GitTools &>/dev/null

printf "[!]${GREEN}Downloading Dive to /opt/${CLEAR}\n"
wget https://github.com/wagoodman/dive/releases/download/v0.9.2/dive_0.9.2_linux_amd64.deb
apt install "./dive_0.10.0_linux_amd64.deb"

# Updates file owner and permissions
printf "[!]${GREEN}Updating file permissions in /opt/${CLEAR}\n"
chown -R ${USER}:${GROUP} ./GitTools ./chisel ./windowsexploiter ./winPEAS
chmod -R 700 ./GitTools ./chisel ./windowsexploiter ./winPEAS

cd ~

# Authenticate with Github
#printf "[!] ${CYAN}Attempting to authenticate with Github...${CLEAR}\n"
#gh auth login --with-token ${TOKEN}

# Setup Git Config 
#printf "[!] ${CYAN}Setting up Git config...${CLEAR}\n"
#git config --global user.name "$NAME"
#git config --global user.email "$EMAIL"
#git config --list

printf "Restarting in five seconds..."
sleep 5
/sbin/shutdown -r now