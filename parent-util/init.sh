#!/bin/sh

nix run github:nix-community/disko -- --mode disko ./disko-config.nix

nixos-generate-config --no-filesystems --root /mnt

cp /iso/nixconfig/* /mnt/etc/nixos/

cd /mnt/etc/nixos

nixos-install