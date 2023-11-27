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

  isoImage.contents = [ { source = ./util; target = "/nixconfig"; } ];

  # Enable SSH in the boot process.
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  # users.users.root.openssh.authorizedKeys.keys = [
  #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF lmilius@x1carbon"
  # ];
  users.users.root.openssh.authorizedKeys.keyFiles = [
    ~/.ssh/id_ed25519.pub
  ];

  # Enable the X11 windowing system.
  # services.xserver = {
  #   enable = true;
  #   layout = "us";
  #   videoDrivers = [ "amdgpu" ];

  #   # Enable XFCE4
  #   displayManager.lightdm.enable = true;
  #   desktopManager.xfce.enable = true;

  #   # Enable KDE Plasma 5
  #   # displayManager.sddm.enable = true;
  #   # desktopManager.plasma5.enable = true;
  # };


  # services.xserver.displayManager.defaultSession = "plasmawayland";
  # environment.plasma5.excludePackages = with pkgs.libsForQt5; [
  #   elisa
  #   gwenview
  #   okular
  #   oxygen
  #   khelpcenter
  #   plasma-browser-integration
  #   print-manager
  # ];

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

  # Enable flakes (experimental)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    htop
    git
    tmux
    dig
    traceroute
  ];

  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
}