{ inputs, outputs, config, pkgs, hostname, ... }:
{
  imports =
    [
      inputs.disko.nixosModules.disko
      (import ./disko-config.nix {
        disks = [ "/dev/sda" ];
      })
      ./hardware-configuration.nix

      inputs.home-manager.nixosModules.home-manager
      outputs.nixosModules.docker_daemon
      outputs.nixosModules.systemd_oom
      outputs.nixosModules.lmilius_user
      outputs.nixosModules.deployer_user
      # Remote build client - use NVR as build server
      outputs.nixosModules.remote_build_client

      inputs.agenix.nixosModules.default
    ];

  nix.settings.substituters = [ ];

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        graceful = true;
      };
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_6_12;
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv4.conf.all.forwarding" = 1;
    };
  };

  networking = {
    networkmanager.enable = true;
    networkmanager.unmanaged = ["tailscale0"];
    firewall = {
      enable = false;
      trustedInterfaces = [ "tailscale0" ];
    };
    bridges = {
      br0 = {
        interfaces = [ "enp1s0" ];
      };
    };
    interfaces = {
      br0 = {
        useDHCP = false;
        ipv4.addresses = [{
          address = "192.168.88.5";
          prefixLength = 24;
        }];
        wakeOnLan.enable = true;
      };
    };
    defaultGateway = "192.168.88.1";
    nameservers = [ "192.168.88.1" ];
    localCommands = ''
      ip rule add to 192.168.88.0/24 priority 2500 lookup main
    '';
  };

  systemd.services.NetworkManager-wait-online.enable = false;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.lmilius = {
      imports = [
        ../../users/lmilius/home.nix
      ];
    };
  };

  users.users.lmilius.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF lmilius@x1carbon"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGxP4uuwDHt55l/TjdJNnS+legL8oUgk/3FFtev/NBvsAAAABHNzaDo= Yubikey Personal SSH Key"
  ];
  users.users.lmilius.initialHashedPassword = "$y$j9T$pIpVsIB6vvgo3wh6aRTbT.$lSwdItSLTZcEEg/KxCWR1FZZUDduWkYgrc4nZ/zusI2";

  users.users.deployer.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJr6u53xcfqXT8h42hTG2S7QEDOavh4AQmqfRVAgOvK6 lmilius@util"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF lmilius@x1carbon"
  ];

  environment.systemPackages = [
    pkgs.android-tools
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      speedtest = {
        image = "linuxserver/librespeed:latest";
        environment = {
          MODE = "standalone";
        };
        ports = [
          "8080:80"
        ];
      };
      # Omada uses the following ports: 8088/8043 for the webUI, 
      omada = {
        image = "mbentley/omada-controller:5.15.24.18";
        environment = {
          TZ = "America/Chicago";
        };
        extraOptions = [
          "--network=host"
        ];
        volumes = [
          "/home/lmilius/omada/data:/opt/tplink/EAPController/data"
          "/home/lmilius/omada/logs:/opt/tplink/EAPController/logs"
          "/home/lmilius/omada/work:/opt/tplink/EAPController/work"
        ];
      };
    };
  };

  virtualisation = {
    libvirtd = {
      enable = true;
    };
    spiceUSBRedirection.enable = true;
  };
  programs.virt-manager.enable = true;
  
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    openFirewall = true;
    package = pkgs.unstable.tailscale;
    extraUpFlags = [
      "--accept-routes"
      "--accept-dns"
      "--advertise-exit-node"
      "--advertise-routes 192.168.88.0/23"
      "--ssh"
    ];
  };

  programs.nix-ld.enable = true;
  services.openssh.enable = true;

  # Use NVR as remote build host
  lmilius-remote-build-client = {
    enable = true;
    builderHost = "10.10.200.93";
    sshUser = "nixbuilder";
    maxJobs = 8;
    speedFactor = 2;
  };

  system.stateVersion = "23.05";
}
