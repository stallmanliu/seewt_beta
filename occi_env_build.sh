#!/bin/bash

ONE_NUM=5
EC2_NUM=5
LOG="rocci_env_build_${ONE_NUM}_${EC2_NUM}.data"

function build_env()
{
  cd /opt/rOCCI-server/

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
}

function test()
{
  echo "ONE_NUM:"${ONE_NUM}
  echo "EC2_NUM:"${EC2_NUM}
}

#echo "ARGV_1:"$1
function deploy()
{
  if [ "-" != "-$2" ]
  then
    ONE_NUM=$1
    EC2_NUM=$2
  else
    if [ "-" != "-$1" ]
    then
      ONE_NUM=$(( ($1*$ONE_NUM)/($ONE_NUM+EC2_NUM) ))
      EC2_NUM=$(( $1-$ONE_NUM ))
    fi
  fi
}

#echo "ONE_NUM:"$ONE_NUM
#echo "EC2_NUM:"$EC2_NUM
deploy $1 $2
test
echo "LOG:"${LOG}
build_env







