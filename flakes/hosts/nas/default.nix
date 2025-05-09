
{ inputs, outputs, lib, config, pkgs, hostname, ... }:
let
  zfs_tank = "/tank2";
in
{
  imports =
    [ # Include the results of the hardware scan.
      inputs.disko.nixosModules.disko

      (import ./disko-config.nix {
        disks = [ "/dev/nvme0n1" ];
      })

      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
      # outputs.nixosModules.cockpit
      outputs.nixosModules.docker_daemon
      outputs.nixosModules.intel_gpu
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
    supportedFilesystems = [ "zfs" "btrfs" ];
    zfs = {
      forceImportRoot = false;
      extraPools = [ "tank2" ];
    };
    kernelModules = [ "drivetemp" ];
    kernelParams = ["i915.fastboot=1"];
    kernel.sysctl."net.ipv4.ip_forward" = 1;
    kernelPackages = pkgs.linuxPackages_6_12;
  };

  # External Backup Drive
  fileSystems."/mnt/backups" = {
    device = "/dev/disk/by-uuid/a6fef221-763e-46d4-88c1-212136d94125";
  };
  
  # head -c4 /dev/urandom | od -A none -t x4
  networking.hostId = "dab4ad1d";
  services.zfs.autoScrub.enable = true;

  networking = {
    firewall = {
      enable = false;
      trustedInterfaces = [ "tailscale0" ];
      # allowedTCPPorts = [ 80 443 22 ];
    };
    # bridges = {
    #   br0 = {
    #     interfaces = [ "eno1" ];
    #   };
    # };
    interfaces = {
      # br0 = {
      #   useDHCP = false;
      #   ipv4.addresses = [{
      #       address = "10.10.200.90";
      #       prefixLength = 24;
      #     }];
      # };
      eno1 = {
        # useDHCP = true;
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

  # Enable tailscale service
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "server";
    openFirewall = true;
    package = pkgs.unstable.tailscale;
    extraUpFlags = [
      "--accept-routes=true"
      "--accept-dns"
      "--advertise-exit-node"
      "--advertise-routes 10.10.200.0/24"
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
    };
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lmilius = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "libvirtd" "deployer" "syncthing" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [ 
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF lmilius@x1carbon"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGxP4uuwDHt55l/TjdJNnS+legL8oUgk/3FFtev/NBvsAAAABHNzaDo= Yubikey Personal SSH Key"
    ];
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
    hddtemp
    intel-gpu-tools
    distrobox
    virt-manager
    qemu
    quickemu
  ];

  services.samba-wsdd = {
    enable = true; # make shares visible for windows 10 clients
    discovery = true;
    openFirewall = true;
    hostname = "${hostname}";
  };
  # Still need to run 'smbpasswd -a <USER>'
  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    # settings = {
    #   global = {
    #     "workgroup" = "WORKGROUP";
    #     "server string" = "${hostname}";
    #     "netbios name" = "${hostname}";
    #     "security" = "user";
    #     "hosts allow" = "10.10.200. 127.0.0.1 localhost";
    #     "hosts deny" = "0.0.0.0/0";
    #     "guest account" = "nobody";
    #     "map to guest" = "bad user";
    #     # "create mask" = "0664";
    #     # "directory mask" = "0775";
    #     "follow symlinks" = "yes";
    #     "inherit permissions" = "yes";
    #   };
    # };
    # extraConfig = ''
    #   # workgroup = WORKGROUP
    #   # server string = ${hostname}
    #   # netbios name = ${hostname}

    #   server role = standalone server
    #   dns proxy = no

    #   # pam password change = yes
    #   # map to guest = bad user
    #   # usershare allow guests = yes
    #   # create mask = 0664
    #   # force create mode = 0664
    #   # directory mask = 0775
    #   # force directory mode = 0775
    #   follow symlinks = yes
    #   load printers = no
    #   printing = bsd
    #   printcap name = /dev/null
    #   disable spoolss = yes
    #   strict locking = no
    #   aio read size = 0
    #   aio write size = 0
    #   vfs objects = acl_xattr catia fruit streams_xattr
    #   inherit permissions = yes

    #   # Security
    #   client ipc max protocol = SMB3
    #   client ipc min protocol = SMB2_10
    #   client max protocol = SMB3
    #   client min protocol = SMB2_10
    #   server max protocol = SMB3
    #   server min protocol = SMB2_10
    # '';
    settings = let
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "${hostname}";
        "netbios name" = "${hostname}";
        "security" = "user";
        "hosts allow" = "10.10.200. 127.0.0.1 localhost";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
        # "create mask" = "0664";
        # "directory mask" = "0775";
        "follow symlinks" = "yes";
        "inherit permissions" = "yes";
      };
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
      "global" = global;
      "archives" = mkShare "/${zfs_tank}/archives";
      "backups" = mkShare "/${zfs_tank}/backups";
      "ha_backups" = mkShare "/${zfs_tank}/backups/ha";

      "public_share" = mkPublicShare "/${zfs_tank}/public_share";
    };
  };

  # NFS
  # fileSystems."/export/pve_data" = {
  #   device = "/tank2/pve_data";
  #   options = [ "bind" ];
  # };

  services.nfs.server.enable = true;
  # services.nfs.server.exports = ''
  #   /export           10.10.200.92(rw,sync,nohide,insecure,no_subtree_check,crossmnt,fsid=0)
  #   /export/pve_data  10.10.200.92(rw,sync,nohide,insecure,no_subtree_check)
  # '';
  # /export           192.168.1.10(rw,fsid=0,no_subtree_check) 192.168.1.15(rw,fsid=0,no_subtree_check)


  # nix cli helper
  # https://github.com/viperML/nh
  # programs.nh.flake = "/home/lmilius/workspace/nix/flakes";

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

  virtualisation.docker.daemon.settings.data-root = "/${zfs_tank}/docker-data";

  # syncthing overrides
  users.groups."syncthing" = {};
  users.users."syncthing" = {
    group = "syncthing";
    extraGroups = [ "syncthing" "deployer" ];
  };
  services.syncthing = {
    user = "syncthing";
    group = "syncthing";
    dataDir = "/${zfs_tank}/appdata/syncthing";
    configDir = "/${zfs_tank}/appdata/syncthing/.config/syncthing";
  };

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

