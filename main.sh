#!/bin/bash

# temp config files
cat > /tmp/caddy.json << EOF
{
  "admin": {
    "disabled": true,
    "config": {
      "persist": false
    }
  },
  "apps": {
    "http": {
      "servers": {
        "xray": {
          "listen": [":10000"],
          "routes": [
            {
              "match": [{
                "path": ["${path}"]
              }],
              "handle": [{
                "handler": "reverse_proxy",
                "upstreams": [{
                  "dial": "localhost:20000"
                }]
              }]
            },
            {
              "match": [{
                "path": ["/host"]
              }],
              "handle": [{
                "handler": "static_response",
                "body": "${REPL_SLUG}.${REPL_OWNER}.repl.co"
              }]
            },
            {
              "handle": [{
                "handler": "static_response",
                "body": "Hello world!"
              }]
            }
          ]
        }
      }
    }
  }
}
EOF

cat > /tmp/xray.json << EOF
{
  "log": {
    "loglevel": "warning",
    "access": "/dev/null"
  },
  "inbounds": [
    {
      "port": 20000,
      "protocol": "vless",
      "settings": {
        "udp": false,
        "clients": [{
          "id": "${uuid}"
        }],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "${path}"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "tag": "direct"
    },
    {
      "protocol": "blackhole",
      "tag": "block"
    },
    {
      "protocol": "dns",
      "tag": "dns_out"
    }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "outboundTag": "dns_out",
        "network": "udp",
        "port": 53
      },
      {
        "type": "field",
        "outboundTag": "block",
        "ip": ["geoip:private"]
      }
    ]
  },
  "dns": {
    "servers": [
      "https+local://1.1.1.1/dns-query",
      "localhost"
    ]
  }
}
EOF

# give permissions
chmod +x caddy xray
# start xray
./xray -c /tmp/xray.json &
# wait for xray to be started
(until (netstat -l | grep 20000 > /dev/null); do usleep 100; done &&
# start caddy
./caddy run --config /tmp/caddy.json) &
# stay the repl awake
(while true;
  do sleep 1m;
  curl https://${REPL_SLUG}.${REPL_OWNER}.repl.co > /dev/null 2>&1;
done)
