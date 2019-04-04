#!/bin/bash

# Upgrade git version

git --version
if test -z "$(ls /etc/apt/sources.list.d/git*)" > /dev/null
then
  sudo apt-add-repository ppa:git-core/ppa -y 
fi
sudo apt-get update -q && sudo apt-get install git -qy
