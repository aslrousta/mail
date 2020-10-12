FROM debian:buster
WORKDIR /opt
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -yq postfix opendkim opendkim-tools rsyslog procps net-tools dnsutils && \
    rm -rf /var/lib/apt/lists/*

COPY scripts /opt

COPY .config/postfix/main.cf         /etc/postfix/
COPY .config/opendkim/opendkim.conf  /etc/
COPY .config/opendkim/opendkim       /etc/default/
COPY .config/opendkim/TrustedHosts   /etc/opendkim/
COPY .config/opendkim/KeyTable       /etc/opendkim/
COPY .config/opendkim/SigningTable   /etc/opendkim/

EXPOSE 25

ENTRYPOINT [ "/opt/docker-entrypoint.sh" ]
CMD [ "/opt/start.sh" ]
