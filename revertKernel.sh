#!/bin/bash

sudo add-apt-repository ppa:cappelikan/ppa
sudo apt update
sudo apt install mainline


printf "\n\nInstall the 5.4.213 kernel using the GUI \n\n\n" 


gtk-launch mainline.desktop 

printf "\n\nThe kernel will not work with Secure Boot unless you sign it manually following these instructions: \n\n\n" 
xdg-open https://github.com/maxried/ubuntu-sb-kernel-signing#automated-signing-of-kernels-installed-with-mainline
