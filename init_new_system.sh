# Assuming your system is x86_64-linux
hostname=t480s

# sudo nix \
#     --extra-experimental-features 'flakes nix-command' \
#     run github:nix-community/disko#disko-install -- \
#     --flake "github:lmilius/nix?dir=flakes#$hostname" \
#     --write-efi-boot-entries \
#     --disk main /dev/sda

curl "https://raw.githubusercontent.com/lmilius/nix/main/flakes/hosts/$hostname/disko-config.nix" > disko-config.nix && \
sudo nix --extra-experimental-features 'flakes nix-command' run github:nix-community/disko -- --mode disko ./disko-config.nix && \

sudo nixos-install --root /mnt --flake "github:lmilius/nix?dir=flakes#$hostname"
