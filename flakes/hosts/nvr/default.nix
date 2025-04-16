
{ inputs, outputs, lib, config, pkgs, hostname, ... }:
let
  # zfs_tank = "tank";
  # appdata_path = "/${zfs_tank}/appdata";
  # bitcoin_data_dir = "/${zfs_tank}/bitcoin";
  # local_domain = "nvr.miliushome.com";
in
{
  imports =
    [ inputs.disko.nixosModules.disko

      (import ./disko-config.nix {
        disks = [ "/dev/nvme0n1" ];
      })
      
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
      outputs.nixosModules.cockpit
      outputs.nixosModules.docker_daemon
      outputs.nixosModules.intel_gpu
      outputs.nixosModules.syncthing
      outputs.nixosModules.systemd_oom
    ];
  

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_6_12;
  };
  
  networking = {
    hostId = "e324fe9f";
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.
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
  ];

  programs.nix-ld.enable = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

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

