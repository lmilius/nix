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

      outputs.nixosModules.bluetooth
      outputs.nixosModules.docker_daemon
      outputs.nixosModules.intel_gpu
      outputs.nixosModules.pipewire
      outputs.nixosModules.plasma6
      # outputs.nixosModules.systemd_oom

      inputs.agenix.nixosModules.default

      (outputs.nixosModules.restic_home_backup {
        config = config;
        pkgs = pkgs;
        hostname = hostname;
        home_dir = config.users.users.lmilius.home;
        repo_file = ../../secrets/restic_repo_t480s_home.age;
        password_file = ../../secrets/restic_password_t480s_home.age;
      })
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
  };
  networking = {
    # hostName = outputs.hostname; # Define your hostname. (defined from flake.nix)
    networkmanager = {
      enable = true;
      dns = "systemd-resolved";
      # wifi.backend = "iwd";
      wifi.powersave = false;
    };
    # wireless = {
    #   # enable = true;  # Enables wireless support via wpa_supplicant.
    #   iwd.enable = true;
    # };
    useDHCP = false;
    # useNetworkd = true;
    # nftables.enable = true;
    interfaces = {
      enp0s31f6 = {
        useDHCP = true;
      };
      wlp61s0 = {
        useDHCP = true;
      };
    };
    # dhcpd.enable = true;
  };

  services.resolved.enable = true;

  # Enable tailscale service
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client";
    openFirewall = true;
    package = pkgs.unstable.tailscale;
    extraUpFlags = [
      "--accept-routes=false"
      "--accept-dns"
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
  services.upower.enable = true;
  hardware.flipperzero.enable = true;

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
    bitwarden
    steam-run
    moonlight-qt
    teamviewer
    yubioath-flutter
    yubikey-personalization-gui
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
    # virt-manager
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
    inputs.agenix.packages."${system}".default
    ipmiview
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
  ];

  services.udev.packages = with pkgs; [
    yubikey-personalization
    libu2f-host
  ];

  # services.fprintd.enable = true;
  # services.fprintd.tod.enable = true;
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-vfs0090;
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  # # Docker setup
  # virtualisation.docker = {
  #   enable = true;
  #   autoPrune = {
  #     enable = true;
  #     dates = "weekly";
  #   };
  #   enableOnBoot = true;
  #   #daemon.settings = {
  #   #  log-opts = {
  #   #    max-size = "10m";
  #   #  };
  #   #};
  # };

  # Podman support
  # virtualisation = {
  #   podman = {
  #     enable = true;

  #     # Create a `docker` alias for podman, to use it as a drop-in replacement
  #     dockerCompat = true;

  #     # Required for containers under podman-compose to be able to talk to each other.
  #     defaultNetwork.settings.dns_enabled = true;
  #     # For Nixos version > 22.11
  #     #defaultNetwork.settings = {
  #     #  dns_enabled = true;
  #     #};
  #   };
  # };

  # Cockpit
  # services.cockpit = {
  #   enable = true;
  #   openFirewall = true;
  #   port = 9090;
  # };

  # Security
  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  # Enable fingerprint reader.
  # services.open-fprintd.enable = true;
  # services.python-validity.enable = true; # service failing to start 6/12

  # fingerprint scanning for authentication
  # (this makes it so that it prompts for a password first. If none is entered or an incorrect one is entered, it will ask for a fingerprint instead)
  # security.pam.services.sudo.text = ''
  #   # Account management.
  #   account required pam_unix.so
    
  #   # Authentication management.
  #   auth sufficient pam_unix.so   likeauth try_first_pass nullok
  #   auth sufficient ${nixos-06cb-009a-fingerprint-sensor.localPackages.fprintd-clients}/lib/security/pam_fprintd.so
  #   auth required pam_deny.so
    
  #   # Password management.
  #   password sufficient pam_unix.so nullok sha512
    
  #   # Session management.
  #   session required pam_env.so conffile=/etc/pam/environment readenv=0
  #   session required pam_unix.so
  # '';

  # services.fprintd = {
  #   enable = true;
  #   tod = {
  #     enable = true;
  #     driver = pkgs.libfprint-2-tod1-vfs0090;
  #   };
  # };

  # Virtualization support
  virtualisation.libvirtd = {
    enable = true;
  };
  
  # QEMU UEFI support
  # environment = {
  #   (pkgs.writeShellScriptBin "qemu-system-x86_64-uefi" 
  #     qemu-system-x86_64 \
  #       -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
  #       "$@"
  #   )
  # };

  # # VirtualBox support
  # virtualisation.virtualbox.host = {
  #   enable = true;
  #   enableWebService = true;
  #   enableKvm = true;
  #   enableExtensionPack = true;
  #   addNetworkInterface = false;
  # };
  # # VirtualBox USB support
  # users.extraGroups.vboxusers.members = [ "lmilius" ];
  # services.gvfs.enable = true;
  # services.udisks2.enable = true;
  
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
  services.hardware.bolt.enable = true;

  # Enable the teamviewer service
  services.teamviewer.enable = true;

  # Syncthing (port 8384 web gui)
  services.syncthing = {
    enable = true;
    user = "lmilius";
    dataDir = "/home/lmilius/Documents";
    configDir = "/home/lmilius/Documents/.config/syncthing";
    openDefaultPorts = true;
  };

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
    dconf.enable = true;
  };


  # Hyprland Desktop
  programs.hyprland = {
    enable = true;
    withUWSM = true; # recommended for most users
    xwayland.enable = true; # Xwayland can be disabled.
  };


  # Borg Backups
  services.borgbackup.jobs.documents-lmilius = {
    paths = "/home/lmilius/Documents";
    encryption.mode = "none";
    environment.BORG_RSH = "ssh -i /home/lmilius/.ssh/id_ed25519";
    repo = "ssh://borgwarehouse@borg.miliushome.com:2222/./f25e9129";
    compression = "auto,zstd";
    startAt = "daily";
  };

  # system.copySystemConfiguration = true;

#   # This will add each flake input as a registry
#   # To make nix3 commands consistent with your flake
#   nix.registry = (lib.mapAttrs (_: flake: {inherit flake;})) ((lib.filterAttrs (_: lib.isType "flake")) inputs);
#
#   # This will additionally add your inputs to the system's legacy channels
#   # Making legacy nix commands consistent as well, awesome!
#   nix.nixPath = ["/etc/nix/path"];
#   environment.etc =
#     lib.mapAttrs'
#     (name: value: {
#       name = "nix/path/${name}";
#       value.source = value.flake;
#     })
#     config.nix.registry;

  # # Nix automated garbage collection
  # nix.gc = {
    # automatic = true;
  #   dates = "weekly";
  #   options = "--delete-older-than 30d";
  # };
  # nix.extraOptions = ''
  #   min-free = ${toString (100 * 1024 * 1024)}
  #   max-free = ${toString (1024 * 1024 * 1024)}
  # '';


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFlavor = "curses";
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 
      22000 # Syncthing
      # 27036 # steam
      80 # nix-cache nginx
      # config.services.tailscale.port
      # 41641 # tailscale
      44445 # nc
    ]; 
    allowedUDPPorts = [ 
      22000 # Syncthing
      # 27036 # steam
      80 # nix-cache nginx
      # 41641 # tailscale
      # config.services.tailscale.port
      44445 # nc
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
  system.stateVersion = "24.05"; # Did you read the comment?

}
