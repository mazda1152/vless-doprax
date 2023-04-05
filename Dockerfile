FROM ubuntu:latest
EXPOSE 80

COPY caddy /usr/bin/
COPY xray /usr/bin/
COPY geoip.dat /usr/bin/
COPY geosite.dat /usr/bin/
COPY entrypoint.sh /usr/bin/

RUN chmod a+x /usr/bin/caddy /usr/bin/xray /usr/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
