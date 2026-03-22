{ inputs, outputs, lib, config, pkgs, hostname, ... }:
let
  zfs_tank = "tank";
in
{
  imports =
    [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
      outputs.nixosModules.cockpit
      outputs.nixosModules.docker_daemon
      outputs.nixosModules.intel_gpu
      outputs.nixosModules.syncthing
      outputs.nixosModules.lmilius_user
      outputs.nixosModules.deployer_user
    ];

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

  networking.networkmanager.enable = true;

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

  environment.systemPackages = with pkgs; [
    pkgs.vim
    pkgs.intel-gpu-tools
    pkgs.distrobox
    pkgs.virt-manager
    pkgs.qemu
    pkgs.quickemu
  ];

  services.samba-wsdd.enable = true;
  services.samba = {
    enable = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "${hostname}";
        "netbios name" = "${hostname}";
        "server role" = "standalone server";
        "dns proxy" = "no";
        "pam password change" = "yes";
        "map to guest" = "bad user";
        "usershare allow guests" = "yes";
        "create mask" = "0664";
        "force create mode" = "0664";
        "directory mask" = "0775";
        "force directory mode" = "0775";
        "follow symlinks" = "yes";
        "load printers" = "no";
        "printing" = "bsd";
        "printcap name" = "/dev/null";
        "disable spoolss" = "yes";
        "strict locking" = "no";
        "aio read size" = 0;
        "aio write size" = 0;
        "vfs objects" = "acl_xattr catia fruit streams_xattr";
        "inherit permissions" = "yes";
        "client ipc max protocol" = "SMB3";
        "client ipc min protocol" = "SMB2_10";
        "client max protocol" = "SMB3";
        "client min protocol" = "SMB2_10";
        "server max protocol" = "SMB3";
        "server min protocol" = "SMB2_10";
      };
    };
    shares = let
      mkShare = path: {
        inherit path;
        browseable = "yes";
        "read only" = "no";
        "inherit acls" = "yes";
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

  programs.nix-ld.enable = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;

  services.openssh.enable = true;

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  virtualisation.docker.daemon.settings.data-root = "/${zfs_tank}/docker-data";

  networking.firewall.enable = false;

  system.stateVersion = "24.05";
}
