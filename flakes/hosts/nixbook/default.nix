# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ inputs, outputs, lib, config, pkgs, hostname, ... }:
{
  imports =
    [
      inputs.disko.nixosModules.disko
      (import ./disko-config.nix {
        disks = [ "/dev/mmcblk0" ];
      })
      ./hardware-configuration.nix

      # ( outputs.nixosModules.nix_cache {
      #   ip_address = "10.10.200.8";
      # })

      inputs.home-manager.nixosModules.home-manager
      # outputs.nixosModules.docker_daemon
      outputs.nixosModules.systemd_oom

      inputs.agenix.nixosModules.default
    ];


  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        graceful = true;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  # networking.hostName = hostname; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  networking.networkmanager.unmanaged = ["tailscale0"];

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_6_12;

  services.xserver = {
    enable = true;
    layout = "us";
    # videoDrivers = [ "amdgpu" ];

    # Enable the XFCE4 Desktop Environment
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF lmilius@x1carbon"
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGxP4uuwDHt55l/TjdJNnS+legL8oUgk/3FFtev/NBvsAAAABHNzaDo= Yubikey Personal SSH Key"
    ];
    initialHashedPassword = "$y$j9T$pIpVsIB6vvgo3wh6aRTbT.$lSwdItSLTZcEEg/KxCWR1FZZUDduWkYgrc4nZ/zusI2";
    #packages = with pkgs; [
    #  firefox
    #  tree
    #];
  };

  programs.virt-manager.enable = true;

  # Enable tailscale service
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    openFirewall = true;
    package = pkgs.unstable.tailscale;
    extraUpFlags = [
      "--accept-routes=true"
      "--accept-dns"
      "--ssh"
      # "--exit-node gateway"
      # "--exit-node-allow-lan-access"
    ];
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

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
  system.stateVersion = "25.11"; # Did you read the comment?

}

