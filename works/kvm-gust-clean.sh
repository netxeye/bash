#! /usr/bin/env bash
vmPath='/perfectworld/vm_image'
program='/usr/bin/virsh'


function Usage {
    cat <<-USAGE
    Usage: ${0}
        -g {Guest name} The Guest name.
        -d delete action
        -u undefine action
        -r remove virtual disk
USAGE
    exit 1
}

function Delete {
    local guestName=${1}
		${program} list --name | grep -q ${guestName}
    [[ $? == 0 ]] && ${program} destroy ${guestName} &> /dev/null ||\
    printf "${guestName} has been deleted or not existed"
    [[ $? == 0 ]] && printf 'Deleted %s \n' ${guestName} || printf 'Fail\n'
}

function Undefine {
    local guestName=${1}
		${program} list --all --name | grep -q ${guestName}
    [[ $? == 0 ]] && ${program} undefine ${guestName} &> /dev/null ||\
    printf "${guestName} has been undefined or not existed"
    [[ $? == 0 ]] && printf 'Undefined %s \n' ${guestName} || printf 'Fail\n'
}

function Remove {
    local guestName=${1}
    [ -z ${guestName} ] && printf 'Fail\n' || find ${vmPath} -type f -name \
    "${guestName}*.qcow2" -exec rm -rf {} \;
    [[ $? == 0 ]] && printf 'Removed %s \n' ${guestName} || printf 'Fail\n'
}

function DnsCleanUp {
    local guestName=${1}
		nslookup ${guestName} &> /dev/null
		[[ $? == 0 ]] && tmpfile=$(mktemp) &> /dev/null && cat > ${tmpfile} <<-DNSUPDATE
update delete ${guestName}
send
DNSUPDATE
    [ $? -eq 0 ] && [ -f ${tmpfile} ] && nsupdate ${tmpfile} && rm -f ${tmpfile}
}


[ ${UID} -ne 0 ] && Usage
while getopts 'g:dur' ARGS
do
    case ${ARGS} in
        g ) GuestName=${OPTARG} ;;
        d ) delete=1 ;;
        u ) undefine=1;;
        r ) remove=1 ;;
        \? ) Usage ;;
    esac
done
[[ $delete == 1 ]] && Delete ${GuestName}
[[ $undefine == 1 ]] && Undefine ${GuestName}
[[ $remove == 1  ]] && Remove ${GuestName} ; DnsCleanUp ${GuestName}
