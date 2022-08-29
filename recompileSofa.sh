#!/bin/bash

version="v21.12"

cd ~/sofa/src 
git pull
git checkout $version

cd ~/sofa-plugins/SoftRobots
git pull
git checkout $version
cd ~/sofa-plugins/SofaPython3
git pull
git checkout $version
cd ~/sofa-plugins/STLIB
git pull
git checkout $version

rm -rf /home/nick/sofa/$version
mkdir /home/nick/sofa/$version

cd ~/sofa/$version

cmake -G "CodeBlocks - Ninja" -DCMAKE_C_COMPILER=/usr/bin/clang-12 -DCMAKE_CXX_COMPILER=/usr/bin/clang++-12 -DCMAKE_PREFIX_PATH=/home/nick/Qt/5.13.2/gcc_64 -DSOFA_BUILD_METIS=ON -DSOFA_EXTERNAL_DIRECTORIES=/home/nick/sofa-plugins -DSOFTROBOTS_IGNORE_ERRORS=ON -Dpybind11_DIR=/home/nick/.local/lib/python3.8/site-packages/pybind11/share/cmake/pybind11 -DPLUGIN_SOFTROBOTS=ON -DPLUGIN_SOFAPYTHON3=ON -DSTLIB=ON -S /home/nick/sofa/src -B /home/nick/sofa/$version

ninja

rm -rf /home/nick/sofa/build
mkdir /home/nick/sofa/build
cp -a /home/nick/sofa/$version/. /home/nick/sofa/build
