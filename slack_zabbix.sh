#!/bin/bash
function Usage {
    cat <<-USAGE
    Usage: ${0}
        -e {EVENT.ID}the event ID for zabbix alarm
        -m the Acknowledge messages for zabbix
        -n {HOST.NAME}the hostname of problems
        -s {TRIGGER.SEVERITY}Seventy of alarm
        -t {EVENT.TIME}
        -p {TRIGGER.NAME}
        -C close this problem
USAGE
exit 1
}
function Parser {
    if [ -z ${EVENT_ID} ] || [ -z ${HOST_NAME} ] || [ -z ${TRIGGER_SEVERITY} ] \
    || [ -z ${EVENT_TIME} || [ -z ${TRIGGER_NAME} ; then
        Usage
    fi
}
[ ${UID} -ne 0 ] && Usage
while getopts ':e:m:n:s:t:p:C' ARGS
    do
        case ${ARGS} in
            e) EVENT_ID=${OPTARG} ;;
            m) ACK_MESSAGE=${OPTARG} ;;
            n) HOST_NAME=${OPTARG} ;;
            s) TRIGGER_SEVERITY=${OPTARG} ;;
            t) EVENT_TIME=${OPTARG} ;;
            p) TRIGGER_NAME=${OPTARG} ;;
            C) EVENT_CLOSE='yes' ;;
            *) Usage ;;
        esac
done
Parser
