
{ inputs, outputs, lib, config, pkgs, hostname, ... }:
let
  zfs_tank = "tank";
  appdata_path = "/${zfs_tank}/appdata";
  bitcoin_data_dir = "/${zfs_tank}/bitcoin";
  local_domain = "nix.miliushome.com";
  # vHostLocal = {domain, port, }: {
  #   enableACME = false;
  #   useACMEHost = domain;
  #   locations."/" = {
  #     proxyPass = "http://127.0.0.1:${port}";
  #     # proxyWebsockets = false;
  #   };
  # };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
      outputs.nixosModules.cockpit
      outputs.nixosModules.docker_daemon
      outputs.nixosModules.intel_gpu
      # inputs.nix-bitcoin.nixosModules.default
      # (inputs.nix-bitcoin + "/modules/presets/secure-node.nix")
      # (outputs.nixosModules.mealie {
      #   local_domain = local_domain;
      #   appdata_path = appdata_path;
      # })
      # (outputs.nixosModules.paperless {
      #   inherit config pkgs;
      #   admin_pass_file = config.age.secrets.paperless_admin_pass.path;
      #   appdata_path = appdata_path;
      #   domain = local_domain;
      # })
      outputs.nixosModules.syncthing
      # outputs.nixosModules.systemd_oom

      # (outputs.nixosModules.nextcloud {
      #   hostname = "nextcloud.${local_domain}";
      #   pkgs = pkgs;
      # })

      # inputs.agenix.nixosModules.default

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
      extraPools = [ "${zfs_tank}" ];
    };
    kernelPackages = pkgs.linuxPackages_6_12;
  };
  
  networking.hostId = "d131645e";
  services.zfs.autoScrub.enable = true;

  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  #networking.bridges = {
  #  br0 = {
  #    interfaces = [
  #      "eno1"
  #    ];
  #  };
  #};

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
    extraGroups = [ "wheel" "docker" "libvirtd" "deployer" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [ 
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF lmilius@x1carbon"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGxP4uuwDHt55l/TjdJNnS+legL8oUgk/3FFtev/NBvsAAAABHNzaDo= Yubikey Personal SSH Key"
    ];
    #packages = with pkgs; [
    #  tree
    #];
  };

  users.groups.deployer = {
    gid = 1100;
  };
  users.users.deployer = {
    isNormalUser = true;
    extraGroups = [ "deployer" "wheel" "docker" "libvirtd" ];
    createHome = true;
    uid = 1100;
    group = "deployer";
    openssh.authorizedKeys.keys = [ 
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJr6u53xcfqXT8h42hTG2S7QEDOavh4AQmqfRVAgOvK6 lmilius@util"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF lmilius@x1carbon"
    ];
  };
  security.sudo.extraRules = [{
    commands = [
      {
        command = "ALL";
        options = [ "NOPASSWD" ];
      }
    ];
    users = [ "deployer" ];
  }];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    intel-gpu-tools
    distrobox
    virt-manager
    qemu
    quickemu
    # inputs.compose2nix.packages.x86_64-linux.default
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

  # Nix-Bitcoin configuration
  # https://github.com/fort-nix/nix-bitcoin/blob/master/examples/flakes/flake.nix
  # nix-bitcoin = {
  #   generateSecrets = true;
  #   operator = {
  #     enable = true;
  #     name = "lmilius";
  #   };
  # };
  # services.bitcoind = {
  #   enable = true;
  #   dataDir = "${bitcoin_data_dir}/bitcoind";
  # };
  # services.clightning = {
  #   enable = true;
  #   dataDir = "${bitcoin_data_dir}/clightning";
  # };

  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      workgroup = WORKGROUP
      server string = ${hostname}
      netbios name = ${hostname}

      server role = standalone server
      dns proxy = no

      pam password change = yes
      map to guest = bad user
      usershare allow guests = yes
      create mask = 0664
      force create mode = 0664
      directory mask = 0775
      force directory mode = 0775
      follow symlinks = yes
      load printers = no
      printing = bsd
      printcap name = /dev/null
      disable spoolss = yes
      strict locking = no
      aio read size = 0
      aio write size = 0
      vfs objects = acl_xattr catia fruit streams_xattr
      inherit permissions = yes

      # Security
      client ipc max protocol = SMB3
      client ipc min protocol = SMB2_10
      client max protocol = SMB3
      client min protocol = SMB2_10
      server max protocol = SMB3
      server min protocol = SMB2_10
    '';
    shares = let
      mkShare = path: {
        path = path;
        browseable = "yes";
        "read only" = "no";
        "inherit acls" = "yes";
        # Authenticate Users (space delimited)
        "valid users" = "lmilius";

        "veto files" = "/.apdisk/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/";
        "delete veto files" = "yes";


        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "lmilius";
        "force group" = "users";
      };
      mkPublicShare = path: {
        path = path;
        browseable = "yes";
        "read only" = "no";
        "inherit acls" = "yes";

        # This is public, everybody can access.
        "guest ok" = "yes";
        "force user" = "nobody";
        "force group" = "users";

        "veto files" = "/.apdisk/.DS_Store/.TemporaryItems/.Trashes/desktop.ini/ehthumbs.db/Network Trash Folder/Temporary Items/Thumbs.db/";
        "delete veto files" = "yes";
      };
    in {
      archives = mkShare "${zfs_tank}/archives";
      backups = mkShare "/${zfs_tank}/backups";

      public_share = mkPublicShare "/${zfs_tank}/public_share";
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
  # programs.nh.flake = "/home/lmilius/syncthing/nix-flake-config";

  # List services that you want to enable:

  programs.nix-ld.enable = true;

  services.fstrim.enable = true;
  services.fwupd.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Virtualization support
  virtualisation.libvirtd = {
    enable = true;
    #allowedBridges = [
    #  "br0"
    #];
  };
  programs.virt-manager.enable = true;

  # age = {
  #   # identityPaths = [ "/etc/ssh/ssh_host_ed25519_key.pub" ];
  #   secrets = {
  #     traefik_env = {
  #       file = ../../secrets/nix-server/traefik_env.age;
  #     };
  #     paperless_admin_pass = {
  #       file = ../../secrets/nix-server/paperless_admin_pass.age;
  #     };
  #     # traefik_conf = {
  #     #   file = ../../secrets/nix-server/traefik_conf_toml.age;
  #     #   path = "${appdata_path}/traefik/traefik.toml";
  #     #   owner = "traefik";
  #     #   group = "traefik";
  #     #   mode = "770";
  #     # };
  #     # traefik_rules = {
  #     #   file = ../../secrets/nix-server/traefik_rules_toml.age;
  #     #   path = "${appdata_path}/traefik/rules.toml";
  #     #   owner = "traefik";
  #     #   group = "traefik";
  #     #   mode = "770";
  #     # };
  #   };
  # };

  virtualisation.docker.daemon.settings.data-root = "/${zfs_tank}/docker-data";
  # virtualisation.oci-containers = {
  #   backend = "docker";
  #   containers = {
  # #     traefik = {
  # #       image = "traefik:v2.10.7";
  # #       ports = [
  # #         "0.0.0.0:80:80"
  # #         "0.0.0.0:443:443"
  # #       ];
  # #       labels = {
  # #         "traefik.enable" = "true";
  # #         "traefik.http.routers.traefik.entrypoints" = "websecure";
  # #         "traefik.http.routers.traefik.rule" = "Host(`proxy.${local_domain}`)";
  # #         "traefik.http.routers.traefik.tls" = "true";
  # #         "traefik.http.routers.traefik.service" = "api@internal";
  # #         "traefik.http.services.traefik.loadbalancer.server.port" = "8080";
  # #       };
  # #       volumes = [
  # #         "${appdata_path}/traefik:/etc/traefik"
  # #         "/var/run/docker.sock:/var/run/docker.sock:ro"
  # #       ];
  # #       environmentFiles = [ config.age.secrets.traefik_env.path ];
  # #     };
  #     speedtest = {
  #       image = "linuxserver/librespeed:latest";
  #       environment = {
  #         MODE = "standalone";
  #       };
  #       # labels = {
  #       #   "traefik.enable" = "true";
  #       #   "traefik.http.routers.speedtest.rule" = "Host(`speedtest.${local_domain}`)";
  #       # };
  #       ports = [
  #         "127.0.0.1:8080:80"
  #       ];
  #     };
  #     # paperless = {
  #     #   image = "ghcr.io/paperless-ngx/paperless-ngx:2.12.1";

  #     # }
  #   };
  # };

  # outputs.nixosModules.paperless = {
  #   admin_pass_file = config.age.secrets.paperless_admin_pass.path;
  #   appdata_path = appdata_path;
  #   domain = local_domain;
  # };

  # services.traefik = {
  #   enable = true;
  #   staticConfigFile = config.age.secrets.traefik_conf.path;
  #   environmentFiles = [
  #     config.age.secrets.traefik_env.path
  #   ];
  #   dataDir = "${appdata_path}/traefik";
  # };

  # users.users.traefik = {
  #   extraGroups = [ "docker" ];
  # };

  # systemd.tmpfiles.rules = [
  #   "d ${appdata_path}/nginx 750 ${config.services.nginx.user} ${config.services.nginx.group} - -"
  #   "d ${appdata_path}/nginx/certs 750 ${config.services.nginx.user} ${config.services.nginx.group} - -"
  # ];

  # Allow nginx access to letsencrypt keys
  # users.users."nginx".extraGroups = [ "acme" ];


  # services.nginx = {
  #   enable = true;
  #   recommendedOptimisation = true;
  #   recommendedTlsSettings = true;
  #   recommendedGzipSettings = true;
  #   recommendedProxySettings = true;
  #   virtualHosts = {
  #     "ha.${local_domain}" = {
  #       enableACME = false;
  #       useACMEHost = local_domain;
  #       forceSSL = true;
  #       locations."/" = {
  #         proxyPass = "http://10.10.200.10:8123";
  #         proxyWebsockets = true;
  #       };
  #     };
  #     "speedtest.${local_domain}" = {
  #       enableACME = false;
  #       useACMEHost = local_domain;
  #       forceSSL = true;
  #       locations."/" = {
  #         proxyPass = "http://127.0.0.1:8080";
  #         proxyWebsockets = true;
  #       };
  #     };
  #     "nextcloud.${local_domain}" = {
  #       enableACME = false;
  #       useACMEHost = local_domain;
  #       forceSSL = true;
  #     };
  #     "mealie.${local_domain}" = {
  #       enableACME = false;
  #       useACMEHost = local_domain;
  #       forceSSL = true;
  #       locations."/" = {
  #         proxyPass = "http://127.0.0.1:9000";
  #         proxyWebsockets = true;
  #       };
  #     };
  #   };
  # };

  # # services.nginx.virtualHosts = lib.mkMerge vHostLocal "speedtest" local_domain "8080";
  
  # security.acme = {
  #   acceptTerms = true;
  #   defaults = {
  #     email = "lmilius12@gmail.com";
  #     dnsProvider = "cloudflare";
  #     dnsResolver = "1.1.1.1:53";
  #     environmentFile = config.age.secrets.traefik_env.path;
  #   };
  #   certs."${local_domain}" = {
  #     domain = local_domain;
  #     extraDomainNames = [ "*.${local_domain}" ];
  #     group = config.services.nginx.group;
  #     dnsPropagationCheck = true;
  #     reloadServices = [ "nginx" ];
  #     # directory = "${appdata_path}/nginx/certs";
  #   };
  # };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ 80 443 22 ];
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

