{ ... }:
{
  programs.nix-ld.enable = true;
  services.fstrim.enable = true;
  services.openssh.enable = true;

  virtualisation.libvirtd = {
    enable = true;
  };
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
}
