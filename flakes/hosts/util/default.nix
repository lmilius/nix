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
      outputs.nixosModules.cockpit
      outputs.nixosModules.docker_daemon
      outputs.nixosModules.lmilius_user
      outputs.nixosModules.deployer_user
      # Remote build client - use NVR as build server
      outputs.nixosModules.remote_build_client

      inputs.agenix.nixosModules.default
    ];

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        graceful = true;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_6_12;

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.forwarding" = 1;
  };

  networking.networkmanager.enable = true;
  networking.networkmanager.unmanaged = ["tailscale0"];
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

  users.users.lmilius = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF lmilius@x1carbon"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGxP4uuwDHt55l/TjdJNnS+legL8oUgk/3FFtev/NBvsAAAABHNzaDo= Yubikey Personal SSH Key"
    ];
    initialHashedPassword = "$y$j9T$pIpVsIB6vvgo3wh6aRTbT.$lSwdItSLTZcEEg/KxCWR1FZZUDduWkYgrc4nZ/zusI2";
  };

  users.users.deployer.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJr6u53xcfqXT8h42hTG2S7QEDOavh4AQmqfRVAgOvK6 lmilius@util"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF lmilius@x1carbon"
  ];

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      codeserver = {
        image = "lscr.io/linuxserver/code-server:latest";
        environment = {
          PUID = "1000";
          PGID = "1000";
          DEFAULT_WORKSPACE = "/config/workspace";
        };
        volumes = [
          "/home/lmilius/code-server:/config"
        ];
        ports = [
          "443:8443"
        ];
      };
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

  virtualisation.libvirtd = {
    enable = true;
  };

  programs.virt-manager.enable = true;
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    openFirewall = true;
    package = pkgs.unstable.tailscale;
    extraUpFlags = [
      "--accept-routes=true"
      "--accept-dns"
      "--advertise-exit-node"
      "--advertise-routes 10.10.200.0/23"
      "--ssh"
    ];
  };

  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.localCommands = ''
    ip rule add to 10.10.200.0/24 priority 2500 lookup main
  '';

  services.nebula.networks.mesh = {
    enable = true;
    isLighthouse = false;
    cert = "/etc/nebula/util.crt";
    key = "/etc/nebula/util.key";
    ca = "/etc/nebula/ca.crt";
    lighthouses = [
      "10.100.100.1"
    ];
    staticHostMap = {
      "10.100.100.1" = [
        "gateway.miliusfam.com:4242"
      ];
    };
    firewall = {
      outbound = [
        {
          host = "any";
          port = "any";
          proto = "any";
        }
      ];
      inbound = [
        {
          host = "any";
          port = "any";
          proto = "icmp";
        }
        {
          host = "any";
          port = "8080";
          proto = "any";
        }
      ];
    };
    settings = {
      cipher = "aes";
      local_allow_list = {
        "10.0.0.0/8" = false;
        "172.16.0.0/12" = false;
        "192.168.0.0/16" = false;
        interfaces = {
          "docker.*" = false;
          "tailscale.*" = false;
        };
        "10.10.200.0/24" = true;
      };
    };
  };

  programs.nix-ld.enable = true;
  services.openssh.enable = true;
  networking.firewall.enable = false;

  # Use NVR as remote build host
  lmilius-remote-build-client = {
    enable = true;
    builderHost = "10.10.200.93";
    sshUser = "nixbuilder";
    maxJobs = 12;
    speedFactor = 2;
  };

  system.stateVersion = "23.05";
}
