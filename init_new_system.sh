# Assuming your system is x86_64-linux
hostname=t480s
DISK=$1
read -n 1 -srp $"Disk supplied: $DISK. Is this correct? (Y/n) " key
echo
if [ "$key" == 'n' ]; then exit;
# sudo nix \
#     --extra-experimental-features 'flakes nix-command' \
#     run github:nix-community/disko#disko-install -- \
#     --flake "github:lmilius/nix?dir=flakes#$hostname" \
#     --write-efi-boot-entries \
#     --disk main /dev/sda
DCONFIG="/tmp/disko-config.nix"
git clone "https://github.com/lmilius/nix.git" /tmp/nix
curl "https://raw.githubusercontent.com/lmilius/nix/main/flakes/hosts/$hostname/disko-config.nix" > $DCONFIG && \
sudo nix --extra-experimental-features 'flakes nix-command' run github:nix-community/disko -- --mode zap_create_mount $DCONFIG --arg disks '[ ""\"""$DISK""\""" ]' && \

echo "Making empty snapshot of root"
MOUNT="/mnt2"
mkdir $MOUNT
mount -o subvol=@ "$DISK"3 "$MOUNT"
# Make tmp and srv directories so subvolumes are not autocreated
# by systemd, stopping deletion of root subvolume
mkdir -p "$MOUNT/root/srv"
mkdir -p "$MOUNT/root/tmp"
# Having a /mnt folder can be useful too
mkdir -p "$MOUNT/root/mnt"
btrfs subvolume snapshot -r $MOUNT/root $MOUNT/root-blank
btrfs subvolume list $MOUNT
umount "$MOUNT"



sudo nixos-install --root /mnt --flake "github:lmilius/nix?dir=flakes#$hostname" || \
sudo nixos-install --root /mnt --flake "/tmp/nix/flakes#$hostname"
