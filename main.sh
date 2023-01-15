# write configure file
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
          "listen": [":80",":443"],
          "routes": [
            {
              "match": [{
                "path": ["${path}"]
              }],
              "handle": [{
                "handler": "reverse_proxy",
                "upstreams": [{
                  "dial": "localhost:12345"
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
      "port": 12345,
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
      "protocol": "freedom"
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
      }
    ]
  }
}
EOF

# run
./xray -c /tmp/xray.json &
./caddy run --config /tmp/caddy.json
