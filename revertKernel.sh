#!/bin/bash

sudo add-apt-repository ppa:cappelikan/ppa
sudo apt update
sudo apt install mainline

gtk-launch mainline.desktop 