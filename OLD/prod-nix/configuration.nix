{ pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/proxmox-lxc.nix")
  ];

  environment.systemPackages = [
    pkgs.vim
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  users.users.lmilius = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF lmilius@x1carbon"
    ];
  };

  # Syncthing
  services.syncthing = {
    enable = true;
    user = "lmilius";
    dataDir = "/home/lmilius/syncthing";
    configDir = "/home/lmilius/Documents/.config/syncthing";
    guiAddress = "0.0.0.0:8384";
    openDefaultPorts = true;
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
        "/home/lmilius/syncthing/nix-flake-config" = {
          id = "vccxz-vvrns";
          devices = [
            "Server"
            "x1carbon"
            "t480s"
            # "parent-util"
          ];
        };
      };
    };
  };

  # Enable tailscale service
  # services.tailscale.enable = true;
  # services.tailscale.useRoutingFeatures = "both";
  # services.tailscale.extraUpFlags = [
  #   "--accept-routes"
  #   "--accept-dns"
  #   "--ssh"
  #   # "--advertise-exit-node"
  #   # "--advertise-routes 10.10.200.0/24"
  #   # "--exit-node gateway"
  #   # "--exit-node-allow-lan-access"
  # ];

  system.stateVersion = "24.05";
}
