# Personal Mail Server

This project is a dead simple solution to configure and use Postfix + OpenDKIM
to run a personal mail server.

## Install

The recommended way to install this project on your server is to use a
`docker-compose.yml` file (change `mail.example.com` to your hostname):

```yaml
services:
  server:
    image: aslrousta/mail:latest
    hostname: mail.example.com
    environment:
      - HOSTNAME=mail.example.com
      - USER=admin
      - PASSWORD=admin
    volumes:
      - ./certs:/etc/postfix/certs:ro
      - ./keys:/etc/dkimkeys
    ports:
      - "25:25"
```

The mail server generates a default _DKIM_ key for your hostname at initial
start-up and puts it in the `/etc/dkimkeys/{HOSTNAME}` directory. Then, it
configures a default mail user with the given `USER` and `PASSWORD` environment
variables.

In order to use TLS, postfix expects certificates in `/etc/postfix/certs`
directory (`fullchain.pem` and `privkey.pem` files) that must belong to your
hostname.

## DNS Settings

After installation, you have to setup your DNS records properly. Use the
contents of `default.txt` file in `/etc/dkimkeys/{HOSTNAME}` directory to
configure `default._domainkey.` TXT record.

```
mail.               IN CNAME     example.com.
@                   IN MX  10    mail.example.com.
@                   IN TXT       "v=spf1 a mx ~all"
_dmarc.             IN TXT       "v=DMARC1;p=quarantine;sp=quarantine;adkim=r;aspf=r"
default._domainkey. IN TXT       "v=DKIM1;h=sha256;k=rsa;p=MIIBIjANBgkq ..."
```

Then, it must be done and your mail server would be ready to send emails via
`admin@example.com` email address.

## Troubleshooting

First of all, check if port 25 is accessible from your network and verify that
you see the ESMTP banner. Unless, you might need to configure your firewall
settings on SMTP port.

```bash
~ telnet mail.example.com 25
Trying ::1...
Connected to localhost.
Escape character is '^]'.
220 mail.example.com ESMTP Postfix (Debian/GNU)
```

If anything else goes wrong, check `/var/log/mail.info` and `/var/log/mail.err`
log files in the container.
