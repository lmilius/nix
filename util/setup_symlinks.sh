#!/bin/sh
cwd=$(pwd)
nixfiles="configuration.nix disko-config.nix vscode-server.nix"

for f in $nixfiles; do
#   sudo mv "/etc/nixos/$f" "/etc/nixos/orig_$f"
  sudo ln -s "$cwd/$f" "/etc/nixos/$f"
done