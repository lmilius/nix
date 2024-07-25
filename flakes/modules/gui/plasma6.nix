{ config, pkgs, ... }:
let

in
{
  services = {
    xserver = {
      # Enable the X11 windowing system.
      enable = true;

      # Configure keymap in X11
      xkb = {
        variant = "";
        layout = "us";
      };
    };

    # Enable KDE Plasma 6
    desktopManager.plasma6 = {
      enable = true;
      enableQt5Integration = false;
    };
    
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
}