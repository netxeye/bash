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
        -c The Channel you want to send
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
    JSON_V=`cat <<-JSONS
    [
      { "title": "Problem ${TRIGGER_NAME}",
        "callback_id" : "${EVENT_ID}",
        "title_link": "${TRIGGER_URL}",
         "color": "danger",
         "fields": [
             { "title": "Severity",
               "value": "${TRIGGER_SEVERITY}",
                "short": true},
             { "title": "Problem ID",
               "value": "${EVENT_ID}",
                "short": true},
             { "title": "Host Name",
               "value": "${HOST_NAME}",
                "short": true}
           ]
      },
      { "title": "Would you like to ACK this alarm ?",
        "fallback": "Action for ACK alarm",
        "callback_id": "zabbix ${EVENT_ID}",
        "color": "#3AA3E3",
        "actions": [
        {
           "name": "action",
           "text": "ACK without Closing",
           "type": "button",
           "value": "ACK_zabbix"
         },
        { 
           "name": "action",
           "text": "ACK with Closing",
           "type": "button",
           "style": "danger",
           "value": "ACK_CLOSE_zabbix",
           "confirm": {
              "title": "Are you sure?",
              "text": "Would you like to ACK and CLOSE this problem?",
              "ok_text": "Yes", 
              "dismiss_text": "No"
           }
         }
        ]
      }
    ]
JSONS`
}
[ ${UID} -ne 0 ] && Usage
while getopts ':e:n:s:t:p:u:U:T:c:' ARGS
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
            c) CHANNEL=${OPTARG} ;;
            *) Usage ;;
        esac
done
Parser
JSON
curl -XPOST  -d "token=${TOKEN}" -d "text=Problme happen ${HOST_NAME}" -d"channel=${CHANNEL:-zabbix-discussion}"  -d "attachments=${JSON_V}" ${URL}
