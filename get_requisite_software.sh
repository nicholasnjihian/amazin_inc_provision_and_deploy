#!/bin/bash

#REQUIREMENTS:
--------------
--------------

#We need to install Jenkins for CI-CD
#Jenkins has Java 8 as a dependency so we will also install java.
#We will be using Jenkins CLI rather than the web dashboard
#at port 8080 to achieve a fully automated pipeline.

#We also need Terraform which enables us to specify which 
#resources we need and which cloud provider and then proceed to deploy said resources.

#We also need Packer which we will use to build our AMI images for the 
#AWS EC2 resources. This are the AMI images Terraform will use.
#Our configuration management is done via Shell or Ansible 
#but that is handled within Packer via the Packer's provisioner block.

#1. DOWNLOADING OUR SOFTWARE
----------------------------
----------------------------

#VERY VERY IMPORTANT!
#Urls and versions for Packer and Terraform may change so check these urls:
#https://www.packer.io/downloads.html --> for Packer
#https://learn.hashicorp.com/terraform/getting-started/install
wget https://releases.hashicorp.com/packer/1.6.0/packer_1.6.0_linux_amd64.zip
wget https://releases.hashicorp.com/terraform/0.12.26/terraform_0.12.26_linux_amd64.zip



#2. INSTALLING OUR SOFTWARE(Terraform, Packer and Jenkins).
----------------------------------------------------------
----------------------------------------------------------

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

install_for_ubuntu() {
	sudo apt update
	sudo apt install unzip
}
install_for_red_hat() {
	sudo yum install -y unzip
}
install_for_fedora() {
	sudo dnf install unzip
}
install_for_archlinux() {
	sudo pacman -Syy
	sudo pacman -S unzip
}
install_for_suse(){
	sudo zypper install unzip
}

#The command below unzips the Terraform and Packer binaries and moves them to /usr/local/bin
unzip_terraform_and_packer_binaries() {
	unzip terraform_0.12.26_linux_amd64.zip
	unzip packer_1.6.0_linux_amd64.zip
}




