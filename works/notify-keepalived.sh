#!/bin/bash
function Usage {
  cat <<-USAGE
  Usage: ${0}
      -s status which send by keepalived, only support MASTER, BACKUP, FAULT
      -c the command used for run basad on status. it is usually is service control command
      -o the options used for option -c
USAGE
exit 1
}
[[ ${UID} == 0 ]] || exit 1
while getopts 's:c:o:' ARGS
do
  case ${ARGS} in
    s) STATUS=${OPTARG^^} ;;
    c) CHECK_CMD=${OPTARG} ;;
    o) CHECK_OPT=${OPTARG} ;;
    *) Usage ;;                                                                                                                                                       
   esac
done
[ ${#} -eq 0 ] && Usage 
if [ ! -z ${STATUS} ] ;then
  case ${STATUS} in
    'MASTER') ${CHECK_CMD} ${CHECK_OPT:-start} 
     ;;
    'BACKUP') ${CHECK_CMD} ${CHECK_OPT:-stop}
     ;;
    'FAULT') ${CHECK_CMD} ${CHECK_OPT:-stop}
     ;;
     *)     logger -t keepalived "notify_script is not support this options ${STATUS}"
     ;;
  esac
fi
