#!/bin/bash

# configures a static network gentoo style

if [ $# -ne 3 ] ; then
  echo Usage: $0 [hostname] [external-ip] [internal-ip]
  echo Uses ROOT_PREFIX to set a directory prefix to all files written.
  exit 1
fi

echo Configuring $ROOT_PREFIX/etc/resolv.conf
echo domain example.com > $ROOT_PREFIX/etc/resolv.conf
echo search example.com >> $ROOT_PREFIX/etc/resolv.conf
echo nameserver 192.168.1.1 >> $ROOT_PREFIX/etc/resolv.conf

echo Configuring $ROOT_PREFIX/etc/conf.d/hostname
echo "HOSTNAME=\"${1}\"" > $ROOT_PREFIX/etc/conf.d/hostname

echo Configuring $ROOT_PREFIX/etc/conf.d/net
echo "config_eth0=\"${2} netmask 255.255.255.0 broadcast 192.168.1.255\"" > $ROOT_PREFIX/etc/conf.d/net
echo "routes_eth0=(\"default via 192.168.1.1\")" >> $ROOT_PREFIX/etc/conf.d/net
echo "config_eth1=\"${3} netmask 255.255.255.0 broadcast 192.168.2.255\"" >> $ROOT_PREFIX/etc/conf.d/net

