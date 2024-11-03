#!/bin/bash

# Routing Table
ip addr add 192.168.1.23/24 dev eth1
ip link set eth1 up

ip route del default via 172.20.20.1 dev eth0
ip route add default via 192.168.1.23 dev eth1 metric 100
ip route add default via 172.20.20.1 dev eth0 metric 200