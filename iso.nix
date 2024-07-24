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

  isoImage.contents = [ { source = ./flakes/hosts/t480s; target = "/nixconfig"; } ];

  # Enable SSH in the boot process.
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  users.users.root.openssh.authorizedKeys.keyFiles = [
    ~/.ssh/id_ed25519.pub
  ];

  # Enable networking
  networking.networkmanager.enable = true;
  networking.wireless.enable = true;

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

  # Enable KDE Plasma 6
  services = {
    desktopManager.plasma6.enable = true;
    xserver = {
      # Enable the X11 windowing system.
      enable = true;

      # Configure keymap in X11
      xkb = {
        variant = "";
        layout = "us";
      };
    };

    # Enable KDE Plasma 5
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
      defaultSession = "plasma";
    };
    
  };

  environment.plasma6.excludePackages = with pkgs.libsForQt5; [
    elisa
  ];

  # KDE apps
  programs.partition-manager.enable = true;
  programs.kdeconnect.enable = true;

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