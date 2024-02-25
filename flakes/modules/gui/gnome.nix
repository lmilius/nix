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

    Enable the Gnome Desktop Environment.
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
  };
}