# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  unstable = import
    (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixpkgs-unstable)
  { config = config.nixpkgs.config; };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      # ./steam.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_6_0;
  # boot.kernelParams = [ "nouveau.modeset=0" ];

  boot.kernel.sysctl = { "vm.swappiness" = 10; };

  networking.hostName = "x1carbon"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "systemd-resolved";
  # Refer to: https://github.com/NixOS/nixpkgs/issues/59603
  # and: https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;
  services.resolved.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.utf8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;

    # Configure keymap in X11
    layout = "us";
    xkbVariant = "";

    # Enable XFCE4
    # displayManager.lightdm.enable = true;
    # desktopManager.xfce.enable = true;

    # Enable KDE Plasma 5
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;

    # Enable the Gnome Desktop Environment.
    # desktopManager.gnome.enable = true;
    # displayManager.gdm.enable = true;
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;
  # # services.xserver.displayManager.defaultSession = "plasmawayland";
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    elisa
  ];
  
  # Enable the Cinnamon Desktop Environment.
  #services.xserver.desktopManager.cinnamon.enable = true;
  #services.xserver.displayManager.lightdm.enable = true;
  
  # Enable the Panthen Desktop Environment.
  #services.xserver.desktopManager.pantheon.enable = true;
  #services.xserver.displayManager.lightdm.enable = true;

  # Enable the Deepin Desktop Environment.
  #services.xserver.desktopManager.deepin.enable = true;
  #services.xserver.displayManager.lightdm.enable = true;  
  
  # Enable Budgie Desktop Environment.
  #services.xserver.desktopManager.budgie.enable = true;
  #services.xserver.displayManager.lightdm.enable = true;
  
  # Enable the Mate Desktop Environment.
  #services.xserver.desktopManager.mate.enable = true;
  #services.xserver.displayManager.lightdm.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  #   # If you want to use JACK applications, uncomment this
  #   #jack.enable = true;

  #   # use the example session manager (no others are packaged yet so this is enabled by default,
  #   # no need to redefine it in your config for now)
  #   #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.lmilius = {
    isNormalUser = true;
    description = "Luke Milius";
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" "dialout" ]; # dialout used for serial devices
    packages = with pkgs; [
      firefox
      kate
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # nix trusted users
  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  # Intel GPU
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      # intel-compute-runtime
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  # services.xserver.deviceSection = ''
  #   Driver "i915"
  #   Option "DRI" "2"
  #   Option "TearFree" "true"
  # '';


  # nixpkgs.config.permittedInsecurePackages = [
  #   "electron-24.8.6"
  # ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    curl
    tmux
    htop
    iotop
    usbutils
    pciutils
    unstable.vscode
    # vscode
    plasma5Packages.plasma-thunderbolt
    unzip
    intel-gpu-tools
    unstable.bitwarden
    moonlight-qt
    teamviewer
    unstable.tailscale
    yubico-piv-tool
    yubikey-agent
    yubikey-manager
    yubikey-manager-qt
    yubikey-personalization
    yubikey-personalization-gui
    # yubioath-desktop
#    busybox
    powertop
    docker
    docker-compose
    steam
    moonlight-qt
    nextcloud-client
    google-chrome
    chromium
    arduino
    ubootTools
    openscad
    gparted
    vlc
    unstable.discord
    intel-gpu-tools
    joplin-desktop
    cups-brother-hl3140cw
    lm_sensors
    screen
    nmap
    distrobox
    # agenix
    exfatprogs
    ### Matrix Clients
    # fractal
    element-desktop
    libsForQt5.neochat
    fluffychat
    fwupd
    # fprintd
    python310
    python310Packages.pip
    python310Packages.virtualenv
    unstable.rtl_433
    virt-manager
    qemu
    openssl
    #disk utils
    du-dust
    duf
    dua
    syncthing
    # syncthingtray
    # amtterm
    wineWowPackages.full # wine
  ];

  # services.fprintd.enable = true;
  # services.fprintd.tod.enable = true;
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-vfs0090;
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  # Docker setup
  # virtualisation.docker = {
  #   enable = true;
  #   autoPrune = {
  #     enable = true;
  #   };
  #   enableOnBoot = true;
  #   #daemon.settings = {
  #   #  log-opts = {
  #   #    max-size = "10m";
  #   #  };
  #   #};
  # };

  # Podman support
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
      # For Nixos version > 22.11
      #defaultNetwork.settings = {
      #  dns_enabled = true;
      #};
    };
  };

  # VirtualBox support
  virtualisation.virtualbox.host.enable = true;
  boot.kernelParams = [ "vboxdrv.load_state=1" ];
  boot.kernelModules = [ "vboxdrv" "vboxnetadp" "vboxnetflt" "vboxpci" ];
  users.extraGroups.vboxusers.members = [ "lmilius" ];

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
  

  # Yubikey setup for GPG and SSH
  # services.yubikey-agent.enable = true;
  # hardware.gpgSmartcards.enable = true;
  # services.udev.packages = [ pkgs.yubikey-personalization ];
  #environment.shellInit = ''
  #  export GPG_TTY="$(tty)"
  #  gpg-connect-agent /bye
  #  export SSH_AUTH_SOCK="/run/user/$UID/gnupg/S.gpg-agent.ssh"
  #'';

  # Enable thunderbolt's boltctl - https://nixos.wiki/wiki/Thunderbolt
  services.hardware.bolt.enable = true;

  # Enable the teamviewer service
  services.teamviewer.enable = true;

  # Enable tailscale service
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";
  networking.firewall.checkReversePath = "loose";
  nixpkgs.overlays = [(final: prev: {
    tailscale = unstable.tailscale;
  })];

  # Syncthing
  services.syncthing = {
    enable = true;
    user = "lmilius";
    dataDir = "/home/lmilius/Documents";
    configDir = "/home/lmilius/Documents/.config/syncthing";
  };

  # Enable steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
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


  system.copySystemConfiguration = true;

  programs.bash.shellAliases = {
    l = "ls -alh";
    ll = "ls -l";
    ls = "ls --color=tty";
    dcp = "docker-compose ";
    dlog = "docker logs -f ";
    dtop = "docker run --name ctop -it --rm -v /var/run/docker.sock:/var/run/docker.sock quay.io/vektorlab/ctop ";
    nix-listgens = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
    nix-gc5d = "sudo nix-collect-garbage -d --delete-older-than 5d";
    nix-optimize = "sudo nix-store --optimize";
    rebuild = "sudo nixos-rebuild";
  };

  # # nix-command and flakes experimental enable
  # nix = {
  #   package = pkgs.nixFlakes;
  #   extraOptions = lib.optionalString (config.nix.package == pkgs.nixFlakes)
  #     "experimental-features = nix-command flakes";
  # };

  # Nix automated garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.extraOptions = ''
    min-free = ${toString (100 * 1024 * 1024)}
    max-free = ${toString (1024 * 1024 * 1024)}
  '';


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
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

# Home Manager Config
  # let
  #   home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/master.tar.gz";
  # in
  # {
  #   imports = [
  #     (import "${home-manager}/nixos")
  #   ];
    
  #   home-manager.users.lmilius = {
  #     home.stateVersion = "23.04";
  #   };
  # }

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
