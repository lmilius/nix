{ lib, ... }:
{

  users.users."syncthing".extraGroups = [ "deployer" ];

  # Syncthing
  services.syncthing = {
    enable = lib.mkDefault true;
    # user = lib.mkDefault "deployer";
    # group = lib.mkDefault "deployer";
    dataDir = lib.mkDefault "/tank2/appdata/syncthing";
    guiAddress = "0.0.0.0:8384";
    settings = {
      options = {
        localAnnounceEnabled = true;
      };
      devices = {
        Server = {
          addresses = [
            "tcp://sync.miliushome.com:22000"
            "tcp://10.10.200.90:22000"
          ];
          id = "QK47CRP-FPGZLTG-ZXSVEPB-K2W7VDQ-3TMGB6M-OCJGDYI-FHJFWG5-SDMG6QI";
        };
        x1carbon = {
          id = "WB74NAR-CQ6B6YL-SLXZGKT-AMWFL7O-5YA4XSF-756NFZP-ZSVGBRD-IQRZRQL";
        };
        t480s = {
          id = "ZJA3J2Y-B43GBN6-US2DC6M-JJ56R6H-NOOOKOJ-2KD2HCP-WRJTWU2-6NZYBQX";
        };
        nas = {
          id = "JD67CKI-PB4NHPU-E7AEKFH-PQXTZ52-WOWKDFX-ED2XRZN-CS6ZKDS-JSDPCAJ";
        };
      };
      folders = {
        "Nix Flake Config" = {
          id = "vccxz-vvrns";
          path = "/home/lmilius/syncthing/nix-flake-config";
          devices = [
            "x1carbon"
            "t480s"
            "nas"
            "Server"
          ];
        };
      };
    };
  };
}