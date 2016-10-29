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

printf "\n
#####################################
install opennebula front-end node
#####################################
\n"

wget -q -O- http://downloads.opennebula.org/repo/Ubuntu/repo.key | apt-key add -
echo "deb http://downloads.opennebula.org/repo/4.10/Ubuntu/14.04/ stable opennebula" > /etc/apt/sources.list.d/opennebula.list

apt-get update
apt-get install opennebula opennebula-sunstone nfs-kernel-server -y
#apt-get install opennebula opennebula-sunstone
#expect <<EOF
#set timeout 600
#spawn apt-get install opennebula opennebula-sunstone
#expect "*\]"
#send "y\r"
#expect eof
#EOF



##########################################################################
#ruby runtime installation along with opennebula installation
##########################################################################

printf "\n
#####################################
install ruby runtime
#####################################
\n"

expect <<EOF
set timeout -1
spawn /usr/share/one/install_gems
expect "*continue..."
send "\r"
expect "*\]"
send "y\r"
expect "*continue..."
send "\r"
expect eof
EOF

#############################
#config sunstone-server.conf
#############################

printf "\n
#####################################
config sunstone-server.conf
#####################################
\n"

if [ ! -f /etc/one/sunstone-server.conf_org ]
then
  cp /etc/one/sunstone-server.conf /etc/one/sunstone-server.conf_org
  sed -i 's/:host: 127.0.0.1/:host: 0.0.0.0/g' /etc/one/sunstone-server.conf
fi

/etc/init.d/opennebula-sunstone restart


#####################################
#config NFS for frontend
#####################################

echo "/var/lib/one/ *(rw,sync,no_subtree_check,root_squash)" >> /etc/exports
service nfs-kernel-server restart


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
#install opennebula node (together with front-end node)
##################################################################

printf "\n
###########################################
install node (together with front-end node)
###########################################
\n"

wget -q -O- http://downloads.opennebula.org/repo/Ubuntu/repo.key | apt-key add -
echo "deb http://downloads.opennebula.org/repo/4.10/Ubuntu/14.04/ stable opennebula" > /etc/apt/sources.list.d/opennebula.list

apt-get update
apt-get -y install opennebula-node bridge-utils


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

printf "\n
###########################################
create certificates
###########################################
\n"

mkdir /etc/grid-security/
cp /usr/lib/ssl/misc/CA.sh /etc/grid-security/
cd /etc/grid-security/

expect <<EOF
set timeout 600
spawn /etc/grid-security/CA.sh -newca
expect "*)"
send "\r"
expect "*Enter PEM pass phrase:"
send "occipem\r"
expect "*Verifying - Enter PEM pass phrase:"
send "occipem\r"
expect "*\]:"
send "cn\r"
expect "*\]:"
send "cn\r"
expect "*\]:"
send "cn\r"
expect "*\]:"
send "cn\r"
expect "*\]:"
send "cn\r"
expect "*\]:"
send "localhost\r"
expect "*\]:"
send "stallmanliu@gmail.com\r"
expect "*\]:"
send "occicr\r"
expect "*\]:"
send "\r"
expect "*cakey.pem:"
send "occipem\r"
expect eof
EOF

expect <<EOF
set timeout 600
spawn openssl genrsa -des3 -out server.key 1024
expect "*Enter pass phrase for server.key:"
send "occisk\r"
expect "*:"
send "occisk\r"
expect eof
EOF

expect <<EOF
set timeout 600
spawn openssl req -new -key server.key -out server.csr
expect "*Enter pass phrase for server.key:"
send "occisk\r"
expect "*\]:"
send "cn\r"
expect "*\]:"
send "cn\r"
expect "*\]:"
send "cn\r"
expect "*\]:"
send "cn\r"
expect "*\]:"
send "cn\r"
expect "*\]:"
send "localhost\r"
expect "*\]:"
send "stallmanliu@gmail.com\r"
expect "*\]:"
send "occiscr\r"
expect "*\]:"
send "\r"
expect eof
EOF

cp server.csr newreq.pem

expect <<EOF
set timeout 600
spawn /etc/grid-security/CA.sh -sign
expect "*cakey.pem:"
send "occipem\r"
expect "*\]:"
send "y\r"
expect "*\]"
send "y\r"
expect eof
EOF

cp newcert.pem server.crt
cp demoCA/cacert.pem cacert.pem
cp cacert.pem ca.crt
cd

#####################################
#install rocci-server from source
#####################################


printf "\n
###########################################
install rocci-server from source
###########################################
\n"


apt-get update

apt-get install -y git ruby-dev libssl-dev memcached

apt-get install -y libcurl4-openssl-dev \
apache2-mpm-worker libapr1-dev \
libaprutil1-dev apache2-prefork-dev \
build-essential libapache2-modsecurity

gem install bundler

adduser --system --disabled-password --group \
--shell /bin/sh --home /var/lib/rocci rocci

mkdir -p /opt/rOCCI-server
git clone https://github.com/EGI-FCTF/rOCCI-server.git /opt/rOCCI-server
cd /opt/rOCCI-server
git checkout 1.1.x
chown -R rocci:rocci /opt/rOCCI-server

ln -sf /opt/rOCCI-server/log /var/log/rocci-server
ln -sf /opt/rOCCI-server/etc /etc/rocci-server

#to avoid error "bundle install after changing gemfile"
#bundle install --deployment VS --no-deployment
bundle install --without development test
bundle install --deployment --without development test
bundle exec passenger-install-apache2-module --auto
bundle exec passenger-install-apache2-module --snippet > /opt/rOCCI-server/passenger.load

