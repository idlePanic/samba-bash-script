#!/bin/bash


# find samba.config
dir=$(pwd)
. $dir/samba.config

# Load config values
echo "$path"
echo "$permission"
echo "$samba_user"


#if file does not exist create file
if [ -d "$path" ] 
then
	echo "directory is exist";
else
	mkdir $path;
fi

#if samba not installed install samba
samba_not_installed=$(dpkg -s samba 2>&1 | grep "not installed")
if [ -n "$samba_not_installed" ];then
  echo "Installing Samba"
  sudo apt-get install samba -y
fi

# config smb.conf
echo "
[share]
comment = This is share folder
path = $path
writable = yes
write list = $samba_user
guest ok = no
"| sudo tee -a /etc/samba/smb.conf


#make permission to share directory

sudo chmod -R  $permission $path

#create samba user if does not exist
if grep "$samba_user" /etc/passwd >/dev/null 2>&1; then
  echo "user is exist already"
  else
	  sudo useradd $samba_user
fi

sudo smbpasswd -a $samba_user;

#restart samba services
sudo /etc/init.d/smbd restart;
