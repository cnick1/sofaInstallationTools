#!/bin/bash

cd ~/Downloads
if [ -f "/usr/local/bin/matlab" ]
then 
    echo "MATLAB was found"
else
    if compgen -G "/home/nick/Downloads/matlab*.zip" > /dev/null; then
        echo "MATLAB installer was found"
    else
        echo "Login to your mathworks account and download the latest matlab."
        xdg-open https://www.mathworks.com/downloads/
fi

fi

if compgen -G "/home/nick/Downloads/morlab*.mltbx" > /dev/null; then
    echo "MORLAB was found"
else
    wget https://csc.mpi-magdeburg.mpg.de/mpcsc/software/morlab/5.0/morlab-5.0.mltbx
fi


if compgen -G "/home/nick/Downloads/MMESS*.mltbx" > /dev/null; then
    echo "MESS was found"
else 
    wget https://csc.mpi-magdeburg.mpg.de/mpcsc/software/mess/mmess/2.2/MMESS-2.2.mltbx
fi

if [ -f "/usr/local/bin/matlab" ]
then 
    echo "MATLAB was found"
else
    matlabInstaller=$(compgen -G "/home/nick/Downloads/matlab*.zip")
    sudo unzip -X -K $matlabInstaller -d ${matlabInstaller%.*}
    cd ${matlabInstaller%.*}
    sudo ./install
fi

morlabFile=$(compgen -G "/home/nick/Downloads/morlab*.mltbx")
messFile=$(compgen -G "/home/nick/Downloads/MMESS*.mltbx")

matlab -r "matlab.addons.install('$morlabFile')"
matlab -r "matlab.addons.install('$messFile')"
