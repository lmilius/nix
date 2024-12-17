{ pkgs, ... }:
{
  # Intel GPU
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      # intel-compute-runtime
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
}