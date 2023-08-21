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
      ./steam.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # boot.kernelPackages = pkgs.linuxPackages_6_0;
  # boot.kernelParams = [ "nouveau.modeset=0" ];

  networking.hostName = "x1carbon"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  # Refer to: https://github.com/NixOS/nixpkgs/issues/59603
  # and: https://github.com/NixOS/nixpkgs/issues/180175
  systemd.services.NetworkManager-wait-online.enable = false;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.utf8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment
  # services.xserver.displayManager.gdm.enable = true;
  # services.xserver.displayManager.gdm.wayland = false;
  # services.xserver.desktopManager.gnome.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # services.xserver.desktopManager.xfce.enable = true;

  # Configure keymap in X11
  # services.xserver = {
  #   layout = "us";
  #   xkbVariant = "";
  # };

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
    extraGroups = [ "networkmanager" "wheel" "docker" "libvirtd" ];
    packages = with pkgs; [
      firefox
      kate
    #  thunderbird
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Intel GPU
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
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
    plasma5Packages.plasma-thunderbolt
    unzip
    intel-gpu-tools
    bitwarden
    moonlight-qt
    teamviewer
    tailscale
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
  ];

  # services.fprintd.enable = true;
  # services.fprintd.tod.enable = true;
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-vfs0090;
  # services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;

  # Docker setup
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
    };
    enableOnBoot = true;
    #daemon.settings = {
    #  log-opts = {
    #    max-size = "10m";
    #  };
    #};
  };

  # Virt-Manager Config
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
  networking.firewall.checkReversePath = "loose";


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
  };

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
