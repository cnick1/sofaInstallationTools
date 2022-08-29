#!/bin/bash

version="master"

cd ~/sofa/src && git checkout $version

cd ~/sofa-plugins/SoftRobots && git checkout $version
cd ~/sofa-plugins/SofaPython3 && git checkout $version
cd ~/sofa-plugins/STLIB && git checkout $version

cd ~/sofa/$version

rm -rf /home/nick/sofa/build
cp -a /home/nick/sofa/$version/. /home/nick/sofa/build
