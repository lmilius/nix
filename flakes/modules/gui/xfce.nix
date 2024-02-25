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

    Enable XFCE4
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
  };
}