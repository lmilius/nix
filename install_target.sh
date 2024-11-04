HOSTNAME=$1
USER=$2

if [[ $USER == "" ]]
then
    USER=lmilius
fi

NIX_SSHOPTS="-o RequestTTY=force" nixos-rebuild --target-host $USER@$HOSTNAME --use-remote-sudo  build --flake .#$HOSTNAME