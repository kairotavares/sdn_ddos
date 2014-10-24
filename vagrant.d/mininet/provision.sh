#!/usr/bin/env bash
set -e

echo ">>> Updating package database"
apt-get update -q

echo ">>> Installing dependencies"
apt-get -y -q install python-software-properties ubuntu-cloud-keyring
add-apt-repository "deb http://ubuntu-cloud.archive.canonical.com/ubuntu precise-updates/folsom main"
apt-get -y -q update
apt-get install -y -q autoconf libtool build-essential fakeroot debhelper \
    python-all libssl-dev python-qt4 patch wireshark wireshark-dev scons \
    openjdk-7-jre-headless postgresql keystone keystone-doc python-keystone \
    iptables unzip curl gcc make socat psmisc xterm ssh iperf iproute telnet \
    python-setuptools cgroup-bin ethtool help2man pyflakes pylint pep8 \
    python-pip libnet1-dev liblua5.1-dev lua5.1 libpcap-dev vlan

echo ">>> Installing Open vSwitch"
curl -kL https://github.com/openvswitch/ovs/archive/v2.3.tar.gz | tar xzf - -C /tmp

pushd /tmp/ovs-2.3 > /dev/null

autoreconf --install --force
DEB_BUILD_OPTIONS='nocheck' fakeroot debian/rules binary
dpkg -i ../openvswitch-common_2.3.0-1_amd64.deb \
    ../openvswitch-switch_2.3.0-1_amd64.deb \
    ../openvswitch-datapath-dkms_2.3.0-1_all.deb
popd > /dev/null
rm -rf /tmp/ovs-2.3 /tmp/*.deb 

echo ">>> Installing Mininet"
curl -kL https://github.com/mininet/mininet/archive/2.1.0.tar.gz | tar xzf - -C /tmp
pushd /tmp/mininet-2.1.0 > /dev/null
for p in /vagrant/vagrant.d/mininet/*; do
    patch -Np1 < $p
done
DEB_BUILD_OPTIONS='nocheck' fakeroot debian/rules binary
dpkg -i ../mininet_2.1.0-0ubuntu1_amd64.deb
popd > /dev/null
rm -rf /tmp/mininet-2.1.0 /tmp/mininet_2.1.0-0ubuntu1_amd64.deb

