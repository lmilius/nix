{ config, pkgs, lib, modulesPath, unstablePkgs, hostname, ... }:

{
  imports = [
    (modulesPath + "/virtualisation/proxmox-image.nix")
    ../../modules/coral/default.nix

    # (import ../../modules/nextcloud/default.nix {
    #     config = config;
    #     lib = lib;
    #     pkgs = pkgs;
    #     cloudflare_creds_file = ../../secrets/cloudflare_dns_credentials.age;
    #     domain_file = ../../secrets/nextcloud_domain_name.age;
    #     postgres_file = ../../secrets/nextcloud_postgres_admin.age;
    #   })
    
  ];

  proxmox = {
    qemuConf = {
      virtio0 = "local_ssd:vm-109-disk-0";
      cores = 4;
      memory = 8192;
      name = hostname;
      diskSize = "auto";
      additionalSpace = "50G";
      bios = "ovmf";
    };
    # cloudInit = {
    #   defaultStorage = "local_ssd";
    # };
  };
  services.qemuGuest.enable = true;

  networking.hostName = hostname;

  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.networkmanager.unmanaged = ["tailscale0"];
  networking.networkmanager.dns = "systemd-resolved";
  services.resolved.enable = true;

  # systemd.services.NetworkManager-wait-online.enable = false;

  # environment.systemPackages = [
  #   pkgs.vim
  # ];

  boot.kernelPackages = pkgs.linuxPackages_6_10; # needed for gasket module

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.forwarding" = 1;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  users.users.lmilius = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker"]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF lmilius@x1carbon"
    ];
    initialHashedPassword = "$y$j9T$pIpVsIB6vvgo3wh6aRTbT.$lSwdItSLTZcEEg/KxCWR1FZZUDduWkYgrc4nZ/zusI2";
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

  # Allows vscode remote ssh server to work when this machine is the server
  programs.nix-ld.enable = true;

  # nix cli helper
  # https://github.com/viperML/nh
  programs.nh.flake = "/home/lmilius/syncthing/nix-flake-config";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # services.frigate = {
  #   enable = true;
  #   hostname = "prod-nix-1";
  #   package = unstablePkgs.frigate;
  #   settings = {
  #     cameras = {
  #       "cam1" = {
  #         ffmpeg.inputs = [ {
  #           path = "rtsp://10.10.200.90:8554/doorbell";
  #           roles = [
  #             "detect"
  #           ];
  #         } ];
  #       };
  #     };
  #     record = {
  #       enabled = false;
  #     };
  #     detectors = {
  #       "cpu" = {
  #         type = "cpu";
  #       };
  #     };
  #   };
  # };

  # Docker setup
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
    enableOnBoot = true;
    #daemon.settings = {
    #  log-opts = {
    #    max-size = "10m";
    #  };
    #};
  };

  # Enable tailscale service
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "server";
  services.tailscale.extraUpFlags = [
    "--accept-routes=false"
    "--accept-dns"
    "--ssh"
    # "--advertise-exit-node"
    # "--advertise-routes 10.10.200.0/24"
    # "--exit-node gateway"
    # "--exit-node-allow-lan-access"
  ];
  # networking.firewall.checkReversePath = "loose";
  networking.firewall.enable = false;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  nixpkgs.overlays = [(final: prev: {
    tailscale = unstablePkgs.tailscale;
  })];
  networking.useDHCP = false;
  networking.interfaces.ens18.useDHCP = true;

  system.stateVersion = "24.05";
}
