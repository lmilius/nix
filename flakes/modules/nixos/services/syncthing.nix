{ lib, ... }:
{
  # Syncthing
  services.syncthing = {
    enable = lib.mkDefault true;
    user = lib.mkDefault "lmilius";
    dataDir = lib.mkDefault "/home/lmilius/syncthing";
    configDir = lib.mkDefault "/home/lmilius/Documents/.config/syncthing";
    settings = {
      devices = {
        Server = {
          addresses = [
            "tcp://sync.miliushome.com:22000"
            "tcp://10.10.200.80:22000"
          ];
          id = "QK47CRP-FPGZLTG-ZXSVEPB-K2W7VDQ-3TMGB6M-OCJGDYI-FHJFWG5-SDMG6QI";
        };
        x1carbon = {
          id = "WB74NAR-CQ6B6YL-SLXZGKT-AMWFL7O-5YA4XSF-756NFZP-ZSVGBRD-IQRZRQL";
        };
        t480s = {
          id = "ZJA3J2Y-B43GBN6-US2DC6M-JJ56R6H-NOOOKOJ-2KD2HCP-WRJTWU2-6NZYBQX";
        };
      };
      folders = {
        "Nix Flake Config" = {
          id = "vccxz-vvrns";
          path = "/home/lmilius/syncthing/nix-flake-config";
          devices = [
            "Server"
            "x1carbon"
            "t480s"
          ];
        };
      };
    };
  };
}