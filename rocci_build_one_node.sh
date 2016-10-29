#!/bin/bash

#rocci_build_ec2.sh 

#set -x

#required executed as root 
USER=`whoami`
if [ "root" != "$USER" ]
then
  printf "pls execute as root! \n"
  exit
fi

###########################
#update system firstly
###########################
#apt-get update
#apt-get -y upgrade
if [ ! -f /etc/localtime_org ]
then
  printf "\n
  ###########################
  update system          
  ###########################
  \n"
  apt-get update
  apt-get -y upgrade
fi


###########################
#test expect
###########################
#expect <<EOF
#exit
#expect eof
#EOF
expect -v
if [ 0 -ne $? ]
then
  printf "\nGoing to install expect firstly !\n"
  printf "\napt-get -y install expect\n"
  apt-get -y install expect
fi


###########################
#create swap
###########################
SWAP=`swapon -s | grep -v "Filename"`
if [ "-" = "-$SWAP" ]
then
  mkdir /opt/images/
  rm -rf /opt/images/swap
  dd if=/dev/zero of=/opt/images/swap bs=1024 count=2048000
  mkswap /opt/images/swap
  swapon /opt/images/swap
  echo "/opt/images/swap  swap  swap  sw  0  0" >> /etc/fstab
fi

###########################
#prepare system
###########################
if [ ! -f /etc/default/locale_org ]
then
  cp /etc/default/locale /etc/default/locale_org
  printf "LANGUAGE=\"en_US.UTF-8\"
LC_ALL=\"en_US.UTF-8\"
LANG=\"en_US.UTF-8\"" > /etc/default/locale
fi

if [ ! -f /etc/localtime_org ]
then
  cp /etc/localtime /etc/localtime_org
  cp /usr/share/zoneinfo/America/Toronto /etc/localtime
  ntpdate cn.pool.ntp.org
  printf "\nGoing to reboot and continue after reboot !\n"
  reboot
  exit
fi


#################################
#optional install openssh-server
#################################
#apt-get install openssh-server

#####################################
#install opennebula front-end node
#####################################

##########################################################################
#ruby runtime installation along with opennebula installation
##########################################################################

#############################
#config sunstone-server.conf
#############################

##################################################################
#install opennebula node (together with front-end node)
##################################################################

printf "\n
###########################################
install node (away from front-end node)
###########################################
\n"

wget -q -O- http://downloads.opennebula.org/repo/Ubuntu/repo.key | apt-key add -
echo "deb http://downloads.opennebula.org/repo/4.10/Ubuntu/14.04/ stable opennebula" > /etc/apt/sources.list.d/opennebula.list

apt-get update
apt-get -y install opennebula-node nfs-common bridge-utils


#####################################
#config SSH public key
#####################################

printf "\n
#####################################
config SSH public key
#####################################
\n"

su - oneadmin <<EOF
cp ~/.ssh/id_rsa.pub ~/.ssh/authorized_keys
cat <<EOT > ~/.ssh/config 
Host * 
    StrictHostKeyChecking no 
    UserKnownHostsFile /dev/null 
EOT
chmod 600 ~/.ssh/config
exit
EOF

##################################################################
#config network
##################################################################

printf "\n
###########################################
config network
###########################################
\n"

if [ ! -f /etc/network/interfaces_org ]
then
  cp /etc/network/interfaces /etc/network/interfaces_org
  cat <<EOT > /etc/network/interfaces
auto lo 
iface lo inet loopback 

auto br0 
iface br0 inet dhcp 
        bridge_ports eth0 
        bridge_fd 9 
        bridge_hello 2 
        bridge_maxage 12 
        bridge_stp off

EOT
  /etc/init.d/networking restart
fi


#####################################
#config NFS for node
#####################################

echo "192.168.0.16:/var/lib/one/  /var/lib/one/  nfs   soft,intr,rsize=8192,wsize=8192,noauto" >> /etc/fstab
mount /var/lib/one/


#####################################
#config Qemu for node
#####################################

cat << EOT > /etc/libvirt/qemu.conf
user  = "oneadmin"
group = "oneadmin"
dynamic_ownership = 0
EOT

service libvirt-bin restart


##########################################################################
#create certificates
##########################################################################


#####################################
#install rocci-server from source
#####################################


#####################################
#config opennebula backend
#####################################


#####################################
#End restart apache2
#####################################
#####################################
#config samba
#####################################



printf "\n
###########################################
End of rocci_build.sh !
###########################################
Do not forget to replace 192.168.1.16 with
the real ip of frontend for NFS configuration
in /ect/fstab and then 'mount /var/lib/one/'
! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !
##########################################
\n"



exit







