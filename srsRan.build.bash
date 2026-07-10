#!/bin/bash
mkdir ~/Src
cd ~/Src
tar jxvf srsRAN_4G.release_25_10.ingenico.tar.bz2
cd srsRAN_4G
mkdir build
cd build
cmake ../
make -j$(nproc)
make test
sudo make install
sudo srsran_install_configs.sh service

