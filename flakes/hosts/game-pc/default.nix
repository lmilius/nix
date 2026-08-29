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

      outputs.nixosModules.docker_daemon
      outputs.nixosModules.pipewire
      outputs.nixosModules.plasma6
      outputs.nixosModules.lmilius_user

      inputs.agenix.nixosModules.default
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
    # kernelPackages = pkgs.linuxPackages_zen;
    # kernelPackages = pkgs.linuxPackages;
    kernelPackages = pkgs.linuxPackages_6_12;
    kernelParams = [
      "modprobe.blacklist=nouveau"
      "nvidia-drm.modeset=1"
    ];
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
    nvidia = {
      open = false;
      # FORCE the 26.05 legacy driver profile for older cards
      # This prevents NixOS from grabbing the incompatible 580+ stable series
      # package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
      branch = "legacy_580";
      modesetting.enable = true;
      powerManagement.enable = false;
      nvidiaSettings = true;
    };
  };

  services.xserver.videoDrivers = ["nvidia"];

  networking = {
    networkmanager = {
      enable = true;
    };
    useDHCP = false;
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

  hardware.flipperzero.enable = true;

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

  users.users.lmilius = {
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
      "libvirtd"
      "dialout"
    ];
  };

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
    pkgs.wineWow64Packages.full
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
    pkgs.nvtopPackages.nvidia
    pkgs.minikube
    pkgs.kubectl
    # pkgs.docker-machine-kvm2
    # pkgs.orca-slicer
    # HAM
    pkgs.chirp
    pkgs.sdrpp
  ];

  services.udev.packages = [
    pkgs.yubikey-personalization
    pkgs.libu2f-host
  ];

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    pam = {
      services = {
        "lmilius" = {
          kwallet = {
            enable = true;
            package = pkgs.kdePackages.kwallet-pam;
          };
        };
      };
    };
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

  services.ollama = {
    enable = true;
    loadModels = [
      "llama3.2:3b"
      "gemma3:4b"
      "qwen2.5:7b"
      "qwen3:8b"
      "phi3:14b"
      "llava:7b"
      "qwen2.5-coder:7b"
      "mistral-nemo:12b"
      "codegemma:7b"
      "phi4-mini:3.8b"
      "phi3.5:3.8b"
      "ministral-3"
      "nemotron-3.5-lightning:30b"
    ];
    package = pkgs.unstable.ollama-cuda.override {
      cudaArches = [ "61" ];
    };
    # acceleration = "cuda";
    host = "0.0.0.0";
    openFirewall = true;
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "1000000";
    };
  };
  
  # services.open-webui = {
  #   enable = true;
  #   host = "0.0.0.0";
  #   openFirewall = true;
  # };

  # nix cli helper
  # https://github.com/viperML/nh
  # programs.nh.flake = "/home/lmilius/workspace/nix/flakes";

  services.rustdesk-server = {
    enable = true;
    openFirewall = true;
    signal.relayHosts = [ "127.0.0.1" ];
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
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

  services.openssh.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      3389 # rdp
      18789 # claw
    ];
    allowedUDPPorts = [
      3389 # rdp
      18789 # claw
    ];
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; } # KDE Connect
    ];
    trustedInterfaces = [ "tailscale0" ];
  };

  system.stateVersion = "25.11";
}
