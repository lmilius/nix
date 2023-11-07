{ lib, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./mastodon.nix
    ];
  
  users.users.root.initialPassword = "root";

  networking.hostName = "x1carbon";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";

  # Enable tailscale service
  services.tailscale.enable = true;
  networking.firewall.checkReversePath = "loose";

  networking.firewall.enable = false;

  environment.systemPackages = with pkgs; [
    busybox
    htop
    iotop
    powertop
    tmux
    vim
    intel-gpu-tools
    tailscale
    docker
  ];

  # virtualisation.docker = {
  #   enable = true;
  #   autoPrune = {
  #     enable = true;
  #   };
  #   enableOnBoot = true;
  # };

  # # Nix automated garbage collection
  # nix.gc = {
  #   automatic = true;
  #   dates = "weekly";
  #   options = "--delete-older-than 30d";
  # };
  # nix.extraOptions = ''
  #   min-free = ${toString (100 * 1024 * 1024)}
  #   max-free = ${toString (1024 * 1024 * 1024)}
  # '';

  services.openssh.enable = true;

  system.stateVersion = "22.05";
}
