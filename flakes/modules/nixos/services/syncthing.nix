{ lib, ... }:
{
  # Syncthing
  services.syncthing = {
    enable = lib.mkDefault true;
    guiAddress = "0.0.0.0:8384";
    user = lib.mkDefault "lmilius";
    dataDir = lib.mkDefault "/home/lmilius/syncthing";
    configDir = lib.mkDefault "/home/lmilius/Documents/.config/syncthing";
    overrideDevices = false;
    overrideFolders = false;
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
        nix-server = {
          id = "AABW4J4-BOIO4MV-HVW5SJC-OLOEDJB-UVC5T3J-6WG4IPX-Y2PC4GJ-P32QNAX";
        };
        parent-util = {
          id = "CLV4OPM-4UWTHWR-WVVLWFT-C7GT27L-DMLXMNC-J2QHYOQ-AKWM4PY-RI5OBQG";
        };
        util = {
          id = "BYSUXOW-75J5GCR-KGIHV3W-3W2Q26N-G3OIHWR-OIRZPH3-7V43IJQ-B7BLPAN";
        };
      };
    };
  };
}