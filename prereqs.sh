#!/bin/bash
############### prereqs.sh #################
# Description: Support script to wlconfig.py
#
# Authored by Dan Perkins (@DanielRPerkins)
# Posted by Matt Brender (@mjbrender)
#
# Requires outbound internet access over port 80/443


# Add software properties
sudo apt-get install -qq software-properties-common

# Add PPAs
sudo apt-add-repository -y ppa:ansible/ansible &> /dev/null || exit 1

# Update
sudo apt-get update -qq

# Install apps
sudo apt-get install -qq ubuntu-dev-tools arp-scan ansible

# Add pip and Python libs
wget -q https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py
sudo pip install envoy
rm get-pip.py

# Get and build latest fio snapshot
wget -q http://brick.kernel.dk/snaps/fio-2.1.11.tar.gz
tar -xvf fio-2.1.11.tar.gz
cd fio-2.1.11
sudo ./configure &> /dev/null || exit 1
sudo make &> /dev/null || exit 1
sudo make install &> /dev/null || exit 1
cd .. ; rm -rf fio-2.1.11*

# Enable cronjobs for @reboot
sudo update-rc.d cron defaults &> /dev/null || exit 1

