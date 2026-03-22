{ inputs, outputs, config, pkgs, hostname, ... }:
{
  imports =
    [
      inputs.disko.nixosModules.disko

      (import ./disko-config.nix {
        disks = [ "/dev/nvme0n1" ];
      })

      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
      outputs.nixosModules.cockpit
      outputs.nixosModules.docker_daemon
      outputs.nixosModules.intel_gpu
      ( outputs.nixosModules.nix_cache {
        ip_address = "10.10.200.93";
      })
      outputs.nixosModules.lmilius_user
      outputs.nixosModules.deployer_user
    ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_6_12;
  };

  networking = {
    hostId = "e324fe9f";
    networkmanager.enable = true;
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
    pkgs.intel-gpu-tools
  ];

  programs.nix-ld.enable = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;
  services.openssh.enable = true;
  networking.firewall.enable = false;

  system.stateVersion = "24.05";
}
