#!/bin/bash
#
# File: env_test.sh
# Desc:
# Date: 2021-04-26

export NFD_ID='test_id'
export NFD_TOKEN='test_token'
export NFD_DNS='dnspod'
export NFD_IPV4='ddns.xxx.com,ipv4.ddns.xxx.com'
export NFD_IPV6='ddns.xxx.com,ipv6.ddns.xxx.com'
export NFD_INDEX4='default'
export NFD_INDEX6='public'
export NFD_TTL='600'
export NFD_PROXY=''
export NFD_DEBUG=''
export NFD_CACHE=''

docker run -e NFD_ID='test_id' -e NFD_TOKEN='test_token' \
    -e NFD_DNS='dnspod' -e NFD_IPV4='ddns.xxx.com,ipv4.ddns.xxx.com' \
    -e NFD_IPV6='ddns.xxx.com,ipv6.ddns.xxx.com' -e NFD_INDEX4='default' \
    -e NFD_INDEX6='public' -e NFD_TTL='600' -e NFD_PROXY='' \
    -e NFD_DEBUG='' -e NFD_CACHE='' --name nfddns -d  nfddns:test