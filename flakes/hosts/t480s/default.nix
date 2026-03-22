{ inputs, outputs, lib, config, pkgs, hostname, ... }:
{
  imports =
    [
      inputs.disko.nixosModules.disko

      (import ./disko-config.nix {
        disks = [ "/dev/nvme0n1" ];
      })

      ./hardware-configuration.nix

      inputs.home-manager.nixosModules.home-manager

      outputs.nixosModules.bluetooth
      outputs.nixosModules.docker_daemon
      outputs.nixosModules.intel_gpu
      outputs.nixosModules.pipewire
      outputs.nixosModules.plasma6
      outputs.nixosModules.lmilius_user

      # Remote build client - use NVR as build server
      outputs.nixosModules.remote_build_client

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

  boot = {
    loader = {
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
      };
      timeout = 3;
    };
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
  };

  hardware = {
    enableRedistributableFirmware = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
  services.hardware.bolt.enable = true;

  networking = {
    networkmanager = {
      enable = true;
      dns = "dnsmasq";
      wifi.powersave = false;
    };
    useDHCP = false;
    interfaces = {
      enp0s31f6 = {
        useDHCP = true;
      };
      wlp61s0 = {
        useDHCP = true;
      };
    };
  };

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

  services.nebula.networks.mesh = {
    enable = true;
    isLighthouse = false;
    cert = "/etc/nebula/t480s.crt";
    key = "/etc/nebula/t480s.key";
    ca = "/etc/nebula/ca.crt";
    lighthouses = [
      "10.100.100.1"
    ];
    staticHostMap = {
      "10.100.100.1" = [
        "gateway.miliusfam.com:4242"
      ];
    };
    firewall = {
      outbound = [
        {
          host = "any";
          port = "any";
          proto = "any";
        }
      ];
      inbound = [
        {
          host = "any";
          port = "any";
          proto = "icmp";
        }
      ];
    };
    settings = {
      cipher = "aes";
      local_allow_list = {
        "10.0.0.0/8" = false;
        "172.16.0.0/12" = false;
        "192.168.0.0/16" = false;
        interfaces = {
          "docker.*" = false;
          "tailscale.*" = false;
        };
        "10.10.200.0/24" = true;
      };
    };
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.cups-brother-hl3140cw ];
  };

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
  };

  services.bpftune.enable = true;
  programs.bcc.enable = true;

  services.upower.enable = true;
  hardware.flipperzero.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.lmilius = {
      imports = [
        ../../users/lmilius/home.nix
      ];
    };
  };

  users.users.lmilius.extraGroups = [
    "networkmanager"
    "wheel"
    "docker"
    "libvirtd"
    "dialout"
  ];

  users.users.lmilius.packages = with pkgs; [
    unstable.vscode
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
        tailscale.vscode-tailscale
        # saoudrizwan.claude-dev
      ];
    })
  ];

  environment.systemPackages = [
    pkgs.firefox
    pkgs.intel-gpu-tools
    pkgs.bitwarden-desktop
    pkgs.steam-run
    pkgs.moonlight-qt
    pkgs.teamviewer
    pkgs.yubioath-flutter
    pkgs.steam
    pkgs.nextcloud-client
    pkgs.google-chrome
    pkgs.ubootTools
    pkgs.openscad-unstable
    pkgs.vlc
    pkgs.mpv
    pkgs.unstable.discord
    pkgs.lm_sensors
    pkgs.distrobox
    pkgs.exfatprogs
    pkgs.qemu
    pkgs.openssl
    pkgs.wineWowPackages.full
    pkgs.kmon
    pkgs.freetube
    pkgs.xwayland
    pkgs.trayscale
    pkgs.thonny
    pkgs.wayland-utils
    pkgs.btrfs-assistant
    pkgs.pulseview
    pkgs.kdePackages.discover
    pkgs.insomnia
    inputs.agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.unstable.onedrive
    pkgs.onedrivegui
    pkgs.samba
    pkgs.libreoffice-qt6-fresh
    pkgs.hunspell
    pkgs.hunspellDicts.en_US
    pkgs.wirelesstools
    pkgs.ffmpeg-full
    pkgs.winbox4
    pkgs.unstable.whosthere
    pkgs.weylus
    pkgs.opencode
    pkgs.curl
  ];

  services.udev.packages = [
    pkgs.yubikey-personalization
    pkgs.libu2f-host
  ];

  security = {
    rtkit.enable = true;
    polkit.enable = true;
  };

  virtualisation = {
    libvirtd = {
      enable = true;
    };
    spiceUSBRedirection.enable = true;
  };

  services.flatpak.enable = true;

  services.pcscd.enable = true;

  age.identityPaths = [
    "${config.users.users.lmilius.home}/.ssh/id_ed25519"
    "/root/.ssh/id_ed25519"
  ];

  environment.shells = [ pkgs.bash pkgs.zsh ];

  services.teamviewer.enable = true;


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


  # Borg Backups
  services.borgbackup.jobs.documents-lmilius = {
    paths = "/home/lmilius/Documents";
    encryption.mode = "none";
    environment.BORG_RSH = "ssh -i /home/lmilius/.ssh/id_ed25519";
    repo = "ssh://borgwarehouse@borg.miliushome.com:2222/./f25e9129";
    compression = "auto,zstd";
    startAt = "daily";
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      44445 # nc
    ];
    allowedUDPPorts = [
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

  # Use NVR as remote build host
  lmilius-remote-build-client = {
    enable = true;
    builderHost = "10.10.200.93";
    sshUser = "nixbuilder";
    maxJobs = 12;
    speedFactor = 2;
  };

  system.stateVersion = "24.05";
}
