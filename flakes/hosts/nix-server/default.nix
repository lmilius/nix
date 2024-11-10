
{ inputs, outputs, lib, config, pkgs, hostname, ... }:
let
  appdata_path = "/tank/appdata";
  local_domain = "nix.miliushome.com";
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
      outputs.nixosModules.cockpit
      outputs.nixosModules.docker_daemon
      outputs.nixosModules.intel_gpu
      outputs.nixosModules.syncthing
      outputs.nixosModules.systemd_oom

      # (outputs.nixosModules.nextcloud {
      #   trusted_domains = ["10.10.200.91"];
      # })

      inputs.agenix.nixosModules.default

    ];
  

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "zfs" ];
    zfs = {
      forceImportRoot = false;
      extraPools = [ "tank" ];
    };
  };
  
  networking.hostId = "d131645e";
  services.zfs.autoScrub.enable = true;

  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # services.nextcloud = {
  #   enable = true;
  #   hostName = "localhost";
  #   database.createLocally = true;
  #   config = {
  #     dbtype = "pgsql";
  #     adminpassFile = "/etc/nextcloud-admin-pass";
  #   };
  #   settings = {
  #     trusted_domains = [
  #       "10.10.200.91"
  #     ];
  #   };
  # };
  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.lmilius = { 
      imports = [
        ../../users/lmilius/home.nix 
      ]; 
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lmilius = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "libvirtd" ]; # Enable ‘sudo’ for the user.
    #packages = with pkgs; [
    #  tree
    #];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    intel-gpu-tools
    distrobox
    virt-manager
    qemu
    inputs.compose2nix.packages.x86_64-linux.default
  ];

  # # Syncthing
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
  #       t480s = {
  #         id = "ZJA3J2Y-B43GBN6-US2DC6M-JJ56R6H-NOOOKOJ-2KD2HCP-WRJTWU2-6NZYBQX";
  #       };
  #     };
  #     folders = {
  #       "/home/lmilius/syncthing/nix-flake-config" = {
  #         id = "vccxz-vvrns";
  #         devices = [
  #           "Server"
  #           "x1carbon"
  #           "t480s"
  #         ];
  #       };
  #     };
  #   };
  # };

  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = ${hostname}
      netbios name = ${hostname}
      security = user
      guest ok = no
      guest account = nobody
      map to guest = bad user
      load printers = no
    '';
    shares = let
      mkShare = path: {
        path = path;
        browseable = "no";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "lmilius";
        "force group" = "users";
      };
    in {
      archives = mkShare "/tank/archives";
      backups = mkShare "/tank/backups";
    };
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # nix cli helper
  # https://github.com/viperML/nh
  programs.nh.flake = "/home/lmilius/syncthing/nix-flake-config";

  # List services that you want to enable:

  programs.nix-ld.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Virtualization support
  virtualisation.libvirtd = {
    enable = true;
  };
  programs.virt-manager.enable = true;

  age = {
    # identityPaths = [ "/etc/ssh/ssh_host_ed25519_key.pub" ];
    secrets = {
      traefik_env = {
        file = ../../secrets/nix-server/traefik_env.age;
      };
      traefik_conf = {
        file = ../../secrets/nix-server/traefik_conf.age;
        path = "${appdata_path}/traefik/traefik.yaml";
      };
      traefik_rules = {
        file = ../../secrets/nix-server/traefik_rules.age;
        path = "${appdata_path}/traefik/rules.yaml";
      };
    };
  };

  virtualisation.docker.daemon.settings.data-root = "/tank/docker-data";
  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      traefik = {
        image = "traefik:v2.10.7";
        ports = [
          "0.0.0.0:80:80"
          "0.0.0.0:443:443"
        ];
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.traefik.entrypoints" = "websecure";
          "traefik.http.routers.traefik.rule" = "Host(`proxy.${local_domain}`)";
          "traefik.http.routers.traefik.tls" = "true";
          "traefik.http.routers.traefik.service" = "api@internal";
          "traefik.http.services.traefik.loadbalancer.server.port" = "8080";
        };
        volumes = [
          "${appdata_path}/traefik:/etc/traefik"
          "/var/run/docker.sock:/var/run/docker.sock:ro"
        ];
        environmentFiles = [ config.age.secrets.traefik_env.path ];
      };
      speedtest = {
        image = "linuxserver/librespeed:latest";
        environment = {
          MODE = "standalone";
        };
        labels = {
          "traefik.enable" = "true";
          "traefik.http.routers.traefik.rule" = "Host(`speedtest.${local_domain}`)";
        };
        # ports = [
        #   "8080:80"
        # ];
      };
    };
  };

  

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 80 443 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?

}

