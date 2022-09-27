#!/bin/bash

if [ $# -eq 0 ]
then
    version="master"
else
    if [ $1 == stable ]
    then
        version="v21.12"
    else
        version=$1
    fi
fi

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

rm -rf $HOME/sofa/$version
mkdir $HOME/sofa/$version

cd ~/sofa/$version

for f in $HOME/Qt/6*; do
	prefix_path=$f
	break
done
cmake -G "CodeBlocks - Ninja" -DCMAKE_C_COMPILER=/usr/bin/clang-12 -DCMAKE_CXX_COMPILER=/usr/bin/clang++-12 -DCMAKE_PREFIX_PATH=$prefix_path/bin -DSOFA_EXTERNAL_DIRECTORIES=$HOME/sofa-plugins -Dpybind11_DIR=$HOME/.local/lib/python3.8/site-packages/pybind11/share/cmake/pybind11 -DPLUGIN_SOFTROBOTS=ON -DPLUGIN_SOFAPYTHON3=ON -DPLUGIN_STLIB=ON -S $HOME/sofa/src -B $HOME/sofa/$version

ninja

rm -rf $HOME/sofa/build
mkdir $HOME/sofa/build
cp -a $HOME/sofa/$version/. $HOME/sofa/build

while true; do
    read -p "Do you wish to run SOFA? [Y/n] " yn
    case "${yn:-Y}" in
        [Yy]* ) $SOFA_BLD/bin/runSofa; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
