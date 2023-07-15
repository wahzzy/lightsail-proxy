#!/bin/bash
#
DOMAIN=$DOMAIN
AUTH=$AUTH

BIND_IP=0.0.0.0
CERT_DIR=/etc/letsencrypt
CERT=${CERT_DIR}/live/${DOMAIN}/fullchain.pem
KEY=${CERT_DIR}/live/${DOMAIN}/privkey.pem

GOST_WARP_PORT=2083
sudo docker run -d --name gost-warp \
    -v ${CERT_DIR}:${CERT_DIR}:ro \
    --net=host ginuerzh/gost \
    -L "mwss://${BIND_IP}:${GOST_WARP_PORT}?auth=${AUTH}&cert=${CERT}&key=${KEY}" -F "socks://localhost:40000"