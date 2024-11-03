apk update
apk add --no-cache openssh openrc
rc-update add sshd
rc-service sshd start
touch /etc/frr/vtysh.conf

ip link add name br0 type bridge

ip link set dev eth1 master br0
ip link set dev eth2 master br0
ip link set dev eth3 master br0

ip addr add 192.168.1.1/24 dev br0

ip link set dev br0 up
ip link set dev eth1 up
ip link set dev eth2 up

echo "setup complete"