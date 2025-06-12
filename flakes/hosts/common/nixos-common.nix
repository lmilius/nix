{ inputs, outputs, lib, config, pkgs, ... }:
# let
#   inherit (inputs) nixpkgs nixpkgs-unstable;
# in
{
  time.timeZone = "America/Chicago";

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      permittedInsecurePackages = [
        # "electron-24.8.6"
      ];
    };
  };

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = lib.mkDefault [ "nix-command" "flakes" ];
      warn-dirty = true;
      
      # Definte trusted users
      trusted-users = lib.mkDefault [
        "root"
        "@wheel"
        "lmilius"
      ];
      # Opinionated: disable global registry
      # flake-registry = "";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
      # Use local nix cache
      # Use local nix cache
      substituters = lib.mkDefault [ 
        "http://10.10.200.8" 
        # "http://100.69.216.71/" 
      ];
    };

    # Built-in garbage collection
    gc = {
      automatic = false;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  # environment.systemPackages = with pkgs; [
  #   # intel-gpu-tools
  #   # libva-utils
  #   # intel-media-driver
  #   # jellyfin-ffmpeg
  #   # hddtemp
  #   # synergy
  # ];

  programs.ssh = {
    extraConfig=''
ServerAliveInterval 60
ServerAliveCountMax 240
    '';
  };

  programs.bash.shellAliases = {
    l = "ls -lh";
    ll = "ls -alh";
    ls = "ls --color=tty";
    dcp = "docker-compose ";
    dlog = "docker logs -f ";
    dtop = "ctop";
    nix-listgens = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
    nix-switchgen = "sudo nix-env -p /nix/var/nix/profiles/system --switch-generation";
    nix-gc5d = "sudo nix-collect-garbage -d --delete-older-than 5d";
    nix-optimize = "sudo nix-store --optimize";
    # rebuild = "sudo nixos-rebuild";
    rebuild = "nh os switch --ask";
    rebuild-boot = "nh os boot --ask";
    target-rebuild = "sudo nixos-rebuild -I nixos-config=./configuration.nix --use-remote-sudo --target-host";
    trip = "sudo /run/current-system/sw/bin/trip";
    ".." = "cd ..";
  };

  # nix cli helper
  # https://github.com/viperML/nh
  programs.nh = lib.mkDefault {
    enable = true;
    flake = "/home/lmilius/workspace/nix/flakes";
    clean = {
      enable = true;
      extraArgs = "--keep-since 14d --keep 5";
    };
  };

  security.sudo = {
    enable = true;
    extraRules = [{
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/nh";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/reboot";
          options = [ "NOPASSWD" ];
        }
        {
          command = "/run/current-system/sw/bin/trip";
          options = [ "NOPASSWD" ];
        }
      ];
      groups = [ "wheel" ];
    }];
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
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

  ## pins to stable as unstable updates very often
  # nix.registry.nixpkgs.flake = inputs.nixpkgs;
  # nix.registry = {
  #   n.to = {
  #     type = "path";
  #     path = inputs.nixpkgs;
  #   };
  #   u.to = {
  #     type = "path";
  #     path = inputs.nixpkgs-unstable;
  #   };
  # };
}