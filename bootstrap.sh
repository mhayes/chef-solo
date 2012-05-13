#!/usr/bin/env bash
apt-get -y update
apt-get -y install build-essential git zlib1g-dev libssl-dev libreadline-gplv2-dev libyaml-dev
cd /tmp
rm -rf ruby-build
git clone git://github.com/sstephenson/ruby-build.git ruby-build
cd ruby-build
git checkout e69f559c7edcd2b49d0e27c662ac923391544bcf
./install.sh

ruby-build 1.9.3-p194 /usr

echo "Updating rubygems"
gem update --system

echo "Installing chef client"
gem install chef --no-ri --no-rdoc

echo "Installing bundler"
gem install bundler --no-ri --no-rdoc

echo "You are now ready to be conquer the world!"