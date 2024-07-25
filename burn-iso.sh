
sudo dd bs=4M conv=fsync oflag=direct status=progress if=$(find ./result/iso/nixos-*.iso) of=$1