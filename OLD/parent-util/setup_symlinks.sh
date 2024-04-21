#!/bin/sh
cwd=$(pwd)
nixfiles="configuration.nix disko-config.nix"

for f in $nixfiles; do
#   sudo mv "/etc/nixos/$f" "/etc/nixos/orig_$f"
  sudo ln -bs "$cwd/$f" "/etc/nixos/$f"
done