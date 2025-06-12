# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  lib,
  config,
  pkgs,
  ...
}: 
let
  myAliases = {
    ll = "ls -alF";
    la = "ls -A";
    l = "ls -CF";
    ".." = "cd ..";
  };
in
{
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    # overlays = [
    #   # Add overlays your own flake exports (from overlays and pkgs dir):
    #   outputs.overlays.additions
    #   outputs.overlays.modifications
    #   outputs.overlays.unstable-packages

    #   # You can also add overlays exported from other flakes:
    #   # neovim-nightly-overlay.overlays.default

    #   # Or define it inline, for example:
    #   # (final: prev: {
    #   #   hi = final.hello.overrideAttrs (oldAttrs: {
    #   #     patches = [ ./change-hello-to-hi.patch ];
    #   #   });
    #   # })
    # ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  home = {
    username = "lmilius";
    homeDirectory = "/home/lmilius";
    packages = with pkgs; [
      # yubikey-manager
      # yubikey-personalization
    ];
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
    ".bashrc".source = ./bashrc;
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/lmilius/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Enable home-manager and git
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.git = {
    enable = true;
    userEmail = "lmilius12@gmail.com";
    userName = "Luke Milius";
    diff-so-fancy.enable = true;
    extraConfig = {
      init = {
        defaultBranch = "main";
      };
    };
  };
  programs.home-manager.enable = true;
  programs.ssh = {
    enable = true;
    serverAliveInterval = 60;
    serverAliveCountMax = 240;
    extraConfig = ''
StrictHostKeyChecking no
    '';
    matchBlocks = {
      "util" = {
        hostname = "util.milius.home";
        user = "lmilius";
      };
      "parent-util" = {
        hostname = "192.168.88.5";
        user = "lmilius";
      };
      "nas" = {
        hostname = "10.10.200.90";
        user = "lmilius";
      };
      "nix-server" = {
        hostname = "10.10.200.91";
        user = "lmilius";
      };
      "pve3" = {
        hostname = "pve3";
        user = "root";
      };
      "ha" = {
        hostname = "homeassistant";
        user = "root";
        port = 22222;
      };
      "influxdb" = {
        hostname = "10.10.200.99";
        user = "root";
      };
      "pi" = {
        hostname = "raspberrypi";
        user = "admin";
      };
      "gateway" = {
        hostname = "gateway.miliusfam.com";
        user = "root";
      };
      "storj" = {
        hostname = "storj";
        user = "root";
      };
      "ctcrouter" = {
        hostname = "192.168.8.1";
        user = "root";
        extraOptions = {
          HostkeyAlgorithms = "+ssh-rsa";
          PubkeyAcceptedAlgorithms = "+ssh-rsa";
        };
      };
      "ctcserver" = {
        hostname = "192.168.8.10";
        user = "lmilius";
      };
    };
  }; 
  programs.tmux = {
    enable = true;
    historyLimit = 10000;
  };
  programs.zsh = {
    enable = true;
    shellAliases = myAliases;
    enableCompletion = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.11";
}
