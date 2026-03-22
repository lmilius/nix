{ inputs, outputs, lib, config, pkgs, hostname, ... }:
let
  zfs_tank = "/tank2";
in
{
  imports =
    [
      inputs.disko.nixosModules.disko

      (import ./disko-config.nix {
        disks = [ "/dev/nvme0n1" ];
      })

      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
      outputs.nixosModules.docker_daemon
      outputs.nixosModules.intel_gpu
      outputs.nixosModules.lmilius_user
      outputs.nixosModules.deployer_user
      # Remote build client - use NVR as build server
      outputs.nixosModules.remote_build_client

      inputs.agenix.nixosModules.default
    ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "zfs" "btrfs" ];
    zfs = {
      forceImportRoot = false;
      extraPools = [ "tank2" ];
    };
    kernelModules = [ "drivetemp" ];
    kernelParams = [
      "i915.fastboot=1"
      "i915.disable_display=1"
    ];
    kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "kernel.task_delayacct" = 1;
    };
  };

  fileSystems."/mnt/backups" = {
    device = "/dev/disk/by-uuid/a6fef221-763e-46d4-88c1-212136d94125";
  };

  networking.hostId = "dab4ad1d";
  services.zfs = {
    autoScrub.enable = true;
    autoSnapshot = {
      enable = true;
      flags = "-k -p --utc";
      daily = 7;
      weekly = 5;
      monthly = 12;
    };
  };

  networking = {
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
          address = "10.10.200.90";
          prefixLength = 24;
        }];
        wakeOnLan.enable = true;
      };
    };
    defaultGateway = "10.10.200.1";
    nameservers = [ "10.10.200.1" ];
    localCommands = ''
      ip rule add to 10.10.200.0/24 priority 2500 lookup main
    '';
  };

  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
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

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.lmilius = {
      imports = [
        ../../users/lmilius/home.nix
      ];
      programs.rclone = {
        enable = true;
        package = pkgs.rclone;
        remotes = {
          b2 = {
            config = {
              type = "b2";
              hard_delete = true;
            };
            secrets = {
              account = config.age.secrets."b2/accountid".path;
              key = config.age.secrets."b2/key".path;
            };
          };
        };
      };
    };
  };

  users.users.lmilius.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF lmilius@x1carbon"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGxP4uuwDHt55l/TjdJNnS+legL8oUgk/3FFtev/NBvsAAAABHNzaDo= Yubikey Personal SSH Key"
  ];

  users.users.deployer.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJr6u53xcfqXT8h42hTG2S7QEDOavh4AQmqfRVAgOvK6 lmilius@util"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF lmilius@x1carbon"
  ];

  environment.systemPackages = [
    pkgs.vim
    pkgs.backblaze-b2
    pkgs.hddtemp
    pkgs.intel-gpu-tools
    pkgs.distrobox
    pkgs.virt-manager
    pkgs.qemu
    pkgs.quickemu
    pkgs.rclone
  ];

  services.samba-wsdd = {
    enable = true;
    discovery = true;
    openFirewall = true;
    hostname = "${hostname}";
  };

  services.samba = {
    enable = true;
    openFirewall = true;
    settings = let
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "${hostname}";
        "netbios name" = "${hostname}";
        "security" = "user";
        "hosts allow" = "10.10.200. 192.168.122. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
        "follow symlinks" = "yes";
        "inherit permissions" = "yes";
      };
      mkShare = path: {
        inherit path;
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
        inherit path;
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
      "global" = global;
      "archives" = mkShare "/${zfs_tank}/archives";
      "backups" = mkShare "/${zfs_tank}/backups";
      "ha_backups" = mkShare "/${zfs_tank}/backups/ha";
      "isos" = mkShare "/${zfs_tank}/isos/template/iso";
      "public_share" = mkPublicShare "/${zfs_tank}/public_share";
    };
  };

  age.secrets = {
    "borg/passphrase" = {
      file = ../../secrets/borgbackup_passphrase.age;
    };
    "b2/accountid" = {
      file = ../../secrets/b2_account_id.age;
      path = "${config.home-manager.users.lmilius.home.homeDirectory}/.config/rclone/accountid";
      owner = "lmilius";
    };
    "b2/key" = {
      file = ../../secrets/b2_account_key.age;
      path = "${config.home-manager.users.lmilius.home.homeDirectory}/.config/rclone/key";
      owner = "lmilius";
    };
    "restic/localpass" = {
      file = ../../secrets/restic_password_local.age;
    };
  };

  # # Send notification on status of backup job
  # systemd.services.backup-notification = {
  #   description = "Send notification on backup run";
  #   after = [ "network-online.target" ];
  #   wants = [ "network-online.target" ];
  #   # environment = {
  #   #   APPRISE_TOKEN = "";
  #   # };
  #   serviceConfig = {
  #     Type = "oneshot";
  #     ExecStart = ''${pkgs.curl}/bin/curl https://status.miliushome.com/api/push/cbUhYoqn8k?status=up&msg=OK&ping='';
  #     # EnvironmentFile = ;
  #   };
  # } // flip mapAttrs' config.services.borgbackup.jobs ( name: value:
  #   nameValuePair "borgbackup-job-photos" {
  #     unitConfig.OnFailure = "backup-notification.service";
  # });

  # https://github.com/VTimofeenko/monorepo-machine-config/tree/master/nixosModules/services/nut-client
  # power.ups = {
  #   enable = true;
  #   mode = "netclient";
  #   upsmon = {
  #     enable = true;
  #     monitor = {
  #       rack_ups = {
  #         system = "myups@10.10.200.10";
  #         passwordFile = /dev/null;
  #         user = "nas";
  #         type = "slave";
  #       };
  #     };
  #   };
  # };

  # Backups
  services.borgbackup = {
    jobs = {
      photos = {
        paths = [
          "/tank2/immich"
          "/tank2/media_photos"
        ];
        exclude = [
          "*.log"
        ];
        encryption = {
          mode = "repokey-blake2";
          passCommand = "cat ${config.age.secrets."borg/passphrase".path}";
        };
        repo = "/tank2/backups/borgbackups/photos";
        compression = "zstd,10";
        startAt = "daily";
        prune.keep = {
          within = "1d"; # keep all archives from the last day
          daily = 7;
          weekly = 5;
          monthly = -1; # Keep at least one archive for each month
        };
        postHook = ''${pkgs.curl}/bin/curl https://status.miliushome.com/api/push/cbUhYoqn8k?status=up&msg=OK&ping='';
      };
      appdata = {
        paths = [
          "/home/deployer/appdata"
        ];
        exclude = [
          "*.log"
          "ZZ_OLD/*"
          "jellyfin/transcodes/*"
        ];
        encryption = {
          mode = "repokey-blake2";
          passCommand = "cat ${config.age.secrets."borg/passphrase".path}";
        };
        repo = "/tank2/backups/borgbackups/appdata";
        compression = "zstd,10";
        startAt = "daily";
        prune.keep = {
          within = "1d"; # keep all archives from the last day
          daily = 7;
          weekly = 5;
          monthly = -1; # Keep at least one archive for each month
        };
        postHook = ''${pkgs.curl}/bin/curl https://status.miliushome.com/api/push/e58FJH5LJM?status=up&msg=OK&ping='';
      };
    };
  };

  services.restic.backups = {
    local = {
      initialize = true;
      repository = "/mnt/backups/BACKUPS/restic/local";
      passwordFile = config.age.secrets."restic/localpass".path;
      paths = [
        "/tank2/backups"
      ];
      exclude = [
        "ZZ_old_nvr/*"
        "Emma/*"
        "lmilius/*"
        "GAME-PC/*"
      ];
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
      ];
    };
  };

  systemd.services.rclone-b2-appdata = {
    enable = true;
    after = [ "network.target" ];
    description = "Rclone backups to B2 BackBlaze for appdata.";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''${pkgs.rclone}/bin/rclone --config ${config.home-manager.users.lmilius.home.homeDirectory}/.config/rclone/rclone.conf sync --progress --fast-list /tank2/backups/borgbackups/appdata b2:lmilius-backups/appdata/'';
    };
  };

  systemd.timers.rclone-b2-appdata = {
    wantedBy = [ "timers.target" ];
    partOf = [ "rclone-b2-appdata.service" ];
    timerConfig = {
      OnCalendar = "10:00 UTC";
      Unit = "rclone-b2-appdata.service";
    };
  };

  systemd.services.rclone-b2-photos = {
    enable = true;
    after = [ "network.target" ];
    description = "Rclone backups to B2 BackBlaze for photos.";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''${pkgs.rclone}/bin/rclone --config ${config.home-manager.users.lmilius.home.homeDirectory}/.config/rclone/rclone.conf sync --progress --fast-list /tank2/backups/borgbackups/photos b2:lmilius-backups/photos/'';
    };
  };

  systemd.timers.rclone-b2-photos = {
    wantedBy = [ "timers.target" ];
    partOf = [ "rclone-b2-photos.service" ];
    timerConfig = {
      OnCalendar = "09:00 UTC";
      Unit = "rclone-b2-photos.service";
    };
  };

  services.nfs.server.enable = true;

  programs.nix-ld.enable = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;

  services.openssh.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Use NVR as remote build host
  lmilius-remote-build-client = {
    enable = true;
    builderHost = "10.10.200.93";
    sshUser = "nixbuilder";
    maxJobs = 12;
    speedFactor = 2;
  };

  system.stateVersion = "24.05";
}
