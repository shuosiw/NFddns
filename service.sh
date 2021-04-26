#!/bin/sh
#
# File: service.sh
# Desc: ddns service control script
# Date: 2021-04-26

# sleep seconds after recieving term signal
if [ -z "$PRESTOP_SECONDS" ]; then
    PRESTOP_SECONDS=2
fi

# flag of backing down with docker stop signal
# default false mean unexpected crash
DOCKER_STOP=false

VALID_DNS='alidns|cloudflare|dnscom|dnspod|dnspod_com|he|huaweidns|callback'
VALID_IP_METHOD='default|public|interface:.*|url:.*'
DDNS_BIN='/ddns'
DDNS_CONFIG='/config.json'
JSON_CONFIG_TPL='{
    "id": $NFD_ID,
    "token": $NFD_TOKEN,
    "dns": $NFD_DNS,
    "index4": $NFD_INDEX4,
    "index6": $NFD_INDEX6,
    "ipv4": $NFD_IPV4,
    "ipv6": $NFD_IPV6,
    "proxy": $NFD_PROXY,
    "ttl": $NFD_TTL,
    "debug": $NFD_DEBUG,
    "$schema": "https://ddns.newfuture.cc/schema/v2.8.json"
}'

transfer_str_list(){
    # strip space at the beginning and end of a line
    _str=`echo $1` 
    # transfer to list
    _list=''
    for i in ${_str//,/ }; do
        _list="${_list}\"$i\", "
    done
    _final_list="[`echo $_list | sed 's/,$//g'`]"
    echo "$_final_list"
}

# get config from environment variables
get_config(){
    # dns accesskey id and token
    if [ -z $NFD_ID ] || [ -z $NFD_TOKEN ]; then
        echo 'Missing id or token, exit!'
        exit 1
    fi
    # dns service provider
    if ! echo $NFD_DNS | grep -wqE "$VALID_DNS"; then
        echo "invalid dns provider: $NFD_DNS"
        exit 1
    fi
    # ipv4 and ipv6 domain list
    NFD_IPV4=`transfer_str_list "$NFD_IPV4"`
    NFD_IPV6=`transfer_str_list "$NFD_IPV6"`

    # method of obtaining ipv4 and ipv6 
    if ! echo "$NFD_INDEX4" | grep -wqE "$VALID_IP_METHOD"; then
        echo "Invalid index4 parameter: $NFD_INDEX4"
        exit 1
    fi
    if ! echo "$NFD_INDEX6" | grep -wqE "$VALID_IP_METHOD"; then
        echo "Invalid index6 parameter: $NFD_INDEX6"
        exit 1
    fi

    # domain ttl
    if [ -z $NFD_TTL ]; then
        NFD_TTL=null
    elif ! echo "$NFD_TTL" | grep -wq '^[[:digit:]]*$'; then
        echo "Invalid domain ttl: $NFD_TTL"
        exit
    fi
    # cache setting
    if [ -z $NFD_CACHE ]; then
        NFD_CACHE=true
    else
        if ! echo "$NFD_CACHE" | grep -wqE 'true|false'; then
            echo "Invalid cache setting: $NFD_CACHE"
            exit 1
        fi
    fi
    # debug setting
    if [ -z $NFD_DEBUG ]; then
        NFD_DEBUG=false
    else
        if ! echo "$NFD_DEBUG" | grep -wqE 'true|false'; then
            echo "Invalid cache setting: $NFD_DEBUG"
            exit 1
        fi
    fi
    # crontab
    if [ -z $NFD_INTERVALS ]; then
        NFD_INTERVALS=5
    else
        if ! echo "$NFD_INTERVALS" | grep -wq '^[[:digit:]]\{1,2\}$'; then
            echo 'Invalid intervals setting: $NFD_INTERVALS'
            exit 1
        elif [ $NFD_INTERVALS -lt 0 ] || [ $NFD_INTERVALS -gt 60 ]; then
            echo 'Intervals must between 0 and 60: $NFD_INTERVALS'
            exit 1
        fi
    fi
}


# render json config
render_config(){
    # render ddns config
    echo "render ddns config.json..."
    jq -n --arg NFD_ID "$NFD_ID" \
        --arg NFD_TOKEN "$NFD_TOKEN" \
        --arg NFD_DNS "$NFD_DNS" \
        --argjson NFD_IPV4 "$NFD_IPV4" \
        --argjson NFD_IPV6 "$NFD_IPV4" \
        --arg NFD_INDEX4 "$NFD_INDEX4" \
        --arg NFD_INDEX6 "$NFD_INDEX6" \
        --argjson NFD_TTL "$NFD_TTL" \
        --argjson NFD_CACHE "$NFD_CACHE" \
        --arg NFD_PROXY "$NFD_PROXY" \
        --argjson NFD_DEBUG "$NFD_DEBUG" "$JSON_CONFIG_TPL" > $DDNS_CONFIG
    echo
    cat $DDNS_CONFIG
    # render crontab config
    echo 'render crontab config...'
    echo "*/${NFD_INTERVALS} * * * * $DDNS_BIN -c $DDNS_CONFIG" > /etc/crontabs/root
    cat /etc/crontabs/root
}


# check pid valid
check_service_by_pid(){
    if [ ! -z "$CRON_PID" ]; then
        if ! ps axu | awk '{print $1}' | grep "^${CRON_PID}\$" > /dev/null; then
            echo "cron is not running"
            return 1
        fi
    fi
    return 0
}

# start service
start_service(){
    crond -f &
    export CRON_PID="$!"
}


# stop service
stop_service(){
    _quick="$1"
    # check for quick stoping or normal stoping
    if [ "x$_quick" != "xquick" ] && [ "x$ENV" != "xTEST" ]; then
        echo "prepare stop service, sleep $PRESTOP_SECONDS..."
        for i in `seq 1 $PRESTOP_SECONDS`; do
            sleep 1
            echo "prepare stop service for $i seconds."
        done
    fi
    # check cron is alive then stop it
    if [ ! -z "$CRON_PID" ] && \
        ps axu | awk '{print $1}' | grep "^${CRON_PID}\$" > /dev/null; then
        echo "stoping crontab: kill -s TERM $CRON_PID"
        kill -s TERM $CRON_PID
        wait $!
    fi
    echo "all service stop."
}


# trap script
trap_term(){
    echo 'get terminal signal, stop service...'
    # just stop nginx and python gunicorn.
    stop_service
    # set flag for docker stop
    DOCKER_STOP=true
}

main(){
    # trap 15 signal
    trap 'trap_term' SIGTERM

    # start service
    get_config
    render_config
    start_service

    # hold docker
    while ! $DOCKER_STOP ; do
        if ! check_service_by_pid; then
            stop_service quick
            exit 0
        fi
        sleep 2
    done

    # wait child
    wait
    echo "init process end"
}

main