cp /opt/rOCCI-server/examples/etc/apache2/sites-available/occi-ssl /etc/apache2/sites-available/occi-ssl.conf
chmod o-rwx /etc/apache2/sites-available/occi-ssl.conf
echo Listen 11443 >> /etc/apache2/ports.conf
cp /opt/rOCCI-server/examples/etc/apache2/conf.d/security /etc/apache2/conf-available/
cp /opt/rOCCI-server/passenger.load /etc/apache2/mods-available/

a2enmod passenger
a2enmod ssl
a2enmod security2
a2ensite occi-ssl

#service apache2 restart

#####################################
#config opennebula backend
#####################################


printf "\n
###########################################
config opennebula backend
###########################################
\n"

su - oneadmin <<EOF
oneuser create rocci 'rocci' --driver server_cipher
oneuser chgrp rocci oneadmin
exit
EOF

if [ ! -f /etc/apache2/sites-available/occi-ssl.conf_org ]
then
  cp /etc/apache2/sites-available/occi-ssl.conf /etc/apache2/sites-available/occi-ssl.conf_org
fi

sed -i 's/SSLCertificateFile/#SSLCertificateFile/g' /etc/apache2/sites-available/occi-ssl.conf
sed -i '/#SSLCertificateFile/a\    SSLCertificateFile /etc/grid-security/server.crt' /etc/apache2/sites-available/occi-ssl.conf 

sed -i 's/SSLCertificateKeyFile/#SSLCertificateKeyFile/g' /etc/apache2/sites-available/occi-ssl.conf
sed -i '/#SSLCertificateKeyFile/a\    SSLCertificateKeyFile /etc/grid-security/server.key' /etc/apache2/sites-available/occi-ssl.conf 

sed -i 's/SSLCACertificatePath/#SSLCACertificatePath/g' /etc/apache2/sites-available/occi-ssl.conf 
sed -i '/#SSLCACertificatePath/a\    SSLCACertificatePath /etc/grid-security\n    SSLCACertificateFile /etc/grid-security/cacert.pem' /etc/apache2/sites-available/occi-ssl.conf 

sed -i 's/SSLCARevocationPath/#SSLCARevocationPath/g' /etc/apache2/sites-available/occi-ssl.conf 
sed -i '/#SSLCARevocationPath/a\    SSLCARevocationPath /etc/grid-security' /etc/apache2/sites-available/occi-ssl.conf 

sed -i 's/SetEnv ROCCI_SERVER_BACKEND/#SetEnv ROCCI_SERVER_BACKEND/g' /etc/apache2/sites-available/occi-ssl.conf 
sed -i '/#SetEnv ROCCI_SERVER_BACKEND/a\    SetEnv ROCCI_SERVER_BACKEND               opennebula' /etc/apache2/sites-available/occi-ssl.conf

sed -i 's/SetEnv ROCCI_SERVER_ONE_PASSWD/#SetEnv ROCCI_SERVER_ONE_PASSWD/g' /etc/apache2/sites-available/occi-ssl.conf 
sed -i '/#SetEnv ROCCI_SERVER_ONE_PASSWD/a\    SetEnv ROCCI_SERVER_ONE_PASSWD       rocci' /etc/apache2/sites-available/occi-ssl.conf 

sed -i 's/ServerName/#ServerName/g' /etc/apache2/sites-available/occi-ssl.conf 
sed -i '/#ServerName/a\    ServerName                           rocci-server.example.com' /etc/apache2/sites-available/occi-ssl.conf 

#sed -i 's/Allow from all/#Allow from all/g' /etc/apache2/sites-available/occi-ssl.conf 
sed -i '/Allow from all/a\        AllowOverride all\n        Require all granted' /etc/apache2/sites-available/occi-ssl.conf 

sed -i 's/SetEnv ROCCI_SERVER_HOSTNAME/#SetEnv ROCCI_SERVER_HOSTNAME/g' /etc/apache2/sites-available/occi-ssl.conf 
sed -i '/#SetEnv ROCCI_SERVER_HOSTNAME/a\    SetEnv ROCCI_SERVER_HOSTNAME              rocci-server.example.com' /etc/apache2/sites-available/occi-ssl.conf 

#####################################
#End restart apache2
#####################################
cat <<EOF > /usr/share/apache2/ssl_passphrase
#!/bin/sh

echo "occisk"

exit
EOF

chmod 777 /usr/share/apache2/ssl_passphrase
sed -i 's/SSLPassPhraseDialog/#SSLPassPhraseDialog/g' /etc/apache2/mods-available/ssl.conf
sed -i '/#SSLPassPhraseDialog/a\        SSLPassPhraseDialog exec:/usr/share/apache2/ssl_passphrase' /etc/apache2/mods-available/ssl.conf

service apache2 restart

#expect <<EOF
#set timeout 5
#spawn service apache2 restart
#expect "*:"
#send "occisk\r"
#expect eof
#EOF


printf "\n
###########################################
Finish rocci installation !
###########################################
\n"

#####################################
#config samba
#####################################

printf "\n
###########################################
config samba
###########################################
\n"

samba -V
if [ 0 -ne $? ]
then
  printf "\nGoing to install samba !\n"
  apt-get -y install samba
fi

if [ ! -f /etc/samba/smb.conf_org ]
then
  cp /etc/samba/smb.conf /etc/samba/smb.conf_org
  printf "
[rocci]
     path = /opt/rOCCI-server
     available = yes
     browsable = yes
     public = no
     writable = yes

" >> /etc/samba/smb.conf 
fi

expect <<EOF
spawn smbpasswd -a rocci
expect "*:"
send "rocci\r"
expect "*:"
send "rocci\r"
expect eof
EOF

/etc/init.d/samba restart



printf "\n
###########################################
End of rocci_build.sh !
###########################################
\n"



exit







