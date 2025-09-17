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

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
  ];

  environment.systemPackages = with pkgs.kdePackages; [
    kio-admin
    kio-extras
    kio-fuse
    kdenetwork-filesharing
    ffmpegthumbs
    kdegraphics-thumbnailers
    kimageformats
    plasma-nm
  ];

  # KDE apps
  programs.partition-manager.enable = true;
  programs.kdeconnect.enable = true;
}