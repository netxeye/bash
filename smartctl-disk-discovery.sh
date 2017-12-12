#!/bin/bash
function Usage {
  cat <<-USAGE
  Usage: ${0} 
    -s Scan the disk to output json format information for Zabbix
    -h Help informaion
    -v Display the version number
USAGE
  exit 0
}
function Check_software {
case $(lsb_release -is) in
  Centos) rpm -q smartmontools &> /dev/null
          [[ $? == 0 ]] || yum install -y smartmontools
  ;;
  Ubuntu) dpkg -L smartmontools &> /dev/null
          [[ $? == 0 ]] || apt-get update &> /dev/null && apt-get install -y  smartmontools &> /dev/null
  ;;
  \?)     echo "This script is not support this OS yet, please contact Tao.lu@perfectworld.com";exit 2 ;;
esac
}
function Scan_open {
local name dirver vendor serial disk_info
declare -a name driver
local index=0
local IFS_bk=${IFS}
local position=$(smartctl --scan-open | sed 's/#.*/\n/g' | grep -v '^$'| wc -l)
IFS=$'\n'
echo -e "{\n"
echo -e "\t\"data\":[\n"
for device in $( smartctl --scan-open | sed 's/#.*/\n/g' | grep -v '^$') ; do
  name[${index}]=$(echo ${device}|cut -f1 -d' ')
  driver[${index}]=$(echo ${device}|cut -f3 -d' ')
  echo -e "\t\t{"
  vendor=$(smartctl -i ${name[${index}]} -d ${driver[${index}]} | grep -i Vendor | awk -F: '{print $2}' | tr -d ' ')
  smartctl -i ${name[${index}]} -d ${driver[${index}]} | grep -i 'SMART support' | grep -qi Enabled
  if [[ $? == 0 ]] ; then
    serial=$(smartctl -i ${name[${index}]} -d ${driver[${index}]} | grep -i 'Serial number' | awk -F: '{print $2}' | tr -d ' ')
    disk_info=$(smartctl -i ${name[${index}]} -d ${driver[${index}]} | egrep -i '(Transport protocol|User Capacity|Rotation Rate|Form Factor)'| awk -F: '{print $2}' | sed -e 's/^\s*//g' -e 's/^[0-9]\+,\?.* bytes //g'|tr -d '[]' | tr '\n' ' ' | sed 's/$/\n/g')
    echo -e "\t\t\t\"{#DISKNAME}\": \"${vendor}_${serial} ${disk_info}\","
    echo -e "\t\t\t\"{#DISKCMD}\": \"${device}\","
    echo -e "\t\t\t\"{#DISK_SUPPORT}\": \"1\""
    if [[ $(( index + 1 )) == ${position} ]] ;then
      echo -e "\t\t}"
    else
      echo -e "\t\t},"
    fi
  else
    echo -e "\t\t\t\"{#DISKNAME}\": \"${vendor} - ${index}\","
    echo -e "\t\t\t\"{#DISK_SUPPORT}\": \"0\""
    if [[ $(( index + 1 )) == ${position} ]] ;then
      echo -e "\t\t}"
    else
      echo -e "\t\t},"
    fi
  fi
  ((index++))
done
echo -e "\n\t]\n"
echo -e "}\n"
IFS=${IFS_bk}
}
function Check_disks {
  smartctl -H $1 -d $2 |egrep -i '(SMART Health Status|SMART overall-health)' | awk -F: '{print $2}'
}
umask 022
[[ ${UID} == 0 ]] ||  exit 1
Check_software
while getopts "svc:d:" ARGS
do
  case ${ARGS} in
    s) Scan_open ;;
    v) echo 'Verison 1.5'
       exit 0 ;;
    c) DISKS=${OPTARG} ;;
    d) DIRVERS=${OPTARG} ;;
    \?) Usage ;;
  esac
done
if [ ! -z ${DISKS} ] && [ ! -z ${DIRVERS} ] ; then
  Check_disks ${DISKS} ${DIRVERS}
fi
