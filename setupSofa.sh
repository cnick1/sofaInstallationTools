#!/bin/bash
VERSION="v22.06"
sudo apt update && sudo apt upgrade -y
sudo apt install git curl -y

#check if git email / name have been set already
email=`git config --global --get user.email`
if [ $? -eq 1 ];then
    echo "Couldn't find git user.email"
    read -p "Enter your email for git: " email
    git config --global user.email $email
else
    echo "Found git user.email: $email"
fi

name=`git config --global --get user.name`
if [ $? -eq 1 ];then

    echo "Couldn't find git user.name"
    read -p "Enter your name for git: " name
    git config --global user.name $name
else
    echo "Found git user.name: $name"
fi

git clone https://github.com/cnick1/sofaInstallationTools.git $HOME/sofaInstallationTools

sudo apt install build-essential software-properties-common -y
sudo apt install gcc gcc-10 cmake cmake-gui ccache -y
read -t 60 -p "Select which IDE's to install"$'\n'"(0)None (1)Clion-Professional (2)Code (3) both <default>"$'\n'"Seleciton: " ide
case $ide in
  0)
    echo -n "Skipping IDE install"
    ;;

  1)
    sudo snap install --classic clion-professional
    ;;
  2)
    sudo snap install --classic code
    ;;
  *)
    sudo snap install --classic code
    sudo snap install --classic clion-professional
    ;;
esac

cd ~
if [ ! -f "qt-unified-linux-x64-online.run" ]
then
    wget https://download.qt.io/official_releases/online_installers/qt-unified-linux-x64-online.run
else
    echo "Qt downloader file exists."
fi

if [ ! -d "$HOME/Qt/" ]
then
    message="The Qt installer is about to begin. Be ready with your credentials for a Qt account and ensure to select the following:\n    - an install directory of $HOME/Qt/\n    - custom installation\n    -Select Archive and hit filter\n    - On Select Components:\n        -- Qt -> version 5.13.2 (some other 5.* version work but 5.13.2 recommended) --> Select Desktop gcc 64-bit,Qt Charts, and Qt Web Engine\n"
    zenity --question --no-wrap --title "setupSofa: Qt Installer Instructions" --text="${message}This message will be repeated interminal so you can refer to it during the Qt setup.\nClick yes to continue..."
    echo -e "${message}"
    chmod +x qt-unified-linux-x64-online.run
    ./qt-unified-linux-x64-online.run 
fi

sudo apt install libopengl0 libboost-all-dev -y

sudo apt install python3.8-dev

if ! [[ "$PATH" =~ .*${HOME}/.local/bin.* ]]; then
    export PATH="$PATH:$HOME/.local/bin"
    echo "export PATH=$PATH:$HOME/.local/bin" >> $HOME/.bashrc
fi

sudo apt-get install python3-distutils \
&& curl -L https://bootstrap.pypa.io/pip/get-pip.py --output /tmp/get-pip3.py \
&& python3.8 /tmp/get-pip3.py \
&& python3.8 -m pip install --upgrade pip \
&& python3.8 -m pip install numpy scipy pybind

sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 1

sudo apt install libpng-dev libjpeg-dev libtiff-dev libglew-dev zlib1g-dev libeigen3-dev nvidia-cuda-toolkit libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libblas-dev liblapack-dev -y

mkdir $HOME/sofa
mkdir $HOME/sofa/build
mkdir $HOME/sofa/build/$VERSION


git clone -b $VERSION https://github.com/sofa-framework/sofa.git $HOME/sofa/src

plugins_dir=$HOME/sofa-plugins
mkdir $plugins_dir
cd $plugins_dir
git clone https://github.com/sofa-framework/SofaPython3
git clone https://github.com/SofaDefrost/SoftRobots
git clone https://github.com/SofaDefrost/STLIB.git

# make CMAKE FILE FOR PLUGINS 
echo -e "cmake_minimum_required(VERSION 2.8.12)\n\nfind_package(SofaFramework)\n\nsofa_add_subdirectory(plugin SofaPython3/  SofaPython3)\nsofa_add_subdirectory(plugin STLIB/  STLIB)\nsofa_add_subdirectory(plugin SoftRobots/  SoftRobots)" > $plugins_dir/CMakeLists.txt

for f in $HOME/Qt/5*; do
	prefix_path=$f
	break	
done

if [ -z $PYTHONPATH ];then 
	py_path="export PYTHONPATH=$HOME/sofa-plugins/STLIB/python3/src:$HOME/sofa/build/$VERSION/lib/python3/site-packages"
	$py_path
	echo $py_path >> $HOME/.bashrc
fi

if [ -z "$SP3_BLD" ];then
    sp3_path="export SP3_BLD=$HOME/sofa/build/$VERSION"
    ${sp3_path}
    echo ${sp3_path} >> $HOME/.bashrc
fi

if [ -z "$SOFA_BLD" ]
then

    sofa_bld_path="export SOFA_BLD=$HOME/sofa/build/$VERSION"
    $sofa_bld_path
    echo $sofa_bld_path >> $HOME/.bashrc
fi

if [ -z "$SOFA_ROOT" ]
then
    sofa_root="export SOFA_ROOT=$HOME/sofa/build/$VERSION"
    $sofa_root
    echo $sofa_root >> $HOME/.bashrc
    echo "alias sofa='$SOFA_ROOT/bin/runSofa'" >> .bash_aliases
fi



cd $HOME/sofa/src
CMD="-G \"CodeBlocks - Unix Makefiles\" -DCMAKE_C_COMPILER=/usr/bin/gcc -DCMAKE_CXX_COMPILER=/usr/bin/g++ -DSOFA_EXTERNAL_DIRECTORIES=$plugins_dir -DCMAKE_PREFIX_PATH=${prefix_path}/gcc_64 -Dpybind11_DIR=$HOME/.local/lib/python3.8/site-packages/pybind11/share/cmake/pybind11/ -DPLUGIN_SOFAPYTHON3=ON -DPLUGIN_STLIB=ON -DPLUGIN_SOFTROBOTS=ON -S $HOME/sofa/src -B $HOME/sofa/build/$VERSION"
cmake $CMD
echo "alias runSofa=\"$HOME/sofa/build/$VERSION/bin/runSofa\"" >> $HOME/.bash_aliases

cd $HOME/sofa/build/$VERSION
make -j 16

echo -e "\n\n\n THIS IS THE CMAKE ARGUMENTS TO INCLUDE FOR DEVELOPING YOUR PROGRAM IN CLION AND OTHER IDEs: \n ${CMD}\n\n\n"
echo "This will be written to ~/cmake_cmd.txt for refrence when recompiling a dev branch."
echo "$CMD" > $HOME/cmake_cmd.txt


