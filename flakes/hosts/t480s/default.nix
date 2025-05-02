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
      outputs.nixosModules.systemd_oom

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

  # nix = let
  #   flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  # in {
  #   settings = {
  #     # Enable flakes and new 'nix' command
  #     # experimental-features = "nix-command flakes";
  #     # Opinionated: disable global registry
  #     # flake-registry = "";
  #     # Workaround for https://github.com/NixOS/nix/issues/9574
  #     nix-path = config.nix.nixPath;
  #     # Use local nix cache
  #     # substituters = [ 
  #     #   "http://10.10.200.8" 
  #     #   # "http://100.69.216.71/" 
  #     # ];
  #   };
  #   # Opinionated: disable channels
  #   channel.enable = false;

  #   # Opinionated: make flake registry and nix path match flake inputs
  #   registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
  #   nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  # };

  # Use local nix cache
  # nix.settings.substituters = [ 
  #   "http://10.10.200.8" 
  #   # "http://100.69.216.71/" 
  # ];

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
    kernel.sysctl = { "vm.swappiness" = 10; };
    kernelPackages = pkgs.unstable.linuxPackages_latest;
  };


  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    # fileSystems = [ "/" ];
  };

  # Enable networking
  # networking.networkmanager.enable = true;
  # networking.networkmanager.dns = "systemd-resolved";
  networking = {
    # hostName = outputs.hostname; # Define your hostname. (defined from flake.nix)
    networkmanager = {
      enable = true;
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

  # # OOM configuration:
  # systemd = {
  #   # Create a separate slice for nix-daemon that is
  #   # memory-managed by the userspace systemd-oomd killer
  #   slices."nix-daemon".sliceConfig = {
  #     ManagedOOMMemoryPressure = "kill";
  #     ManagedOOMMemoryPressureLimit = "95%";
  #   };
  #   services = {
  #     "nix-daemon".serviceConfig = {
  #       Slice = "nix-daemon.slice";

  #       # If a kernel-level OOM event does occur anyway,
  #       # strongly prefer killing nix-daemon child processes
  #       OOMScoreAdjust = 1000;
  #     };
  #     # Refer to: https://github.com/NixOS/nixpkgs/issues/59603
  #     # and: https://github.com/NixOS/nixpkgs/issues/180175
  #     NetworkManager-wait-online.enable = false;
  #   };
  # };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  ## enable printer auto discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # # Enable sound with pipewire.
  # sound.enable = true;
  # hardware.pulseaudio.enable = false;
  # security.rtkit.enable = true;
  # services.pipewire = {
  #   enable = true;
  #   alsa.enable = true;
  #   alsa.support32Bit = true;
  #   pulse.enable = true;
  # #   # If you want to use JACK applications, uncomment this
  # #   #jack.enable = true;

  # #   # use the example session manager (no others are packaged yet so this is enabled by default,
  # #   # no need to redefine it in your config for now)
  # #   #media-session.enable = true;
  # };

  # hardware.bluetooth = {
  #   enable = true;
  #   powerOnBoot = true;
  # };

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
      firefox
      kate
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

  # # Intel GPU
  # nixpkgs.config.packageOverrides = pkgs: {
  #   vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  # };
  # hardware.opengl = {
  #   enable = true;
  #   extraPackages = with pkgs; [
  #     # intel-compute-runtime
  #     intel-media-driver
  #     vaapiIntel
  #     vaapiVdpau
  #     libvdpau-va-gl
  #   ];
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    # unstable.vscode
    # vscode
    # plasma5Packages.plasma-thunderbolt
    intel-gpu-tools
    bitwarden
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
    pkgs.unstable.discord
    cups-brother-hl3140cw
    lm_sensors
    distrobox
    exfatprogs
    virt-manager
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
    discover
    insomnia
    inputs.agenix.packages."${system}".default
    ipmiview
    # pkgs.unstable.orca-slicer
    orca-slicer
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

  # VirtualBox support
  # virtualisation.virtualbox.host.enable = true;
  # boot.kernelParams = [ "vboxdrv.load_state=1" ];
  # boot.kernelModules = [ "vboxdrv" "vboxnetadp" "vboxnetflt" "vboxpci" ];
  # users.extraGroups.vboxusers.members = [ "lmilius" ];

  # Virtualization support
  virtualisation.libvirtd = {
    enable = true;
  };
  programs.dconf.enable = true;
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
    # remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    # dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
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

  programs.kdeconnect.enable = true;


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
      80 # nix-cache nginx
      # config.services.tailscale.port
      # 41641 # tailscale
    ]; 
    allowedUDPPorts = [ 
      22000 # Syncthing
      80 # nix-cache nginx
      # 41641 # tailscale
      # config.services.tailscale.port
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
