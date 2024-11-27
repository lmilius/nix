{ lib, ... }:
{

  users.users."syncthing".extraGroups = [ "syncthing" "deployer" ];

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
        nas = {
          addresses = [
            "tcp://sync.miliushome.com:22000"
            "tcp://10.10.200.90:22000"
          ];
          id = "XCFL7W4-CTECDYD-BY52DVC-O7KIAHO-7MISPLT-5CWVBSR-OKNXHXO-WRRSQQ2";
        };
        x1carbon = {
          id = "WB74NAR-CQ6B6YL-SLXZGKT-AMWFL7O-5YA4XSF-756NFZP-ZSVGBRD-IQRZRQL";
        };
        t480s = {
          id = "ZJA3J2Y-B43GBN6-US2DC6M-JJ56R6H-NOOOKOJ-2KD2HCP-WRJTWU2-6NZYBQX";
        };
      };
    };
  };
}