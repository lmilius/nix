HOSTNAME=$1
USER=$2

if [[ $USER == "" ]]
then
    USER=lmilius
fi

nixos-rebuild --target-host $USER@$HOSTNAME --use-remote-sudo  build --flake .#$HOSTNAME &&
NIX_SSHOPTS="-o RequestTTY=force" nixos-rebuild --target-host $USER@$HOSTNAME --use-remote-sudo  switch --flake .#$HOSTNAME