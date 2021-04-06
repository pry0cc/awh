# Awesome Wireguard Helper
I was finding it really annoying trying to automate wireguard configurations. So I made this. 

## Usage
Just run these commands on an Ubuntu 20.04 server with Wireguard installed and you'll soon have yourself a Wireguard server :) 
```
git clone https://github.com/pry0cc/awh
cd awh
./generate.sh
```
The script will generate a client and server configuration, setup the server, and then print out the client configuration.

Copy that client configuration into your wireguard client and you're good!
```
# Run on client if linux
sudo cp client.conf /etc/wireguard/wg0.conf
sudo systemctl start wg-quick@wg0
sudo systemctl status wg-quick@wg0
```
