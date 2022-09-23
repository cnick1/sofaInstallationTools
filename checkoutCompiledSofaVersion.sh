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

cd ~/sofa/src && git checkout $version

cd ~/sofa-plugins/SoftRobots && git checkout $version
cd ~/sofa-plugins/SofaPython3 && git checkout $version
cd ~/sofa-plugins/STLIB && git checkout $version

cd ~/sofa/$version

rm -rf $HOME/sofa/build
mkdir $HOME/sofa/build
cp -a $HOME/sofa/$version/. $HOME/sofa/build
