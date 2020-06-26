#!/bin/bash

#REQUIREMENTS:
#--------------
#--------------

#1. DOWNLOADING OUR SOFTWARE(Packer and Terraform).
#----------------------------
#----------------------------

#VERY VERY IMPORTANT!
#Urls and versions for Packer and Terraform may change so check these urls:
#https://www.packer.io/downloads.html --> for Packer
#https://learn.hashicorp.com/terraform/getting-started/install
export VERSION_NUM="1.6.0"
wget https://releases.hashicorp.com/packer/${VERSION_NUM}/packer_${VERSION_NUM}_linux_amd64.zip
wget https://releases.hashicorp.com/terraform/${VERSION_NUM}/terraform_${VERSION_NUM}_linux_amd64.zip



#2. INSTALLING OUR SOFTWARE(Terraform, Packer).
#----------------------------------------------------------
#----------------------------------------------------------

#We need a bash function that gets the Operating system we're using and 
#the determines which package manager to use.


#Bash functions do not have return values like other programming languages
#Instead they have a return status which is obtained as $? 
#This is similar to the concept of exit statuses.

function get_os_version(){
	if [ -f /etc/os-release ]; then
		. /etc/os-release #Note that the . is similar to source UNIX command
		OS=$NAME
	elif type lsb_release >/dev/null 2>&1; then
		OS=$(lsb_release -si)
	elif [ -f /etc/lsb-release ]; then
		. /etc/lsb-release 
		OS=$DISTRIB_ID
	elif [ -f /etc/debian_version ]; then
		OS=Debian
	elif [ -f /etc/SuSe-release ]; then
		# Older SuSE/etc.
		OS=OpenSUSE
	elif [ -f /etc/redhat-release ]; then
		# Older Red Hat, CentOS, etc.
		OS=Red-Hat
	else
		# Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
		OS=$(uname -v)
	fi 
	echo $OS 
}



install_for_ubuntu() {
	sudo apt update
	sudo apt install unzip
	sudo apt install python3 python3-pip python3-setuptools
	pip3 install --user ansible
}
install_for_red_hat() {
	sudo yum update -y
	sudo yum install -y epel-release 
	sudo yum install -y unzip
	sudo yum install -y python3 python3-pip 
	sudo yum install ansible
}
install_for_fedora() {
	sudo dnf install unzip
	sudo dnf install python3 python3-pip 
	sudo dnf install ansible
}
install_for_archlinux() {
	sudo pacman -Syyy
	sudo pacman -Sy unzip
	sudo pacman -Sy python3 python3-pip 
	sudo pacman -Sy ansible
}
install_for_suse(){
	sudo zypper install -y unzip
	sudo zypper install -y python3python3-pip 
	pip3 install --user ansible
}

#The command below unzips the Terraform and Packer binaries and moves them to /usr/local/bin
unzip_terraform_and_packer_binaries() {
	unzip terraform_${VERSION_NUM}_linux_amd64.zip
	unzip packer_${VERSION_NUM}_linux_amd64.zip
	sudo chmod +x terraform
	sudo chmod +x packer
	#Move the binaries to directory that is listed as $PATH environment variable
	sudo mv terraform packer /usr/local/bin 
	echo "Succesfully Installed Terraform and Packer"
}


#The return value is moved to a shell variable called os_version.

os_version=$(get_os_version)

if [ $os_version == 'Ubuntu' ] || [ $os_version == 'Debian' ] || [ $os_version == 'Linux Mint' ]; then
	install_for_ubuntu
	unzip_terraform_and_packer_binaries
elif [ $os_version = 'Red-Hat' ] || [ $os_version = 'CentOS' ]; then
	install_for_red_hat
	unzip_terraform_and_packer_binaries
elif [ $os_version = "Fedora" ]; then
	install_for_fedora
	unzip_terraform_and_packer_binaries
elif [ $os_version = 'Arch-Linux' ]; then
	install_for_archlinux
	unzip_terraform_and_packer_binaries
elif [ $os_version = 'OpenSUSE' ];then
	install_for_suse
	unzip_terraform_and_packer_binaries 
else
	echo "Haven't configured for that distro yet"
	exit 1
fi







