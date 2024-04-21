# Assuming your system is x86_64-linux
hostname=nix-cache

sudo nix \
    --extra-experimental-features 'flakes nix-command' \
    run github:nix-community/disko#disko-install -- \
    --flake "github:lmilius/nix?dir=flakes#$hostname" \
    --write-efi-boot-entries \
    --disk main /dev/sda