#!/bin/sh

echo "need specify AWS Access Key:"

exit

ssh 192.168.0.20 <<EOF
service apache2 restart;
curl --insecure -u ' https://localhost:11443/-/
EOF

./ec2_basicauth_test.rb
