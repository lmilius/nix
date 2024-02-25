{ config, pkgs, ... }:
let

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
}