#!/bin/bash
function Usage {
    cat <<-USAGE
    Usage: ${0}
        -e {EVENT.ID}the event ID for zabbix alarm
        -n {HOST.NAME}the hostname of problems
        -s {TRIGGER.SEVERITY}Seventy of alarm
        -t {EVENT.TIME}
        -p {TRIGGER.NAME}
        -u The URL of slack API
        -U The URL of ZABBIX Tigger
        -T The Token of slack API
USAGE
exit 1
}
function Parser {
    if [ -z ${EVENT_ID} ] || [ -z ${HOST_NAME} ] || [ -z ${TRIGGER_SEVERITY} ] \
    || [ -z ${EVENT_TIME} ] || [ -z ${TRIGGER_NAME// /} ]|| [ -z ${URL} ] || \
    [ -z ${TOKEN} ] || [ -z ${TRIGGER_URL} ] ; then
        Usage
    fi
}
function JSON {
    echo '{'
    echo '"text": "This is Zabbix alarm from ZABBIX3",'
    echo '"attachments": ['
    echo "  { \"title\": \"Problem ${TRIGGER_NAME}\","
    echo "    \"title_link\": \"${TRIGGER_URL}\","
    echo '     "color": "danger",'
    echo '     "fields": ['
    echo '         { "title": "Severity",'
    echo "           \"value\": \"${TRIGGER_SEVERITY}\","
    echo '            "short": true},'
    echo '         { "title": "Problem ID",'
    echo "           \"value\": \"${EVENT_ID}\","
    echo '            "short": true},'
    echo '         { "title": "Host Name",'
    echo "           \"value\": \"${HOST_NAME}\","
    echo '            "short": true}'
    echo '       ]'
    echo '  },'
    echo '  { "title": "Would you like to ACK this alarm ?",'
    echo '    "fallback": "Action for ACK alarm",'
    echo "    \"callback_id\": \"zabbix ${EVENT_ID}\","
    echo '    "color": "#3AA3E3",'
    echo '    "actions": [ '
    echo '    { '
    echo '       "name": "action", '
    echo '       "text": "ACK without Closing", '
    echo '       "type": "button", '
    echo '       "value": "ACK_zabbix" '
    echo '     }, '
    echo '    { '
    echo '       "name": "action", '
    echo '       "text": "ACK with Closing", '
    echo '       "type": "button", '
    echo '       "style": "danger", '
    echo '       "value": "ACK_CLOSE_zabbix", '
    echo '       "confirm": { '
    echo '          "title": "Are you sure?", '
    echo '          "text": "Would you like to ACK and CLOSE this problem?", '
    echo '          "ok_text": "Yes", '
    echo '          "dismiss_text": "No" '
    echo '       } '
    echo '     } '
    echo '    ] '
    echo '  } '
    echo '] '
    echo '} '
}
[ ${UID} -ne 0 ] && Usage
while getopts ':e:n:s:t:p:u:U:T:' ARGS
    do
        case ${ARGS} in
            e) EVENT_ID=${OPTARG} ;;
            n) HOST_NAME=${OPTARG} ;;
            s) TRIGGER_SEVERITY=${OPTARG} ;;
            t) EVENT_TIME=${OPTARG} ;;
            p) TRIGGER_NAME=${OPTARG} ;;
            u) URL=${OPTARG} ;;
            U) TRIGGER_URL=${OPTARG} ;;
            T) TOKEN=${OPTARG} ;;
            *) Usage ;;
        esac
done
Parser
JSON
