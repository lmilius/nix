# Assuming your system is x86_64-linux
hostname=t480s

# sudo nix \
#     --extra-experimental-features 'flakes nix-command' \
#     run github:nix-community/disko#disko-install -- \
#     --flake "github:lmilius/nix?dir=flakes#$hostname" \
#     --write-efi-boot-entries \
#     --disk main /dev/sda

git clone "https://github.com/lmilius/nix.git" /tmp/nix
curl "https://raw.githubusercontent.com/lmilius/nix/main/flakes/hosts/$hostname/disko-config.nix" > /tmp/disko-config.nix && \
sudo nix --extra-experimental-features 'flakes nix-command' run github:nix-community/disko -- --mode disko /tmp/disko-config.nix && \

sudo nixos-install --root /mnt --flake "github:lmilius/nix?dir=flakes#$hostname" || \
sudo nixos-install --root /mnt --flake "/tmp/nix/flakes#$hostname"
