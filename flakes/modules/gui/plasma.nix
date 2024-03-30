{ config, pkgs, ... }:
let
  # unstableServices = services: import unstablePkgs { inherit services; };
  # unstableEnv = environment: import unstablePkgs { inherit environment; };
in
{
  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Configure keymap in X11
    layout = "us";
    xkbVariant = "";

    # Enable KDE Plasma 5
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
    displayManager.defaultSession = "plasmawayland";

    
  };

  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    elisa
  ];

  # # Enable KDE Plasma 6
  # unstableServices.xserver = {
  #   desktopManager.plasma6.enable = true;
  # };
  # unstableEnv.plasma6.excludePackages = with unstablePkgs.kdePackages; [
  #   elisa
  # ];

  # KDE apps
  programs.partition-manager.enable = true;
  programs.kdeconnect.enable = true;
}