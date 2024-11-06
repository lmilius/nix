{ config, pkgs, unstablePkgs, ... }:

let 
  libedgetpu = config.boot.kernelPackages.callPackage ./libedgetpu.nix {}; 
  # gasket = config.boot.kernelPackages.callPackage /etc/nixos/packages/gasket.nix {};
in
{
  services.udev.packages = [ libedgetpu ];                                                                                                                                                                                              
  users.groups.plugdev = {};  
  boot.extraModulePackages = [ unstablePkgs.linuxKernel.packages.linux_6_10.gasket ];
}