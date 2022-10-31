# Summary
If you want to just run the installer script, run ```setupSofa.sh'''. This will install SOFA and all its dependencies. 



# Sofa/Linux Installation and Compilation
Some other sources for instructions on building SOFA:
* https://www.sofa-framework.org/community/doc/getting-started/build/linux/
* https://github.com/StanfordASL/soft-robot-control/


This notebook will work through the details to install Linux, configure it, download Sofa and all its dependencies, download all of the tools used to *compile* Sofa, and finally how to compile the source code into an executable binary program. Hopefully, I will be able to cross-compile in Linux for Windows so that I only need to use Linux occasionally.

NOTE: The file setupSofa.sh is a bash script which will do all of the steps in this notebook automatically. This ReadMe file just serves to explain all of the steps, which may help identify any errors which may occur. Try to just run ```bash setupSofa``` first. 

# Preliminaries for formatting a hard drive in Windows to install Linux onto
0.    To remove an old partition, use Disk Management. If the EFI wont let you delete it, run cmd as admin and run (where x corresponds to the desired disk):
```
diskpart
list disk 
select disk x
clean
```
It may give an error about not having permission, just close it and run it again. Check that it worked in Disk Management now, and create a NTFS Partiton and proceed.

# How to install Ubuntu on an external drive
1.    Download Ubuntu ISO (20.04) and use Balena Etcher to create a bootable installation medium.

```
https://ubuntu.com/download/alternative-downloads
https://www.balena.io/etcher/
```

2.    CHANGE TO NVIDIA GPU BEFORE DOING THIS. (If you install Nvidia drivers, the os might only work on your computer...) Reboot and mash F2 to boot into the BIOS. Select the first partition on the Installation Medium as the boot drive, and save and exit the bios to boot into it. Run the installer and install Linux on the external drive.
*   Select the "Something else" option 
*   Use "-" to delete any partitions on the external drive 
*   Use "+" to make a new partition on the external drive on the new "free space"
  *   Format it as "Ext4 Journalling"
  *   Set the mount point to "/"
*   Make sure to select the drive you wish to install Linux on as the bootloader option
*   Make sure to select 3rd party drivers. It will make the NVIDIA drivers work.
*   If you install with the AMD GPU, no problem, you just can't switch during using Linux. You will just have to boot into windows to switch, and then reinstall some drivers.

3.    The first thing I would do is install MSEdge so that my password manager is installed. Then I can easily access github, google drive, etc
*   When downloading the file, don't use the software manager. Just download the deb and run it. 

At the time of writing this, MSEdge has a bug which throws off some other commands. A fix can be obtained by running this command: `wget https://packages.microsoft.com/keys/microsoft.asc && sudo apt-key add microsoft.asc `

4.    Also take a moment to configure any simple system settings such as scaling, wifi, etc.

*   To use gestures, do the following: https://ubuntuhandbook.org/index.php/2021/06/multi-touch-gestures-ubuntu-20-04/

Optional quality of life software: 

1.   VScode: "Code" in Ubuntu Software

