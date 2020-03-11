#!/bin/bash

PUBLIC_IP=`dig +short myip.opendns.com @resolver1.opendns.com`
SSL_CERTIFICATE_KEY="/app/ssl/live/$ROOT_SERVER_NAME/privkey.pem"
SSL_CERTIFICATE="/app/ssl/live/$ROOT_SERVER_NAME/cert.pem"
CA_CERTIFICATE="/app/ca/cacert.pem"

HEADER="
[supervisord]\n
user            = root\n
nodaemon        = true\n\n"
echo -e $HEADER > /app/supervisord.conf

i=0
while :
do
    s="CLOUD_MAP_$i"

    if [[ -z ${!s} ]];
    then
        break
    fi

    target=$(echo ${!s} | cut -f1 -d "|")
    source="$PUBLIC_IP:$(echo ${!s} | cut -f2 -d "|")"

    CMD="
[program:gt_$i]\n
command         = /usr/bin/ghostunnel server --listen $source --target $target --key $SSL_CERTIFICATE_KEY --cert $SSL_CERTIFICATE --cacert $CA_CERTIFICATE --unsafe-target --allow-all\n
autostart       = true\n
autorestart     = true\n
process_name    = master\n
startsecs       = 0\n
stdout_logfile  = /dev/stdout\n
stderr_logfile  = /dev/stderr\n
stdout_logfile_maxbytes=0\n
stderr_logfile_maxbytes=0\n\n"

    i=$(( $i + 1 ))
    echo -e $CMD >> /app/supervisord.conf

done

exec supervisord -c /app/supervisord.conf
