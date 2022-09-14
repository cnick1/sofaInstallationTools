#!/bin/bash

cd ~/Downloads
if [ ! command -v matlab &> /dev/null ]
then
    echo "Login to your mathworks account and download the latest matlab."
    xdg-open https://www.mathworks.com/downloads/
fi
wget https://csc.mpi-magdeburg.mpg.de/mpcsc/software/morlab/5.0/morlab-5.0.mltbx
wget https://csc.mpi-magdeburg.mpg.de/mpcsc/software/mess/mmess/2.2/MMESS-2.2.mltbx
