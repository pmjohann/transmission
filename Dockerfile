FROM alpine:3.12

RUN apk --no-cache add bash curl shadow sed tini \
                transmission-daemon tzdata && \
    DIR="/transmission" && \
    SETTINGS="$DIR/info/settings.json" && \
    mv /var/lib/transmission $DIR && \
    usermod -d $DIR transmission && \
    [[ -d $DIR/downloads ]] || mkdir -p $DIR/downloads && \
    [[ -d $DIR/incomplete ]] || mkdir -p $DIR/incomplete && \
    [[ -d $DIR/watch ]] || mkdir -p $DIR/watch && \
    [[ -d $DIR/info/blocklists ]] || mkdir -p $DIR/info/blocklists && \
    /bin/echo -e '{\n    "blocklist-enabled": 0,' >$SETTINGS && \
    echo '    "dht-enabled": true,' >>$SETTINGS && \
    echo '    "download-dir": "'"$DIR"'/downloads",' >>$SETTINGS && \
    echo '    "incomplete-dir": "'"$DIR"'/incomplete",' >>$SETTINGS && \
    echo '    "incomplete-dir-enabled": true,' >>$SETTINGS && \
    echo '    "watch-dir": "'"$DIR"'/watch",' >>$SETTINGS && \
    echo '    "watch-dir-enabled": true,' >>$SETTINGS && \
    echo '    "download-limit": 100,' >>$SETTINGS && \
    echo '    "download-limit-enabled": 0,' >>$SETTINGS && \
    echo '    "encryption": 1,' >>$SETTINGS && \
    echo '    "max-peers-global": 200,' >>$SETTINGS && \
    echo '    "peer-port": 51413,' >>$SETTINGS && \
    echo '    "peer-socket-tos": "lowcost",' >>$SETTINGS && \
    echo '    "pex-enabled": 1,' >>$SETTINGS && \
    echo '    "port-forwarding-enabled": 0,' >>$SETTINGS && \
    echo '    "queue-stalled-enabled": true,' >>$SETTINGS && \
    echo '    "ratio-limit-enabled": true,' >>$SETTINGS && \
    echo '    "rpc-authentication-required": 1,' >>$SETTINGS && \
    echo '    "rpc-password": "transmission",' >>$SETTINGS && \
    echo '    "rpc-port": 9091,' >>$SETTINGS && \
    echo '    "rpc-username": "transmission",' >>$SETTINGS && \
    echo '    "rpc-whitelist": "127.0.0.1",' >>$SETTINGS && \
    echo '    "upload-limit": 100,' >>$SETTINGS && \
    /bin/echo -e '    "upload-limit-enabled": 0\n}' >>$SETTINGS && \
    chown -Rh transmission. $DIR && \
    rm -rf /tmp/*

COPY transmission.sh /usr/bin/

EXPOSE 9091 51413/tcp 51413/udp

HEALTHCHECK --interval=60s --timeout=15s \
            CMD netstat -lntp | grep -q '0\.0\.0\.0:9091'

VOLUME ["/var/lib/transmission-daemon"]

ENTRYPOINT ["/sbin/tini", "--", "/usr/bin/transmission.sh"]
