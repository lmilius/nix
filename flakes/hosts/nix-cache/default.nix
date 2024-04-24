# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ lib, config, pkgs, unstablePkgs, disko, hostname, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      /../common/common-packages.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.graceful = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = hostname; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.networkmanager.unmanaged = ["tailscale0"];
  systemd.services.NetworkManager-wait-online.enable = false;
  networking.networkmanager.dns = "systemd-resolved";
  # networking = {
  #   usePredictableInterfaceNames = false;
  #   interfaces.enp1s0.ipv4.addresses = [{
  #     address = "192.168.88.5";
  #     prefixLength = 24;
  #   }];
  #   defaultGateway = "192.168.88.1";
  #   nameservers = [ "192.168.88.1" "8.8.8.8" ];
  # };

  # Set your time zone.
  time.timeZone = "America/Chicago";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.forwarding" = 1;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lmilius = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "libvirtd" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF lmilius@x1carbon"
    ];
    initialHashedPassword = "$y$j9T$pIpVsIB6vvgo3wh6aRTbT.$lSwdItSLTZcEEg/KxCWR1FZZUDduWkYgrc4nZ/zusI2";
    #packages = with pkgs; [
    #  firefox
    #  tree
    #];
  };

  # Docker setup
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
    };
    enableOnBoot = true;
    #daemon.settings = {
    #  log-opts = {
    #    max-size = "10m";
    #  };
    #};
  };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      # codeserver = {
      #   image = "lscr.io/linuxserver/code-server:latest";
      #   environment = {
      #     PUID = "1000";
      #     PGID = "1000";
      #     DEFAULT_WORKSPACE = "/config/workspace";
      #   };
      #   volumes = [
      #     "/home/lmilius/code-server:/config"
      #   ];
      #   ports = [
      #     "443:8443"
      #   ];
      # };
      speedtest = {
        image = "linuxserver/librespeed:latest";
        environment = {
          MODE = "standalone";
        };
        ports = [
          "8080:80"
        ];
      };
  #     # Omada uses the following ports: 8088/8043 for the webUI, 
  #     omada = {
  #       image = "mbentley/omada-controller:latest";
  #       environment = {
  #         TZ = "America/Chicago";
  #       };
  #       extraOptions = [
  #         "--network=host"
  #       ];
  #       volumes = [
  #         "/home/lmilius/omada/data:/opt/tplink/EAPController/data"
  #         "/home/lmilius/omada/logs:/opt/tplink/EAPController/logs"
  #         "/home/lmilius/omada/work:/opt/tplink/EAPController/work"
  #       ];
  #     };
    };
  };

  # Virtualization support
  # virtualisation.libvirtd = {
  #   enable = true;
  # };

  # programs.virt-manager.enable = true;


  # Syncthing
  # services.syncthing = {
  #   enable = true;
  #   user = "lmilius";
  #   dataDir = "/home/lmilius/syncthing";
  #   configDir = "/home/lmilius/Documents/.config/syncthing";
  #   guiAddress = "0.0.0.0:8384";
  #   openDefaultPorts = true;
  #   settings = {
  #     devices = {
  #       Server = {
  #         addresses = [ 
  #           "tcp://sync.miliushome.com:22000"
  #           "tcp://10.10.200.80:22000"
  #         ];
  #         id = "QK47CRP-FPGZLTG-ZXSVEPB-K2W7VDQ-3TMGB6M-OCJGDYI-FHJFWG5-SDMG6QI";
  #       };
  #       x1carbon = {
  #         id = "WB74NAR-CQ6B6YL-SLXZGKT-AMWFL7O-5YA4XSF-756NFZP-ZSVGBRD-IQRZRQL";
  #       };
  #     };
  #     folders = {
  #       "/home/lmilius/syncthing/util-nix-config" = {
  #         id = "2tdx5-epjh7";
  #         devices = [
  #           "Server"
  #           "x1carbon"
  #         ];
  #       };
  #       "/home/lmilius/syncthing/nix-flake-config" = {
  #         id = "vccxz-vvrns";
  #         devices = [
  #           "Server"
  #           "x1carbon"
  #           # "parent-util"
  #         ];
  #       };
  #     };
  #   };
  # };

  # Enable VSCode Server
  # services.vscode-server.enable = true;

  # Enable tailscale service
  # services.tailscale.enable = true;
  # services.tailscale.useRoutingFeatures = "both";
  # services.tailscale.extraUpFlags = [
  #   "--accept-routes"
  #   "--accept-dns"
  #   # "--advertise-exit-node"
  #   # "--advertise-routes 10.10.200.0/24"
  #   "--ssh"
  #   # "--exit-node gateway"
  #   # "--exit-node-allow-lan-access"
  # ];
  # networking.firewall.checkReversePath = "loose";
  # networking.firewall.trustedInterfaces = [ "tailscale0" ];
  # nixpkgs.overlays = [(final: prev: {
  #   tailscale = unstablePkgs.tailscale;
  # })];

  # Allows vscode remote ssh server to work when this machine is the server
  # programs.nix-ld.enable = true;

  services.cockpit = {
    enable = true;
    port = 9090;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}

