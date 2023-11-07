# This module defines a small NixOS installation CD.  It does not
# contain any graphical stuff unless you add it.
# To build the iso: nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=iso.nix
{ config, pkgs, ... }:
{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  isoImage.contents = [ { source = ./parent-util; target = "/nixconfig"; } ];

  # Enable SSH in the boot process.
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF lmilius@x1carbon"
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  # services.xserver.displayManager.defaultSession = "plasmawayland";
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    elisa
    gwenview
    okular
    oxygen
    khelpcenter
    plasma-browser-integration
    print-manager
  ];

  # static networking config
  # networking = {
  #   usePredictableInterfaceNames = false;
  #   interfaces.enp1s0.ip4 = [{
  #     address = "192.168.88.5";
  #     prefixLength = 24;
  #   }];
  #   defaultGateway = "192.168.88.1";
  #   nameservers = [ "192.168.88.1" "8.8.8.8" ];
  # };

  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
}