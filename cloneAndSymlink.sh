#!/bin/bash

cd /mnt/e/share
git clone https://github.com/cnick1/sofaInstallationTools.git
ln -s /mnt/e/share/sofaInstallationTools /home/nick

git clone https://github.com/cnick1/softRoboticsMR.git
ln -s /mnt/e/share/softRoboticsMR /home/nick

cd /home/nick/softRoboticsMR
git checkout modelOrderReduction

echo "IN ORDER TO USE THE TRASH BIN ON THE DRIVE, EDIT THE MOUNT OPTIONS TO INCLUDE: uid=1000,gid=1000"