## How to clone your hard drive
Once you get SOFA installed, or at any point you worry you might break something and need to start from scratch, an alternative would be to clone you hard drive as a save point/checkpoint. If you break something, you can then `reload from the last checkpoint' to avoid a lot of extra work. We basically will just clone the hard drive to another drive. This is also useful if you wish to share the drive with someone else so they can boot and pick up where you left off. Eventually, we would like to learn how to use Docker or virtual machines to do something similar. NOTE: If you have any sensitive information (passwords, etc) on the Ubuntu system you are cloning, you will be handing those over to someone! 


To clone the drive, we are going to just use the following command (```sudo dd if=source of=destination bs=1024k status=progress```)

```
sudo dd if=source of=destination bs=1024k status=progress
```

This will go a lot faster if you can resize the partition you are copying to be as small as possible; this may require booting from another drive though, which you might not be able to do. 

Once the drive is cloned, you *should* be able to boot from it on the same computer, but booting to that drive from another computer might just take you to the grub screen. If this happens, boot into linux on a working drive or a live boot from a USB installation medium, and then run ```sudo update-grub```, which should tell grub that there is another linux drive it should recognize to boot from. More information here if necessary: https://askubuntu.com/questions/1205282/ubuntu-cloned-from-hdd-to-ssd-doesnt-boot


Useful for resizing partitions, etc.:
(If it is not already installed) Download GParted with this command:
```
sudo apt-get install gparted
```
Open it by opening your applications and finding gparted.

# Software Installation
With the basics out of the way, let's move on to more detailed software installation.

0.    Update software: Open Update Manager if it doesn't automatically open. Select all and click "install updates". Click yes for the dependencies, and then enter your password. The software will download and then install.

*    NVIDIA Drivers: In ubuntu, they should automatically install if the dGPU was selected in Windows.

## Install SOFA 
https://www.sofa-framework.org/download/

Follow the instructions here to clone the Git repo and build on Linux. Summarized below.

1.   Clone the git in home directory **assuming v21.12**. 



> A quick note about versions: since SOFA is such a development product, it seems like most people use the "unstable" master/nightly source code if they are building themselves. This presumes that the plugins are also updated quickly enough to keep up with the main SOFA code. Alternatively, there are "stable" bi-annual releases; for example, v21.12 refers to the stable release from December 2021. Upcoming is the v22.06 release, i.e. June 2022. **If you use an "old" version of SOFA, i.e. anything other than the current master branch latest commit, you must ensure that all plugins are cloned from an equivalent release.** Hence in this tutorial, we will use v21.12 everywhere.


```
sudo apt install git
mkdir ~/sofa
mkdir ~/sofa/src
mkdir ~/sofa/build
git clone https://github.com/sofa-framework/sofa.git ~/sofa/src
cd ~/sofa/src && git checkout v21.12
cd ~/sofa/build 
```

(This will take a long time, so just continue with the next steps.)



2.   First we install some standard tools for compiling software:
```
sudo apt update
sudo apt install build-essential software-properties-common
```


3.  Next we install the compilers for the C language. 
Clang is a fast compiler; we can install the latest version available by checking with
```
apt-cache search '^clang-[0-9.]+$'
```
and install the latest one with the usual command (example with clang-12):
```
sudo apt install clang-12
```

4. 
Install the latest CMake. 
For example while in home directory, download cmake with
```
cd ~
wget https://github.com/Kitware/CMake/releases/download/v3.24.1/cmake-3.24.1-linux-x86_64.tar.gz
```
Then, unpack with 
```
tar xf cmake-3.24.1-linux-x86_64.tar.gz
```
and add cmake to path:
Option 1) (With VSCode editor) Run ```code .bashrc``` and add the line
```
export PATH="`pwd`/cmake-3.24.1-linux-x86_64/bin:$PATH" # save it in .bashrc if needed
```

or Option 2) run 
``` 
printf "export PATH=\"`pwd`/cmake-3.24.1-linux-x86_64/bin:\$PATH\" # save it in .bashrc if needed\n\n" >> .bashrc
```

Check if it worked in a new terminal with: 
```
which cmake # Should give path from above
which cmake-gui # Should give path from above
cmake --version # Should print version
cmake-gui --version # Should print version
``` 

Note, even if you close and reopen the terminal, it should still work!
5. Ninja: 
```
sudo apt install ninja-build
```

5. Cmake supports caching the cmake file so that you can repoen it and edit rather than starting from scratch. 
Install the following to accelerate compiling subsequent times: 
``` 
sudo apt install ccache 
```

6. Install Qt: https://download.qt.io/official_releases/online_installers/
  *   Make sure to enable Charts and WebEngine components.

```
wget https://download.qt.io/official_releases/online_installers/qt-unified-linux-x64-online.run
```

Make the ```.run``` file executable with 
```
chmod +x qt-unified-linux-x64-online.run
``` 
Then, run the file with 
``` 
./qt-unified-linux-x64-online.run 
```

If necessary, install the library ```sudo apt install libxcb-xinerama0```

  Log in with your Qt credentials, and run the installer. 
  **Make sure to enable Charts and WebEngine components.**

  Following the Sofa docs, it seems it is advisable to select the dropdown ```Qt-Qt 5.13.2``` and just the ```desktop gcc 64-bit```, ```Qt Charts```, and ```Qt WebEngine```

  
7. OpenGL
```
sudo apt install libopengl0
```


8. Boost (>= 1.65.1)
```
sudo apt install libboost-all-dev
```

9. Python 3.8
```
sudo apt install python3 python3-numpy python3-scipy
```
  *  Make python3 default
```
sudo  update-alternatives --install /usr/bin/python python /usr/bin/python3 1
```
Check python version using ```python --version```
10. Additional libraries: libPNG, libJPEG, libTIFF, Glew, Zlib
```
sudo apt install libpng-dev libjpeg-dev libtiff-dev libglew-dev zlib1g-dev
```
11. SOFA v20.06 and newer also need Eigen (>= 3.2.10)
```
sudo apt install libeigen3-dev
```

## Optional Plugins: 

1. CGALPlugin
```
sudo apt install libcgal-dev libcgal-qt5-dev
```
2. MeshSTEPLoader
```
sudo apt install liboce-ocaf-dev
```
3. SofaAssimp
```
sudo apt install libassimp-dev
```
4. SofaCUDA
```
sudo apt install nvidia-cuda-toolkit
```
5. SofaHeadlessRecorder
```
sudo apt install libavcodec-dev libavformat-dev libavutil-dev libswscale-dev
```
6. SofaPardisoSolver
```
sudo apt install libblas-dev liblapack-dev
```

## Install SOFA plugins and dependencies
(Based on https://github.com/StanfordASL/soft-robot-control)

--- 
##### Get Anaconda
NOTE: These steps are only necessary for trying to reproduce Sander's work (https://github.com/StanfordASL/soft-robot-control); however, that repo is broken, so you may as well skip these. The only requirement is pybind11, which can be downloaded without anaconda with ```pip install pybind11==2.6.0```


Download Anaconda with 
```
wget https://repo.anaconda.com/archive/Anaconda3-2021.11-Linux-x86_64.sh
```
and then run the installer with 
```
bash Anaconda3-2021.11-Linux-x86_64.sh
```

Anaconda enables you to make "virtual environments" where a specific version of Python and all of its dependencies can be installed without messing with the system's default Python installation. Create and activate `sofa` conda environment
```
conda create --name sofa python=3.8
```
Then run
```
conda activate sofa
conda config --set auto_activate_base false
conda activate sofa
```

Note that you can activate and deactivate this environment with ``conda activate`` and ``conda deactivate``.

---
##### Get Python dependencies

Now install the following python packages (run these one at a time just to make sure nothing fails):
```
conda install numpy
```
```
conda install scipy
```
```
conda install pyqt
```
```
pip install slycot   # required for control package
```
```
pip install control
```
```
pip install pyDOE
```
```
pip install cvxpy
```
```
pip install osqp
```
```
pip install sip
```
Install pybind11 2.6.0 - DO NOT install 2.8.0 as it will throw compilation errors when compiling SofaPython3
```
conda install -c conda-forge pybind11=2.6.0
```
There should now be a directory {PYTHON_ENV}/share/cmake/pybind11 (e.g. ${HOME}/anaconda3/envs/sofa/share/cmake/pybind11.
 
This stores the cmake files for pybind11, necessary to compile SofaPython3. 

Track pybind2.8 issue here: [pybindissue](https://github.com/sofa-framework/SofaPython3/pull/216)

Set your environment variables in `~/.bashrc`. 
```
cd ~
printf "\nexport PYTHONPATH=\"\$HOME/sofa-plugins/STLIB/python3/src:\$HOME/sofa/build/lib/python3/site-packages\"\nexport SP3_BLD=$HOME/sofa/build\nexport SOFA_BLD=\$HOME/sofa/build\nexport SOFA_ROOT=\$HOME/sofa/build\nexport GUROBI_HOME=\"/opt/gurobi952/linux64\"\nexport PATH=\"\${PATH}:\${GUROBI_HOME}/bin\"\nexport LD_LIBRARY_PATH=\"\${LD_LIBRARY_PATH}:\${GUROBI_HOME}/lib\"\nexport GRB_LICENSE_FILE=/opt/gurobi952/gurobi.lic\n\n " >> .bashrc
source ~/.bashrc
```

Execute `source ~/.bashrc` in terminal to make the appropriate changes.

Your environment variables in `~/.bashrc` should now look like below
```
export PYTHONPATH="$HOME/sofa-plugins/STLIB/python3/src:/home/nick/sofa/build/lib/python3/site-packages"
export SP3_BLD=$HOME/sofa/build
export SOFA_BLD=$HOME/sofa/build
export SOFA_ROOT=$HOME/sofa/build
export GUROBI_HOME="/opt/gurobi952/linux64"
export PATH="${PATH}:${GUROBI_HOME}/bin"
export LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:${GUROBI_HOME}/lib"
export GRB_LICENSE_FILE=/opt/gurobi952/gurobi.lic
```


---
##### Get Plugin Libraries

Download the libraries SoftRobots, STLIB, and SofaPython3
```
mkdir ~/sofa-plugins
git clone https://github.com/SofaDefrost/SoftRobots ~/sofa-plugins/SoftRobots
git clone https://github.com/SofaDefrost/STLIB.git ~/sofa-plugins/STLIB
git clone https://github.com/sofa-framework/SofaPython3.git ~/sofa-plugins/SofaPython3

