#!/bin/bash

cd ~ 
mkdir ~/sofa
mkdir ~/sofa/src
mkdir ~/sofa/build

sudo apt update && sudo apt upgrade -y
sudo apt install git -y

read -p "Enter your email for git: " email
git config --global user.email $email
read -p "Enter your name for git: " name
git config --global user.name $name

git clone https://github.com/cnick1/sofaInstallationTools.git


git clone https://github.com/sofa-framework/sofa.git ~/sofa/src
cd ~/sofa/src && git checkout v21.12

sudo apt install build-essential software-properties-common -y
sudo apt install clang-12 -y
cd ~ 
if [ ! -f "cmake-3.22.2-linux-x86_64.tar.gz" ]
then
    wget https://github.com/Kitware/CMake/releases/download/v3.22.2/cmake-3.22.2-linux-x86_64.tar.gz
else
    echo "cmake downloader file exists."
fi

tar xf cmake-3.22.2-linux-x86_64.tar.gz

if ! [[ $(command -v code) ]]; then
    sudo snap install --classic code
fi

#check if env variables exist and if missing add them, check path before appending to prevent cluttered path variable
if ! [[ "$PATH" =~ .*"cmake-3.22.2-linux-x86_64/bin".* ]]; then
    export PATH="$HOME/cmake-3.22.2-linux-x86_64/bin:$PATH"
    echo "export PATH=\"\$HOME/cmake-3.22.2-linux-x86_64/bin:\$PATH\"" >> $HOME/.bashrc
fi

if [ -z "$PYTHONPATH" ]
then
    export PYTHONPATH="$HOME/sofa-plugins/STLIB/python3/src:$HOME/sofa/build/lib/python3/site-packages"
    echo " export PYTHONPATH=\"\$HOME/sofa-plugins/STLIB/python3/src:\$HOME/sofa/build/lib/python3/site-packages\"" >> $HOME/.bashrc
fi

if [ -z "$SP3_BLD" ]
then
    export SP3_BLD=$HOME/sofa/build
    echo "export SP3_BLD=\"\$HOME/sofa/build\"" >> $HOME/.bashrc
fi

if [ -z "$SOFA_BLD" ]
then
    export SOFA_BLD=\$HOME/sofa/build
    
    echo "export SOFA_BLD=\"\$HOME/sofa/build\"" >> $HOME/.bashrc
fi

if [ -z "$SOFA_ROOT" ]
then
    export SOFA_ROOT=$HOME/sofa/build
    echo "export SOFA_ROOT=\"\$HOME/sofa/build\"" >> $HOME/.bashrc
    echo "alias sofa='$SOFA_ROOT/bin/runSofa'" >> .bash_aliases
fi

if [ -z "$GUROBI_HOME" ]
then
    export GUROBI_HOME="/opt/gurobi952/linux64"
    
    echo "export GUROBI_HOME=\"/opt/gurobi952/linux64\"" >> $HOME/.bashrc
fi

if [ -z "$LD_LIBRARY_PATH" ]
then
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
    echo "export LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH}:\${GUROBI_HOME}/lib\"" >> $HOME/.bashrc
elif ! [[ "$LD_LIBRARY_PATH" =~ .*"${GUROBI_HOME}/lib".* ]]; then
    export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
    echo "export LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH}:\${GUROBI_HOME}/lib\"" >> $HOME/.bashrc

fi


if [ -z "$GRB_LICENSE_FILE" ]
then
    export GRB_LICENSE_FILE="/opt/gurobi952/gurobi.lic"
    echo "export GRB_LICENSE_FILE=\"/opt/gurobi952/gurobi.lic\"" >> $HOME/.bashrc
fi

if ![[ "$PATH" =~ .*"${GUROBI_HOME}/lib".* ]]; then
	export PATH="${PATH}:${GUROBI_HOME}/bin"
	echo "export PATH=\"\${PATH}:\${GUROBI_HOME}/bin\"" >> $HOME/.bashrc
	
fi	

sudo apt install ninja-build ccache libxcb-xinerama0 libopengl0 libboost-all-dev python3 python3-numpy python3-scipy python3-pip -y
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1
sudo apt install libpng-dev libjpeg-dev libtiff-dev libglew-dev zlib1g-dev libeigen3-dev libcgal-dev libcgal-qt5-dev liboce-ocaf-dev libassimp-dev nvidia-cuda-toolkit libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libblas-dev liblapack-dev -y

yes | pip install pybind11==2.6.0


mkdir ~/sofa-plugins
git clone https://github.com/SofaDefrost/SoftRobots ~/sofa-plugins/SoftRobots
git clone https://github.com/SofaDefrost/STLIB.git ~/sofa-plugins/STLIB
git clone https://github.com/sofa-framework/SofaPython3.git ~/sofa-plugins/SofaPython3

cd ~/sofa-plugins/SoftRobots && git checkout v21.12
cd ~/sofa-plugins/STLIB && git checkout v21.12
cd ~/sofa-plugins/SofaPython3 && git checkout v21.12

cd ~/sofa-plugins/
if [ -f "CMakeLists.txt" ]
then
    echo "CMakeLists.txt already exists."
else
    touch CMakeLists.txt
    printf "cmake_minimum_required(VERSION 3.11)\n\nfind_package(SofaFramework)\n\nsofa_add_plugin(STLIB/  STLIB VERSION 1.0)\nsofa_add_plugin(SoftRobots/  SoftRobots VERSION 1.0)\nsofa_add_plugin(SofaPython3/ SofaPython3 VERSION 1.0)" >> CMakeLists.txt
fi

cd ~
if [ ! -f "qt-unified-linux-x64-online.run" ]
then
    wget https://download.qt.io/official_releases/online_installers/qt-unified-linux-x64-online.run
else
    echo "Qt downloader file exists."
fi

if [ ! -d "$HOME/Qt/" ]
then
    chmod +x qt-unified-linux-x64-online.run
    ./qt-unified-linux-x64-online.run 
fi
for f in $HOME/Qt/6*; do
	prefix_path=$f
	break
done
echo ${prefix_path}
cmake -G "CodeBlocks - Ninja" -DCMAKE_C_COMPILER=/usr/bin/clang-12 -DCMAKE_CXX_COMPILER=/usr/bin/clang++-12 -DCMAKE_PREFIX_PATH=${prefix_path}/gcc_64 -S $HOME/sofa/src -B $HOME/sofa/build
cd $HOME/sofa/build
ninja

echo "Start a new terminal session before rerunning the setupSofa.sh script again to apply .bashrc changes and prevent clutter to environment variables."

while true; do
    read -p "Do you wish to run SOFA? [Y/n] " Yn
    case "${yn:-Y}" in
        [Yy]* ) "$HOME/sofa/build/bin/runSofa"; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

