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
      outputs.nixosModules.intel_gpu
      outputs.nixosModules.pipewire
      outputs.nixosModules.systemd_oom
      outputs.nixosModules.xfce

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

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 30;
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

  services.fstrim.enable = true;

  # Auto Tune
  services.bpftune.enable = true;
  programs.bcc.enable = true;
  # Battery power management
  services.upower.enable = true;

  # boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.kernelPackages = pkgs.linuxPackages_zen;

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = [ pkgs.cups-brother-hl3140cw ];
  };
  ## enable printer auto discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

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
    packages = with pkgs; [
      # firefox
      pkgs.unstable.vscode
      # vscode extensions
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          mkhl.direnv
          njpwerner.autodocstring
          ms-vscode.cpptools
          ms-vscode.cmake-tools
          ms-vscode-remote.remote-ssh
          ms-vscode-remote.remote-containers
          ms-python.python
          ms-python.vscode-pylance
          njpwerner.autodocstring
          tailscale.vscode-tailscale
        ];
      })
    ];
  };

  environment.systemPackages = with pkgs; [
    # vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    # unstable.vscode
    # vscode
    # plasma5Packages.plasma-thunderbolt
    firefox
    intel-gpu-tools
    bitwarden-desktop
    # steam-run
    # moonlight-qt
    # teamviewer
    yubioath-flutter
    # steam
    nextcloud-client
    google-chrome
    # chromium
    ubootTools
    # openscad-unstable
    vlc
    mpv
    # pkgs.unstable.discord
    lm_sensors
    # distrobox
    exfatprogs
    # qemu
    openssl
    # wineWowPackages.full # wine
    # kmon
    # keepassxc
    # freetube
    xwayland
    trayscale
    thonny
    wayland-utils
    # btrfs-assistant
    # pulseview
    # kdePackages.discover
    # insomnia
    # inputs.agenix.packages."${stdenv.hostPlatform.system}".default
    # ipmiview
    # pkgs.unstable.orca-slicer
    # orca-slicer
    # pkgs.unstable.onedrive
    # onedrivegui
    # samba
    # libreoffice-qt6-fresh
    # hunspell # spellcheck libreoffice
    # hunspellDicts.en_US # spellcheck libreoffice
    wirelesstools
    # ffmpeg-full
    winbox4
  ];

  services.udev.packages = with pkgs; [
    yubikey-personalization
    libu2f-host
  ];

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

