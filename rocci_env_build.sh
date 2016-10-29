#!/bin/sh

ONE_NUM=5
EC2_NUM=15

cd /opt/rOCCI-server/

LOG="rocci_env_build_${ONE_NUM}_${EC2_NUM}.data"

echo "begin"

echo "begin to build sim env opennebula: ${ONE_NUM}." >> $LOG
date >> $LOG
./one_basicauth_test.rb ${ONE_NUM}
date >> $LOG
echo "end build sim env opennebula" >> $LOG

echo "begin to build sim env ec2: ${EC2_NUM}." >> $LOG
date >> $LOG
./ec2_basicauth_test.rb ${EC2_NUM}
date >> $LOG
echo "end build sim env ec2" >> $LOG

echo "end"
