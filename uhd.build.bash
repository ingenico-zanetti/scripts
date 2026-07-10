#!/bin/bash
mkdir ~/Src
cd ~/Src
tar jxvf ~/uhd_v4.9.0.0_ingenico.tar.bz2 
cd uhd/
cd host/
mkdir build
cd build
cmake ../
make -j$(nproc)
make test
sudo make install
sudo ldconfig
sudo /usr/local/lib/uhd/utils/uhd_images_downloader.py
cd /usr/local/lib/uhd/utils/
sudo cp uhd-usrp.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger
cd ~/Src

