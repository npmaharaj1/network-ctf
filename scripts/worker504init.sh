#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export TERM=xterm-256color

# General Setup
apt update
apt install iproute2 bash apache2 netcat-traditional curl vim -y

# Setup root
echo "root:welcome" | chpasswd

# Routing Table
ip addr add 192.168.1.23/24 dev eth1
ip link set eth1 up

ip route del default via 172.20.20.1 dev eth0
ip route add default via 192.168.1.1 dev eth1 metric 100
ip route add default via 172.20.20.1 dev eth0 metric 200

echo "shiftmanager002 > localhost:8132" > /managerlist.txt