# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ inputs, outputs, lib, config, pkgs, hostname, ... }:

{
  imports =
    [ 
      inputs.disko.nixosModules.disko
      (import ./disko-config.nix {
        disks = [ "/dev/sda" ];
      })
      ./hardware-configuration.nix

      inputs.home-manager.nixosModules.home-manager
      outputs.nixosModules.docker_daemon
      outputs.nixosModules.syncthing
      outputs.nixosModules.systemd_oom
      inputs.agenix.nixosModules.default
    ];

  # Use local nix cache
  nix.settings.substituters = [ ];

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
  systemd.services.NetworkManager-wait-online.enable = false;
  # networking.networkmanager.dns = "systemd-resolved";
  # networking = {
  #   usePredictableInterfaceNames = false;
  #   interfaces.enp1s0.ipv4.addresses = [{
  #     address = "192.168.88.5";
  #     prefixLength = 24;
  #   }];
  #   defaultGateway = "192.168.88.1";
  #   nameservers = [ "192.168.88.1" "8.8.8.8" ];
  # };

  # Set your time zone.
  # time.timeZone = "America/Chicago";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
    "net.ipv4.conf.all.forwarding" = 1;
  };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  # services.xserver.videoDrivers = [ "amdgpu" ];

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable the XFCE4 Desktop Environment.
  # services.xserver.desktopManager.xfce.enable = true;
  # services.xserver.displayManager.lightdm.enable = true;

  # services.xserver = {
    # enable = true;
    # layout = "us";
    # videoDrivers = [ "amdgpu" ];

    # Enable the XFCE4 Desktop Environment
    # displayManager.lightdm.enable = true;
    # desktopManager.xfce.enable = true;
  # };


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
    ];
    initialHashedPassword = "$y$j9T$pIpVsIB6vvgo3wh6aRTbT.$lSwdItSLTZcEEg/KxCWR1FZZUDduWkYgrc4nZ/zusI2";
    #packages = with pkgs; [
    #  firefox
    #  tree
    #];
  };

  # # Docker setup
  # virtualisation.docker = {
  #   enable = true;
  #   autoPrune = {
  #     enable = true;
  #   };
  #   enableOnBoot = true;
  # };

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      speedtest = {
        image = "linuxserver/librespeed:latest";
        environment = {
          MODE = "standalone";
        };
        ports = [
          "8080:80"
        ];
      };
      # Omada uses the following ports: 8088/8043 for the webUI, 
      omada = {
        image = "mbentley/omada-controller:latest";
        environment = {
          TZ = "America/Chicago";
        };
        extraOptions = [
          "--network=host"
        ];
        volumes = [
          "/home/lmilius/omada/data:/opt/tplink/EAPController/data"
          "/home/lmilius/omada/logs:/opt/tplink/EAPController/logs"
          "/home/lmilius/omada/work:/opt/tplink/EAPController/work"
        ];
      };
    };
  };

  # Podman support
  # virtualisation = {
  #  podman = {
  #    enable = true;
  
  #    # Create a `docker` alias for podman, to use it as a drop-in replacement
  #    dockerCompat = true;
  
  #    # Required for containers under podman-compose to be able to talk to each other.
  #    defaultNetwork.settings.dns_enabled = true;
  #    # For Nixos version > 22.11
  #    #defaultNetwork.settings = {
  #    #  dns_enabled = true;
  #    #};
  #  };
  # };

  # Virtualization support
  virtualisation.libvirtd = {
    enable = true;
  };
  programs.virt-manager.enable = true;

  # # Syncthing
  # services.syncthing = {
  #   enable = true;
  #   user = "lmilius";
  #   dataDir = "/home/lmilius/syncthing";
  #   configDir = "/home/lmilius/Documents/.config/syncthing";
  #   guiAddress = "0.0.0.0:8384";
  #   settings = {
  #     devices = {
  #       Server = {
  #         addresses = [ 
  #           "tcp://sync.miliushome.com:22000"
  #           "tcp://10.10.200.80:22000"
  #         ];
  #         id = "QK47CRP-FPGZLTG-ZXSVEPB-K2W7VDQ-3TMGB6M-OCJGDYI-FHJFWG5-SDMG6QI";
  #       };
  #       x1carbon = {
  #         id = "WB74NAR-CQ6B6YL-SLXZGKT-AMWFL7O-5YA4XSF-756NFZP-ZSVGBRD-IQRZRQL";
  #       };
  #     };
  #     folders = {
  #       "/home/lmilius/syncthing/nix-flake-config" = {
  #         id = "vccxz-vvrns";
  #         devices = [
  #           "Server"
  #           "x1carbon"
  #           # "parent-util"
  #         ];
  #       };
  #       "/home/lmilius/syncthing/nix-config" = {
  #         id = "lmyem-knmpz";
  #         devices = [
  #           "Server"
  #           "x1carbon"
  #           "t480s"
  #           # "parent-util"
  #         ];
  #       };
  #     };
  #   };
  # };

  # QEMU UEFI support
  # environment = {
  #   (pkgs.writeShellScriptBin "qemu-system-x86_64-uefi" 
  #     qemu-system-x86_64 \
  #       -bios ${pkgs.OVMF.fd}/FV/OVMF.fd \
  #       "$@"
  #   )
  # };

  # Enable tailscale service
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    openFirewall = true;
    package = pkgs.unstable.tailscale;
    extraUpFlags = [
      "--accept-routes"
      "--accept-dns"
      "--advertise-exit-node"
      "--advertise-routes 192.168.88.0/24"
      "--ssh"
      # "--exit-node gateway"
      # "--exit-node-allow-lan-access"
    ];
  };
  # networking.firewall.checkReversePath = "loose";
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  networking.localCommands = ''
    ip rule add to 192.168.88.0/24 priority 2500 lookup main
  '';

  # programs.bash.shellAliases = {
  #   l = "ls -alh";
  #   ll = "ls -l";
  #   ls = "ls --color=tty";
  #   dcp = "docker-compose ";
  #   dlog = "docker logs -f ";
  #   dtop = "docker run --name ctop -it --rm -v /var/run/docker.sock:/var/run/docker.sock quay.io/vektorlab/ctop ";
  #   nix-listgens = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
  #   nix-gc5d = "sudo nix-collect-garbage -d --delete-older-than 5d";
  #   nix-optimize = "sudo nix-store --optimize";
  #   rebuild = "sudo nixos-rebuild";
  # };

  # Allows vscode remote ssh server to work when this machine is the server
  programs.nix-ld.enable = true;

  # nix cli helper
  # https://github.com/viperML/nh
  # programs.nh.flake = "/home/lmilius/syncthing/nix-flake-config";

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
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
  system.stateVersion = "23.05"; # Did you read the comment?

}

