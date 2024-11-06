#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Setup user
apt update
echo "N" | apt install adduser iproute2 openssh-server inetutils-ping sudo vim hostname php sysdig rsyslog -y

service ssh start

USERNAME="mauricemoss"  # Change this to the desired username
PASSWORD="pookie"  # Change this to the desired password
HOMEDIR="/home/$USERNAME"

# Add the system user
useradd -m -d "$HOMEDIR" -s /bin/bash "$USERNAME"

# Set the password for the new user
echo "$USERNAME:$PASSWORD" | sudo chpasswd

# Routing Table
ip addr add 192.168.1.15/24 dev eth1
ip link set eth1 up

ip route del default via 172.20.20.1 dev eth0
ip route add default via 192.168.1.1 dev eth1 metric 100
ip route add default via 172.20.20.1 dev eth0 metric 200

echo "aotm_ctf{78aa1a382d362594621f3ad452f9491f}" > /root/flag.txt
tar -czvf /root/secure.tar.gz /root/flag.txt
rm /root/flag.txt