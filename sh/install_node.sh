#!/bin/bash
NODE_VERSION=0.4.10
NODE_FILE=node-v$NODE_VERSION
NPM_VERSION=1.0.22

apt-get update
apt-get install -y build-essential git-core nginx libssl-dev pkg-config curl

# Install node
mkdir -p $HOME/local/node
git clone git://github.com/joyent/node.git
cd node
git checkout v$NODE_VERSION
./configure --prefix=$HOME/local/node
make
make install
cd

# Setup basic nginx proxy.
cat > /etc/nginx/sites-available/node_proxy.conf <<EOF
server {
    listen       80;
    # proxy to node
    location / {
        proxy_pass         http://127.0.0.1:1601/;
    }
}
EOF
ln -s /etc/nginx/sites-available/node_proxy.conf /etc/nginx/sites-enabled/node_proxy.conf
/etc/init.d/nginx restart

# install npm
mkdir -p $HOME/local/npm
git clone git://github.com/isaacs/npm.git
cd npm
git checkout v$NPM_VERSION
./configure --prefix=$HOME/local/npm
make
make install
cd

# install npm packages
npm install -g express socket.io jade coffee-script vows
