#!/bin/sh

sudo ln -s $(realpath flake.nix) /etc/nixos
sudo ln -s $(realpath flake.lock) /etc/nixos
sudo ln -s $(realpath hosts) /etc/nixos
sudo ln -s $(realpath users) /etc/nixos