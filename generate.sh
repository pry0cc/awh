#!/bin/bash

server_ip="$(curl -s ipinfo.io/ | jq -r '.ip')"
server_port="5555"
sudo ufw allow $server_port

rm -rf server
rm -rf client

mkdir server
mkdir client

cd server
umask 077
wg genkey | tee privatekey | wg pubkey > publickey

cd ../client
umask 077
wg genkey | tee privatekey | wg pubkey > publickey

cd ..

client_pub="$(cat client/publickey)"
client_pk="$(cat client/privatekey)"
server_pub="$(cat server/publickey)"
server_pk="$(cat server/privatekey)"

echo "Generating server conf"
echo -e "[Interface]\nAddress = 192.168.6.1/24\nSaveConfig = true\nPostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE\nPostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE\nListenPort = $server_port\nPrivateKey = $server_pk\n\n[Peer]\nPublicKey = $client_pub\nAllowedIPs = 192.168.6.2/32" > server/server.conf 
echo "Generating client conf"
echo -e "[Interface]\nPrivateKey = $client_pk\nAddress = 192.168.6.2/24\nDNS = 1.1.1.1\n\n[Peer]\nPublicKey = $server_pub\nAllowedIPs = 0.0.0.0/0\nEndpoint = $server_ip:$server_port" > client/client.conf

sudo systemctl stop wg-quick@wg0
sudo cp server/server.conf /etc/wireguard/wg0.conf
sudo systemctl start wg-quick@wg0
sudo systemctl status wg-quick@wg0

echo "HERE IS YOUR CLIENT CONF:"
cat client/client.conf
