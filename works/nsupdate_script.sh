#!/bin/env bash
TEMP_FILE=$(/bin/mktemp)
HOST_NAME=$(/bin/hostname)
until [ -f /usr/bin/nslookup ]; do
  /usr/bin/yum install -y  bind-utils &> /dev/null
done
DNS_RESULT=$(/usr/bin/timeout 2 /usr/bin/dig -tA ${HOST_NAME} +short)
/usr/bin/timeout 2 /usr/bin/nslookup ${HOST_NAME} &> /dev/null
if [[ $? == 124 ]] || [ -z ${DNS_RESULT} ]; then
  cat > ${TEMP_FILE} << EOL
update add ${HOST_NAME} 300 A $(facter ipaddress_eth0)
send
EOL
  nsupdate ${TEMP_FILE}
  rm -rf ${TEMP_FILE}
else
  for IP_ADD in `facter interfaces | tr ',' ' '` ; do 
    RESULT=`facter ipaddress_${IP_ADD}` 
    if [ ! -z ${RESULT} ] && [ ${DNS_RESULT} = ${RESULT} ] ;then
      NO_UPDATE_A=1
      break
    fi
  done
  if [ ${NO_UPDATE_A} -ne 1 ]; then
    cat > ${TEMP_FILE} << EOL
update delete ${HOST_NAME} A
update add ${HOST_NAME} 300 A $(facter ipaddress_eth0)
send
EOL
    nsupdate ${TEMP_FILE}
    rm -rf ${TEMP_FILE}
  fi
fi
/usr/bin/timeout 2 /usr/bin/nslookup ${DNS_RESULT} &> /dev/null
if [[ $? != 0 ]]; then
DNS_PTR=$(/usr/bin/timeout 2 /usr/bin/nslookup ${DNS_RESULT}| /bin/grep "server can't find" | /bin/awk '{print $5}' | /usr/bin/tr -d ':')
  cat > ${TEMP_FILE} << EOL
update add  ${DNS_PTR} 300 ptr ${HOST_NAME}.
send
EOL
  nsupdate ${TEMP_FILE}
  rm -rf ${TEMP_FILE}
fi
DNS_PTR_A=$(/usr/bin/timeout 2 /usr/bin/nslookup ${DNS_RESULT}| /bin/grep name | /bin/awk -F'=' '{print $2}' | /usr/bin/tr -d ' ')
if [ $(hostname -f ) != ${DNS_PTR_A%.} ];then
DNS_PTR=$(/usr/bin/timeout 2 /usr/bin/nslookup ${DNS_RESULT}| /bin/grep name | /bin/awk -F'=' '{print $1}' | /usr/bin/tr -d ' '| /bin/awk '{print $1}')
  cat > ${TEMP_FILE} << EOL
update delete ${DNS_PTR}
update add  ${DNS_PTR} 300 ptr ${HOST_NAME}.
send
EOL
  nsupdate ${TEMP_FILE}
  rm -rf ${TEMP_FILE}
fi
