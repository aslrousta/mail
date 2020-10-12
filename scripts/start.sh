#!/usr/bin/env bash

if [ ! -d "/home/$USER" ]; then
    useradd -g postfix -m "$USER"
    usermod -p "$PASSWORD" "$USER"
    echo "$USER: $USER" >>/etc/aliases
fi

sed -i "s/\$HOSTNAME/$HOSTNAME/g" /etc/postfix/main.cf
sed -i "s/\$HOSTNAME/$HOSTNAME/g" /etc/opendkim/SigningTable
sed -i "s/\$HOSTNAME/$HOSTNAME/g" /etc/opendkim/TrustedHosts

DOMAIN=${HOSTNAME#*.}
sed -i "s/\$DOMAIN/$DOMAIN/g" /etc/opendkim/KeyTable
sed -i "s/\$DOMAIN/$DOMAIN/g" /etc/opendkim/SigningTable
sed -i "s/\$DOMAIN/$DOMAIN/g" /etc/opendkim/TrustedHosts

HOSTIP=$(dig +short "$HOSTNAME")
sed -i "s/\$HOSTIP/$HOSTIP/g" /etc/postfix/main.cf
sed -i "s/\$HOSTIP/$HOSTIP/g" /etc/opendkim/TrustedHosts

KEYDIR="/etc/dkimkeys/$DOMAIN"
if [ ! -d "$KEYDIR" ]; then
    mkdir -p "$KEYDIR" && cd "$KEYDIR"
    opendkim-genkey -s default -d "$DOMAIN"
    chown -R opendkim:opendkim "$KEYDIR"
fi

/etc/init.d/opendkim start
/etc/init.d/postfix start
/etc/init.d/rsyslog start

sleep infinity
