#!/bin/bash
ROOTDIR=${HOME}
SCRIPTDIR=${ROOTDIR}/scripts

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
sudo ldconfig
sudo srsran_install_configs.sh service
cd $SCRIPTDIR
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
cd $SCRIPTDIR
sudo cp lte_start.sh /usr/local/bin
sudo cp enb.sh /usr/local/bin
sudo cp epc.sh /usr/local/bin
sudo chmod +x /usr/local/bin/*.sh

sudo cp lte.service /etc/systemd/system/
sudo systemctl daemon-reload
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

cd ${SCRIPTDIR}

# Use nginx to serve the file, through a virtual host zatto.free.fr
sudo apt-get install nginx -y
sudo mkdir -p /var/www/zatto.free.fr/html/
sudo cp zatto.free.fr /etc/nginx/sites-available/
sudo ln -sf /etc/nginx/sites-available/zatto.free.fr /etc/nginx/sites-enabled/zatto.free.fr

# Populate the site
echo "<h1>Welcome to zatto.free.fr</h1>" | sudo tee /var/www/zatto.free.fr/html/index.html >/dev/null
creator 1 | sudo tee /var/www/zatto.free.fr/html/1M.HTML >/dev/null
creator 10 | sudo tee /var/www/zatto.free.fr/html/10M.HTML >/dev/null
creator 50 | sudo tee /var/www/zatto.free.fr/html/50M.HTML >/dev/null
creator 100 | sudo tee /var/www/zatto.free.fr/html/100M.HTML >/dev/null
creator 500 | sudo tee /var/www/zatto.free.fr/html/500M.HTML >/dev/null

sudo systemctl restart nginx