cd ~/sofa-plugins/SoftRobots && git checkout v21.12
cd ~/sofa-plugins/STLIB && git checkout v21.12
cd ~/sofa-plugins/SofaPython3 && git checkout v21.12
```

Now create a CMakeLists.txt file in the `~/sofa-plugins/` directory and add the following:
```
cd ~/sofa-plugins/
touch CMakeLists.txt
printf "cmake_minimum_required(VERSION 3.11)\n\nfind_package(SofaFramework)\n\nsofa_add_plugin(STLIB/  STLIB VERSION 1.0)\nsofa_add_plugin(SoftRobots/  SoftRobots VERSION 1.0)\nsofa_add_plugin(SofaPython3/ SofaPython3 VERSION 1.0)" >> CMakeLists.txt
```

Now you should be able to build SOFA with the plugins enabled. See section Building SOFA for instructions.

Here you should be able to run cmake-gui and compile SOFA with no plugins. (Scroll down to "Building SOFA" if you want step by step directions). I recommend you do this to make sure nothing is broken up to this point.

<!-- Just run ```cmake-gui``` in the build directory, set the src and build, and click configure. Set CodeBlocks-Ninja, specify native compilers and point to the clang-12 thing. Should be able to configure and generate without modifying anything. There should not be errors, but there will likely be warnings; no problem. When you run ```make -j``` in the build directory, it should finish without throwing errors and you should be able to run the ```runSofa``` program in the bin folder. -->

# Building SOFA
## Setup your source and build directories 
Set up directories as follows: 
```
sofa/
├── build/
└── src/
    └── < SOFA sources here >
