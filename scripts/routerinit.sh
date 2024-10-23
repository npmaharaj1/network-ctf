apk update
apk add --no-cache openssh openrc
rc-update add sshd
rc-service sshd start
touch /etc/frr/vtysh.conf

vtysh -f /scripts/routerconfig.sh