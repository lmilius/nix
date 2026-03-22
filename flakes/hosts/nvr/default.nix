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
      outputs.nixosModules.nix_cache
      outputs.nixosModules.lmilius_user
      outputs.nixosModules.deployer_user
      outputs.nixosModules.remote_build_server
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

  # Remote build server configuration
  lmilius-remote-build-server = {
    enable = true;
    maxJobs = 8;
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

  environment.systemPackages = with pkgs; [
    pkgs.vim
    pkgs.intel-gpu-tools
  ];

  programs.nix-ld.enable = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;
  services.openssh.enable = true;

  # Firewall: allow SSH from local network for builds
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    trustedInterfaces = [ "tailscale0" "docker0" "br0" ];
    # Allow all traffic from local network for nix daemon builds
    interfaces = {
      "tailscale0" = {
        trusted = true;
      };
      "br0" = {
        trusted = true;
      };
    };
  };

  system.stateVersion = "24.05";
}
