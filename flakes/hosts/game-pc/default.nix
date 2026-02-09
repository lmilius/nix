# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, outputs, lib, config, pkgs, hostname, ... }:#unstablePkgs, nixos-06cb-009a-fingerprint-sensor, agenix, hostname, ... }:
# inputs: flakes from the original imports in flake.nix
# outputs: modules from the 'modules' directory in the repo
#   outputs.nixosModules is from the 'modules/nixos/default.nix'
#   outputs.homeManagerModules is from the 'modules/home-manager/default.nix'
# let
#   outpunts = inputs.self;
# in
{
  imports =
    [
      inputs.disko.nixosModules.disko

      (import ./disko-config.nix {
        disks = [ "/dev/nvme0n1" ];
      })

      ./hardware-configuration.nix

      # nixos-hardware.nixosModules.lenovo-thinkpad-t480s

      inputs.home-manager.nixosModules.home-manager

      # outputs.nixosModules.bluetooth
      # outputs.nixosModules.docker_daemon
      # outputs.nixosModules.intel_gpu
      outputs.nixosModules.pipewire
      outputs.nixosModules.plasma6
      # outputs.nixosModules.systemd_oom

      inputs.agenix.nixosModules.default

      # (outputs.nixosModules.restic_home_backup {
      #   config = config;
      #   pkgs = pkgs;
      #   hostname = hostname;
      #   home_dir = config.users.users.lmilius.home;
      #   repo_file = ../../secrets/restic_repo_t480s_home.age;
      #   password_file = ../../secrets/restic_password_t480s_home.age;
      # })
    ];

  # nixpkgs = {
  #   # You can add overlays here
  #   overlays = [
  #     # Add overlays your own flake exports (from overlays and pkgs dir):
  #     outputs.overlays.additions
  #     outputs.overlays.modifications
  #     outputs.overlays.unstable-packages

  #     # You can also add overlays exported from other flakes:
  #     # neovim-nightly-overlay.overlays.default

  #     # Or define it inline, for example:
  #     # (final: prev: {
  #     #   hi = final.hello.overrideAttrs (oldAttrs: {
  #     #     patches = [ ./change-hello-to-hi.patch ];
  #     #   });
  #     # })
  #   ];
  #   # Configure your nixpkgs instance
  #   config = {
  #     # Disable if you don't want unfree packages
  #     allowUnfree = true;
  #   };
  # };

  # Boot
  boot = {
    # kernelParams = [ "quiet" "loglevel=3" ];
    # kernelParams = [ "quiet" ];
    loader = {
      efi.canTouchEfiVariables=true;
      # systemd-boot.enable = true;
      grub = { 
          enable = true;
          devices = [ "nodev" ];
          efiSupport = true;
      };
      timeout = 3;
    };
    # kernel.sysctl = { "vm.swappiness" = 10; };
    # kernelPackages = pkgs.unstable.linuxPackages_latest;
    # kernelPackages = pkgs.linuxPackages_latest;
    kernelPackages = pkgs.linuxPackages_zen;
  };

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 30;
  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    # fileSystems = [ "/" ];
  };

  # Enable networking
  # networking.networkmanager.enable = true;
  # networking.networkmanager.dns = "systemd-resolved";
  hardware = {
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true; # used for wine
    };
    nvidia = {
      open = false; # GTX 10 series is too old for open-source drivers
      package = config.boot.kernelPackages.nvidiaPackages.stable;
      modesetting.enable = true;
      powerManagement.enable = false; # may fix graphical corruption and system crashes on suspend/resume if set to true
      nvidiaSettings = true;
    };
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  # if Nvidia powerManagement is enabled, may need to move tmp path
  # boot.kernelParams = [ "nvidia.NVreg_TemporaryFilePath=/var/tmp" ];

  networking = {
    # hostName = outputs.hostname; # Define your hostname. (defined from flake.nix)
    networkmanager = {
      enable = true;
    #   # dns = "systemd-resolved";
    #   dns = "dnsmasq";

    };
    useDHCP = false;
    # useNetworkd = true;
    # dhcpd.enable = false;
    # nftables.enable = true;
    # interfaces = {
    #   enp7s0 = {
    #     useDHCP = true;
    #   };
    # };
  };

  # services.resolved.enable = true;

  # Enable tailscale service
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    openFirewall = true;
    package = pkgs.unstable.tailscale;
    extraUpFlags = [
      "--accept-routes=false"
      "--accept-dns=false"
      # "--exit-node gateway"
      # "--exit-node-allow-lan-access"
    ];
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

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

  services.fstrim.enable = true;

  services.gvfs.enable = true;
  services.davfs2.enable = true;

  services.atuin = {
    enable = true;
    # Optional: Configure a server for sync (uncomment and configure if needed)
    # server = {
    #   enable = true;
    #   host = "0.0.0.0";
    #   port = 8888;
    # };
  };

  # Auto Tune
  services.bpftune.enable = true;
  programs.bcc.enable = true;

  # Thinkpad power management/monitoring
  # services.tlp.enable = true; # Conflicts with servies.power-profiles-daemon.enable = true;

  # Battery power management
  hardware.flipperzero.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  services.displayManager = {
    autoLogin.enable = true;
    autoLogin.user = "lmilius";
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
    description = "Luke Milius";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "dialout" ]; # dialout used for serial devices
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

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    # unstable.vscode
    # vscode
    # plasma5Packages.plasma-thunderbolt
    firefox
    intel-gpu-tools
    bitwarden-desktop
    steam-run
    moonlight-qt
    teamviewer
    yubioath-flutter
    steam
    nextcloud-client
    google-chrome
    # chromium
    ubootTools
    openscad-unstable
    vlc
    mpv
    pkgs.unstable.discord
    lm_sensors
    distrobox
    exfatprogs
    qemu
    openssl
    wineWowPackages.full # wine
    kmon
    # keepassxc
    freetube
    xwayland
    trayscale
    thonny
    wayland-utils
    btrfs-assistant
    pulseview
    kdePackages.discover
    insomnia
    inputs.agenix.packages."${stdenv.hostPlatform.system}".default
    # ipmiview
    # pkgs.unstable.orca-slicer
    orca-slicer
    pkgs.unstable.onedrive
    onedrivegui
    samba
    libreoffice-qt6-fresh
    hunspell # spellcheck libreoffice
    hunspellDicts.en_US # spellcheck libreoffice
    wirelesstools
    ffmpeg-full
    winbox4
    # Nvidia utilities
    nvtopPackages.nvidia
    # Minikube
    minikube
    kubectl
    docker-machine-kvm2
  ];

  services.udev.packages = with pkgs; [
    yubikey-personalization
    libu2f-host
  ];

  # Security
  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  # Virtualization support
  virtualisation = {
    libvirtd = {
      enable = true;
      #allowedBridges = [
      #  "br0"
      #];
    };
    spiceUSBRedirection.enable = true;
  };
  
  # QEMU UEFI support
  # environment = {
  #   (pkgs.writeShellScriptBin "qemu-system-x86_64-uefi" 
  #     qemu-system-x86_64 \
  #       -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
  #       "$@"
  #   )
  # };
  
  # Flatpak Support
  services.flatpak.enable = true;

  # Yubikey setup for SSH
  services.pcscd.enable = true;
  # services.yubikey-agent.enable = true;
  # hardware.gpgSmartcards.enable = true;
  #environment.shellInit = ''
  #  export GPG_TTY="$(tty)"
  #  gpg-connect-agent /bye
  #  export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  #'';

  age.identityPaths = [ "${config.users.users.lmilius.home}/.ssh/id_ed25519" "/root/.ssh/id_ed25519" ];

  environment.shells = with pkgs; [ bash zsh ];
  users.defaultUserShell = pkgs.bash;

  # Enable thunderbolt's boltctl - https://nixos.wiki/wiki/Thunderbolt
  # services.hardware.bolt.enable = true;

  # Enable the teamviewer service
  services.teamviewer.enable = true;

  services.ollama = {
    enable = true;
    # Optional: preload models, see https://ollama.com/library
    loadModels = [ "llama3.2:3b" ];
    package = pkgs.ollama-cuda.override {
      # nvidia-smi --query-gpu=compute_cap --format=csv
      cudaArches = [ "61" ];
    };
    acceleration = "cuda";
  };
  services.open-webui.enable = true;

  # nix cli helper
  # https://github.com/viperML/nh
  # programs.nh.flake = "/home/lmilius/workspace/nix/flakes";

  # Enable steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for local network game transfers
  };
  hardware.steam-hardware.enable = true;
  environment.sessionVariables = rec {
    XDG_CACHE_HOME  = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME    = "\${HOME}/.local/bin";
    XDG_DATA_HOME   = "\${HOME}/.local/share";
    # Steam needs this to find Proton-GE
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "\${HOME}/.steam/root/compatibilitytools.d";
    # note: this doesn't replace PATH, it just adds this to it
    PATH = [ 
      "\${XDG_BIN_HOME}"
    ];
  };

  programs = {
    kdeconnect.enable = true;
    virt-manager.enable = true;
  };


  # # Hyprland Desktop
  # programs.hyprland = {
  #   enable = true;
  #   withUWSM = true; # recommended for most users
  #   xwayland.enable = true; # Xwayland can be disabled.
  # };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 
      # 22000 # Syncthing
      # 27036 # steam
      # 80 # nix-cache nginx
      # config.services.tailscale.port
      # 41641 # tailscale
      # 44445 # nc
    ]; 
    allowedUDPPorts = [ 
      # 22000 # Syncthing
      # 27036 # steam
      # 80 # nix-cache nginx
      # 41641 # tailscale
      # config.services.tailscale.port
      # 44445 # nc
    ]; 
    allowedTCPPortRanges = [ 
      { from = 1714; to = 1764; } # KDE Connect
    ];  
    allowedUDPPortRanges = [ 
      { from = 1714; to = 1764; } # KDE Connect
    ];
    trustedInterfaces = [ "tailscale0" ];
  };
  # networking.interfaces.enp0s31f6.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

}
