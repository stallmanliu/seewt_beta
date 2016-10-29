#!/bin/bash

CMD=`cat /home/occi/rocci_test.flag`
if [ "-reboot" == "-${CMD}" ]
then
  echo "stop" > /home/occi/rocci_test.flag
  reboot
fi

if [ "-change_vpn_aws" == "-${CMD}" ]
then
  echo "stop" > /home/occi/rocci_test.flag
  echo `date`": change_vpn_aws" >> /home/occi/rocci_test.log
  cp /etc/openvpn/client.conf_aws /etc/openvpn/client.conf
  service openvpn restart
elif [ "-change_vpn_lab" == "-${CMD}" ]
then
  echo "stop" > /home/occi/rocci_test.flag
  echo `date`": change_vpn_lab" >> /home/occi/rocci_test.log
  cp /etc/openvpn/client.conf_lab /etc/openvpn/client.conf
  service openvpn restart
fi

VIP_FILE="/home/occi/VIP"
#echo "0" > ${VIP_FILE}

  #sleep 10
  
  VIP_OLD=`cat ${VIP_FILE}`
  
  VIP=`/usr/local/bin/tap0ip`
  
  if [ "-${VIP_OLD}" != "-${VIP}" ]
  then
  
    echo "${VIP}" > ${VIP_FILE}
    
    LOG="/home/occi/rocci_test.log"
    #USER=`whoami`
    echo `date`" "`whoami`" waked after 60s, rocci_test.sh executed" >> ${LOG}
    echo "old:${VIP_OLD}, new:${VIP}" >> ${LOG}
    
    #sed -i 's/^portico.jgroups.udp.bindAddress/#portico.jgroups.udp.bindAddress/g' /home/occi/portico-2.0.0/examples/java/hla13/RTI.rid
    #sed -i '/#portico.jgroups.udp.bindAddress/a\portico.jgroups.udp.bindAddress = '${IP}'' /home/occi/portico-2.0.0/examples/java/hla13/RTI.rid
    sed -i '/portico.jgroups.udp.bindAddress/d' /home/occi/sim_task_java/RTI.rid
    echo "portico.jgroups.udp.bindAddress = ${VIP}" >> /home/occi/sim_task_java/RTI.rid
    
    PIP=`ifconfig | grep -iE '172\.31\.|137\.' | awk '{print $2}' | awk -F":" '{print $2}'`

      if [ "-0" != "-${VIP_OLD}" ]
      then
        PIP="new:"${PIP}
      fi

      S_VIP=`echo ${VIP} | awk -F"." '{print $1"."$2"."$3".1"}'`

      if echo ${S_VIP} | grep -iE '172\.20'
      then
        ssh root@${S_VIP} <<EOF
echo \`date\`":${PIP}:##:${VIP}" >> /home/danliu/occi/rocci_test/vms_ip.txt
EOF
      else
 
      ssh root@${S_VIP} <<EOF
echo \`date\`":${PIP}:##:${VIP}" >> /home/occi/rocci_test/vms_ip.txt
EOF

     fi

  
    echo `date`" quit" >> ${LOG}
  
  fi

