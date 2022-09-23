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

if [ ! command -v code &> /dev/null ]
then
    sudo snap install --classic code
    printf "\nexport PATH=\"`pwd`/cmake-3.22.2-linux-x86_64/bin:\$PATH\" # save it in .bashrc if needed\n\n" >> .bashrc
    printf "\nexport PYTHONPATH=\"\$HOME/sofa-plugins/STLIB/python3/src:\$HOME/sofa/build/lib/python3/site-packages\"\nexport SP3_BLD=$HOME/sofa/build\nexport SOFA_BLD=\$HOME/sofa/build\nexport SOFA_ROOT=\$HOME/sofa/build\nexport GUROBI_HOME=\"/opt/gurobi952/linux64\"\nexport PATH=\"\${PATH}:\${GUROBI_HOME}/bin\"\nexport LD_LIBRARY_PATH=\"\${LD_LIBRARY_PATH}:\${GUROBI_HOME}/lib\"\nexport GRB_LICENSE_FILE=/opt/gurobi952/gurobi.lic\n\n " >> .bashrc
    printf "\nalias sofa='$SOFA_ROOT/bin/runSofa' \n" >> .bashrc
    source ~/.bashrc
    exit
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

cmake -G "CodeBlocks - Ninja" -DCMAKE_C_COMPILER=/usr/bin/clang-12 -DCMAKE_CXX_COMPILER=/usr/bin/clang++-12 -DCMAKE_PREFIX_PATH=/home/nick/Qt/5.13.2/gcc_64 -S /home/nick/sofa/src -B /home/nick/sofa/build
cd /home/nick/sofa/build
ninja

while true; do
    read -p "Do you wish to run SOFA? [Y/n] " Yn
    case "${yn:-Y}" in
        [Yy]* ) $SOFA_BLD/bin/runSofa; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done



if [ ! -f "gcm-linux_amd64.2.0.785.deb" ]
then
    wget https://github.com/GitCredentialManager/git-credential-manager/releases/download/v2.0.785/gcm-linux_amd64.2.0.785.deb
else
    echo "git-credential-manager downloader file exists."
fi

sudo dpkg -i gcm-linux_amd64.2.0.785.deb
git-credential-manager-core configure
git config --global credential.credentialStore cache
git config --global credential.cacheoptions "--timeout 72000"

git config --global credential.guiPrompt false
git config --global credential.gitHubAuthModes browser


git clone https://github.com/cnick1/sofaInstallationTools.git
git clone https://github.com/cnick1/softRoboticsMR.git

gsettings set org.gnome.shell.extensions.dash-to-dock isolate-workspaces true
