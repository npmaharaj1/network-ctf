#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export TERM=xterm-256color

apt update
apt install apache2 vim iproute2 python3 pip python3.12-venv curl python3-flask php netcat-openbsd inetutils-ping openssh-client hydra -y
service apache2 start

# Routing Table
ip addr add 192.168.1.98/24 dev eth1
ip link set eth1 up

ip route del default via 172.20.20.1 dev eth0
ip route add default via 192.168.1.1 dev eth1 metric 100
ip route add default via 172.20.20.1 dev eth0 metric 200

# DHCP
echo "192.168.1.15      mauricemosscomputer" >> /etc/hosts