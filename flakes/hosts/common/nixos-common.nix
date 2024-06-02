{ pkgs, unstablePkgs, lib, inputs, ... }:
let
  inherit (inputs) nixpkgs nixpkgs-unstable;
in
{
  time.timeZone = "America/Chicago";
  

  nix = {
    settings = {
        experimental-features = [ "nix-command" "flakes" ];
        warn-dirty = false;
        
        # Definte trusted users
        trusted-users = [
          "root"
          "@wheel"
          "lmilius"
        ];

        # Use local nix cache
        substituters = [ 
          "http://10.10.200.8" 
          # "http://100.69.216.71/" 
          "" 
        ];
    };
    # Automate garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    # "electron-24.8.6"
  ];

  # environment.systemPackages = with pkgs; [
  #   # intel-gpu-tools
  #   # libva-utils
  #   # intel-media-driver
  #   # jellyfin-ffmpeg
  #   # hddtemp
  #   # synergy
  # ];

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
    target-rebuild = "sudo nixos-rebuild -I nixos-config=./configuration.nix --use-remote-sudo --target-host";
    trip = "sudo /run/current-system/sw/bin/trip";
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