#!/bin/bash
ROOTDIR=$PWD

# Build and install srsRAN 4G
mkdir ~/Src
cd ~/Src
tar jxvf ${ROOTDIR}/srsRAN_4G.release_25_10.ingenico.tar.bz2
cd srsRAN_4G
mkdir build
cd build
cmake ../
make -j$(nproc)
make test
sudo make install
sudo srsran_install_configs.sh service
cd $ROOTDIR
# overwrite some configuration files with ours
sudo cp -vf enb.conf epc.conf user_db.csv /etc/srsran/

# Install tools to get the JSON metrics and provide them through an HTTP Server
cd ~/Src
tar jxvf ${ROOTDIR}/compactor.tar.bz2
tar jxvf ${ROOTDIR}/supersimplehttp.tar.bz2
cd jsonCompactor
make
sudo make install
cd ../supersimplehttp
sudo cp server7.py /usr/local/bin

# Install LTE as a service
sudo cp lte_start.sh /usr/loca/bin
sudo cp enb.sh /usr/loca/bin
sudo cp epc.sh /usr/loca/bin
sudo chmod +x /usr/local/bin/*.sh

sudo cp lte.service /etc/systemd/system/
sudo systemctl daemon-realod
sudo systemctl enable lte
sudo systemctl start lte

# Create an HTTP Server for file transfer tests
#
# Tool to create massive files very hard to compress
#
cd ~/Src
tar jxvf ${ROOTDIR}/creator.tar.bz2
cd creator
sudo make install

cd ${ROOTDIR}

# Use nginx to serve the file, through a virtual host zatto.free.fr
sudo apt-get install nginx -y
sudo mkdir -p /var/www/zatto.free.fr/html/
sudo cp zatto.free.fr /etc/nginx/sites-available/
sudo cd /etc/nginx/sites-enabled/
sudo ln -sf ../sites-available/zatto.free.fr
cd -

# Populate the site
echo "<h1>Welcome to zatto.free.fr</h1>" | sudo tee /var/www/zatto.free.fr/html/index.html >/dev/null
sudo creator 1 > /var/www/zatto.free.fr/html/1M.HTML
sudo creator 10 > /var/www/zatto.free.fr/html/10M.HTML
sudo creator 50 > /var/www/zatto.free.fr/html/50M.HTML
sudo creator 100 > /var/www/zatto.free.fr/html/100M.HTML
sudo creator 500 > /var/www/zatto.free.fr/html/500M.HTML

