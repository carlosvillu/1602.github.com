#!/bin/bash
NODE_VERSION=0.4.10
NPM_VERSION=1.0.22

sudo apt-get update
sudo apt-get install -y build-essential git-core nginx libssl-dev pkg-config curl

# Install node
mkdir -p $HOME/local/node
git clone git://github.com/joyent/node.git
cd node
git checkout v$NODE_VERSION
./configure --prefix=$HOME/local/node
make
make install
cd

echo 'export PATH=$HOME/local/node/bin:$PATH' >> ~/.profile
echo 'export NODE_PATH=$HOME/local/node:$HOME/local/node/lib/node_modules' >> ~/.profile
source $HOME/.profile

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

echo 'export PATH=$HOME/local/npm/bin:$PATH' >> ~/.profile
source ~/.profile

# install npm packages
npm install -g express socket.io jade coffee-script vows