```
*(If necessary, delete any old sofa direcctory to rebuild from scratch)*
<!-- ##### Install Sofa

Follow [instructions](https://www.sofa-framework.org/community/doc/getting-started/build/linux/) to download dependencies (compiler, CMake, Qt, etc.)
-->


Run the following from the home directory to do this quickly (including cloning the git repository) **assuming v21.12**: 
``` 
sudo apt install git
mkdir $HOME/sofa
mkdir $HOME/sofa/src
mkdir $HOME/sofa/build
git clone https://github.com/sofa-framework/sofa.git ~/sofa/src
cd ~/sofa/src && git checkout v21.12
cd ~/sofabuild 
```
## Generate a Makefile with CMake
0. As an alternative to cmake-gui, you can generate the configuration files with commands like 
```
cmake -G "CodeBlocks - Ninja" -DCMAKE_C_COMPILER=/usr/bin/clang-12 -DCMAKE_CXX_COMPILER=/usr/bin/clang++-12 -DCMAKE_PREFIX_PATH=/home/nick/Qt/5.13.2/gcc_64 -DSOFA_BUILD_METIS=ON -S /home/nick/sofa/src -B /home/nick/sofa/build
```

1. Run CMake-GUI from the build folder
```
cmake-gui
```
and set source folder and build folder in the gui.

2. Run **Configure**. A popup will ask you to specify the generator for the project. 
* Choose "CodeBlocks – Ninja"

3. Choose “Specify native compilers” and press “Next”

4. Set the C compiler to ```/usr/bin/clang-12```\
Set the C++ compiler to ```/usr/bin/clang++-12```

5. The following list of configuration changes are necessary, according to Sander's docs:
  * Make sure the path to installation of Qt is correct by adding an entry `CMAKE_PREFIX_PATH` (name) (Type: PATH) and setting it to the appropriate location (e.g. `/home/nick/Qt/5.13.2/gcc_64` ).
  <!-- `/home/jlorenze/Qt/5.15.0/gcc_64`). -->

(The remaining options are for compiling plugins)
> Alternatively, you can just run something like `cmake -G "CodeBlocks - Ninja" -DCMAKE_C_COMPILER=/usr/bin/clang-12 -DCMAKE_CXX_COMPILER=/usr/bin/clang++-12 -DCMAKE_PREFIX_PATH=/home/nick/Qt/5.13.2/gcc_64 -DSOFA_BUILD_METIS=ON -DSOFA_EXTERNAL_DIRECTORIES=/home/nick/sofa-plugins -DSOFTROBOTS_IGNORE_ERRORS=ON -Dpybind11_DIR=/home/nick/.local/lib/python3.8/site-packages/pybind11/share/cmake/pybind11 -DPLUGIN_SOFTROBOTS=ON -DPLUGIN_SOFAPYTHON3=ON -DSTLIB=ON -S /home/nick/sofa/src -B /home/nick/sofa/$version` 

  * Find the entry `SOFA_EXTERNAL_DIRECTORIES` and set it to `$HOME/sofa-plugins` where `$HOME` is replaced with the actual path (e.g. `/home/nick/sofa-plugins`). 
  * Next, add a filepath entry `pybind11_DIR` to `/home/nick/anaconda3/envs/sofa/share/cmake/pybind11`.

  * Ensure the following bool entries are activated : `PLUGIN_SOFTROBOTS`, `PLUGIN_SOFAPYTHON3`, `PLUGIN_STLIB` (I had to add them).

6. Run **Configure** again. Note: red just means new stuff, so running configure again will just make the red go away (should complete with no error popups), and then run **Generate**.

7. Finally, build by opening a new terminal and running ```ninja``` in the build directory. This will take a while if compiling for the first time; subsequent times should only compile changes.

Test that Sofa launches by running `$SOFA_BLD/bin/runSofa`.

With plugins, try 
```
$SOFA_BLD/bin/runSofa -l $SP3_BLD/lib/libSofaPython3.so /home/nick/sofa-plugins/SoftRobots/docs/sofapython3/tutorials/DiamondRobot/DiamondRobot.py
```

# Getting started with SOFA
The following is the most comprehensive introduction to SOFA which I have found. This goes over ideology behind SOFA and how the core runs, and gives examples in both XML (actually slightly more intuitive to start with) and Python (more flexible/useful in the long run). 
([Download the files here](https://www.sofa-framework.org/download-materials))

[SOFA Introduction Tutorial](https://www.youtube.com/watch?v=KHTAgD1oG8Y&t=443s)

Note: these tutorial files are very helpful for basic functionality, i.e. for example how to make a standard python file which opens SOFA and runs a simulation.

---
## Install optimal control packages
---
These instructions are modified from the stanford ASL git (https://github.com/StanfordASL/soft-robot-control)

##### Clone the StanfordASL soft-robot-control git
In the home directory, git clone the repository from github: 
```
git clone https://github.com/StanfordASL/soft-robot-control soft-robot-control
```

##### Install Gurobi
Instructions are for v9.5.2

Install Gurobi [Official Instructions](https://cdn.gurobi.com/wp-content/plugins/hd_documentations/documentation/9.0/quickstart_linux.pdf) (Summarized instructions below)

Download Gurobi and setup an **academic** account [here](https://www.gurobi.com/downloads/gurobi-optimizer-eula/) <!-- Password saved in MSEdge -->

[direct-download-link](https://packages.gurobi.com/9.5/gurobi9.5.2_linux64.tar.gz)

Run the following to install Gurobi in the system `/opt` folder
```
sudo tar xvfz ~/Downloads/gurobi9.5.2_linux64.tar.gz -C /opt/
cd /opt/
sudo chmod +777 /opt/gurobi952
sudo chmod +777 /opt/gurobi952/linux64
```
Once gurobi is installed and you have you created an academic account, you need to obtain and install the license. You can obtain it [here](https://www.gurobi.com/downloads/end-user-license-agreement-academic/). When you run `grbgetkey`, refresh the page and it will be populated with the license info to enter into the terminal.
If necessary, install a [VPN](https://blink.ucsd.edu/technology/network/connections/off-campus/VPN/linux.html#1.-Download-the-UCSD-VPN-AnyCon) to connect to UCSD's network so the license works. 
Also, check that the .bashrc file is pointing to the correct file location, since we set the bashrc earlier. 

You then need to put the license in `/opt/gurobi952` during `grbgetkey`.
<!-- info  : License 765381 written to file /opt/gurobi952/gurobi.lic
info  : You may have saved the license key to a non-default location
info  : You need to set the environment variable GRB_LICENSE_FILE before you can use this license key
info  : GRB_LICENSE_FILE=/opt/gurobi950/gurobi.lic -->

Next, install Gurobi modules for Python (see full instructions [here](https://support.gurobi.com/hc/en-us/articles/360044290292-How-do-I-install-Gurobi-for-Python-), or just run the following command)
```
cd $GUROBI_HOME
sudo python setup.py install
```

##### Installation of ROS2

SofaPython3 requires Python 3.8, hence the instructions for ROS2 compatible with python3.8 (which is default for ubuntu 20.04) is provided. 

Download the Debian binaries for ROS2 Foxy Fitzroy on ubuntu. 
Follow the steps provided in the [full instructions here](https://docs.ros.org/en/foxy/Installation/Ubuntu-Install-Debians.html) to complete the setup of ROS2, or follow the summarized below. 

You will need to add the ROS 2 apt repositories to your system. To do so, first authorize our GPG key with apt like this:
```
sudo apt update
sudo apt install curl gnupg2 lsb-release
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key  -o /usr/share/keyrings/ros-archive-keyring.gpg
```
And then add the repository to your sources list:
```
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(source /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null
```

##### Install ROS 2 packages
Update your apt repository caches after setting up the repositories.
```
sudo apt update
```
Desktop Install (Recommended): ROS, RViz, demos, tutorials.
```
sudo apt install ros-foxy-desktop
```

Set up your environment by sourcing the following file.
```
source /opt/ros/foxy/setup.bash
```

<!-- ROS-Base Install (Bare Bones): Communication libraries, message packages, command line tools. No GUI tools.
```
sudo apt install ros-foxy-ros-base
``` -->


Follow steps below for further installation instructions.
ROS2 recommends the usage of colcon for building packages:

```
sudo apt install python3-colcon-common-extensions
pip install -U git+https://github.com/colcon/colcon-common-extensions.git
```

Lark parser is required for ROS2 

```
pip install lark_parser
```

*(If necessary, delete any old ros2 workspaces)*
Next setup the ROS2 workspace. Follow the instructions of step 1+2 of the [guided tutorial](https://index.ros.org/doc/ros2/Tutorials/Workspace/Creating-A-Workspace/). Summarized here: 
Run 
```
source /opt/ros/foxy/setup.bash
mkdir -p ~/dev_ws/src
cd ~/dev_ws/src
```


Next we will setup a package (using cmake) to have the service required for using SOFA with cvxpy, for Sequential Convex Programming trajectory optimization problems. Setup is based upon the [Custom ROS2 Interface Page](https://docs.ros.org/en/foxy/Tutorials/Beginner-Client-Libraries/Custom-ROS2-Interfaces.html):

```
# Navigate to src directory in root of workspace.
ros2 pkg create --build-type ament_cmake soft_robot_control_ros
cd soft_robot_control_ros
mkdir srv
cp ~/soft-robot-control/dependencies/ros/GuSTOsrv.srv srv/
```

(To open the necessary directory for the next two steps in VSCode, run `code .`)

Add the following to `CMakeLists.txt` in `${WS_DIR}/src/soft_robot_control_ros`:
* **Note: add this *BEFORE* the line containing** `ament_package()`


```
find_package(rosidl_default_generators REQUIRED)

rosidl_generate_interfaces(soft_robot_control_ros
  "srv/GuSTOsrv.srv"
 )
```

Add the following to `package.xml`
* **Note: add this *BEFORE* the line containing** `</package>`

```
<build_depend>rosidl_default_generators</build_depend>

<exec_depend>rosidl_default_runtime</exec_depend>

<member_of_group>rosidl_interface_packages</member_of_group>
```

Build the `soft_robot_control_ros` package from `~/dev_ws/`: run

```
cd ~/dev_ws
colcon build --packages-select soft_robot_control_ros
```
*7/21/2022 I got an error when I tried this at first. I tried to follow some of the docs and I think what fixed it was installing the following: ```sudo apt install python3-rosdep2```*  *and activating it with ```rosdep update```. If this didn't work, try following the official docs linked above, I did something from there.*

To source it, within your workspace `~/dev_ws/`, run:

```
. install/setup.bash  # Alternative: . install/setup.zsh
```

To validate that the service is created run the `ros2 interface show` command:

```
ros2 interface show soft_robot_control_ros/srv/GuSTOsrv
```

---
## Setup Environment variables (optional)

Add the following to your `.bashrc` file to auto source ROS 2 workspaces
```
source /opt/ros/foxy/setup.bash
source $HOME/dev_ws/install/setup.bash
conda activate sofa
```
or simply run
```
printf "\nsource /opt/ros/foxy/setup.bash\nsource \$HOME/dev_ws/install/setup.bash\nconda activate sofa\n\n" >> ~/.bashrc
```
---
## Running soft-robot-control and Sofa
*Unfortunately, Sander's code no longer runs on the newest version of SOFA. I tried reverting to the SOFA that existed when he wrote the code, but SofaPython3 was not officially supported at that time so the installation of SofaPython3 no longer works with those versions. STLIB also seems to have issues. John Alora is supposedly working on fixing Sander's code so that it runs again, I am not sure of that progress (7/26/2022). Since at this point SOFA and the plugins are correctly installed, I am quitting here for now. *

There are two methods to launching simulations using soft-robot-control with Sofa. Both require setting the problem file
in `problem_specification.py`.

0. Ensure that the `diamond_rompc` problem in `problem_specification.py` is uncommented `code ~/soft-robot-control/problem_specification.py`: 

1. Run with the simulation GUI. 
`$SOFA_BLD/bin/runSofa -l $SP3_BLD/lib/libSofaPython3.so -l $SP3_BLD/external_directories/sofa-plugins/SoftRobots/lib/libSoftRobots.so ~/soft-robot-control/launch_sofa.py`

`$SOFA_BLD/bin/runSofa -l $SP3_BLD/lib/libSofaPython3.so -l $SP3_BLD/external_directories/sofa-plugins/SoftRobots/lib/libSoftRobots.so -l $SP3_BLD/external_directories/sofa-plugins/STLIB/lib/libSTLIB.so ~/soft-robot-control/launch_sofa.py`







`$SOFA_BLD/bin/runSofa -l $SP3_BLD/lib/libSofaPython3.so ~/soft-robot-control/launch_sofa.py` then `python3 ~/soft-robot-control/examples/diamond/diamond_rompc.py run_rompc_solver` to run controller.

2. Run in the background. `python launch_sofa.py` (Requires modifying `sofa_lib_path` to match environment in `launch_sofa.py` file)

---



## References

[1] F. Faure, C. Duriez, H. Delingette, J. Allard, B. Gilles, S. Marchesseau,
H. Talbot, H. Courtecuisse, G. Bousquet, I. Peterlik, and S. Cotin,
“SOFA: A multi-model framework for interactive physical simulation,”
in Soft Tissue Biomechanical Modeling for Computer Assisted Surgery, 2012. 

[2] E. Coevoet, T. Morales-Bieze, F. Largilliere, Z. Zhang, M. Thieffry,
M. Sanz-Lopez, B. Carrez, D. Marchal, O. Goury, J. Dequidt, and
C. Duriez, “Software toolkit for modeling, simulation, and control of
soft robots,” Advanced Robotics, vol. 31, no. 22, pp. 1208–1224, 2017.

git checkout 5698b

export SP3_BLD=$HOME/sofa/build/external_directories/sofa-plugins/SofaPython3

$SOFA_BLD/bin/runSofa -l $SP3_BLD/lib/libSofaPython3.so /home/nick/sofa-plugins/SoftRobots/docs/sofapython3/tutorials/DiamondRobot/DiamondRobot.py 

https://github.com/sofa-framework/sofa/discussions/2912s
"""
