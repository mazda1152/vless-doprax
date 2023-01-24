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
		"loglevel": "warning"
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

# run
chmod +x caddy xray
./xray -c /tmp/xray.json &
# wait for xray to be started
(until (netstat -l | grep 20000); do usleep 100; done &&
./caddy run --config /tmp/caddy.json)
