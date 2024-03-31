{ config, pkgs, ... }:
let
  myAliases = {
    ll = "ls -alF";
    la = "ls -A";
    l = "ls -CF";
    ".." = "cd ..";
  };
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "lmilius";
  home.homeDirectory = "/home/lmilius";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello
    discover
    # unstablePkgs.tailscale-systray
    # direnv
    insomnia
    # unstablePkgs.vscode
    # unstablePkgs.joplin-desktop

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
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

  # programs.bash = {
    # enable = true;
    # shellAliases = myAliases;
    # enableCompletion = true;
    # bashrcExtra = ''
    # # set variable identifying the chroot you work in (used in the prompt below)
    # if [ -z "''${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    #     debian_chroot=$(cat /etc/debian_chroot)
    # fi


    # # set a fancy prompt (non-color, unless we know we "want" color)
    # case "$TERM" in
    #     xterm-color|*-256color) color_prompt=yes;;
    # esac

    # # uncomment for a colored prompt, if the terminal has the capability; turned
    # # off by default to not distract the user: the focus in a terminal window
    # # should be on the output of commands, not on the prompt
    # #force_color_prompt=yes

    # if [ -n "$force_color_prompt" ]; then
    #     if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    #         # We have color support; assume it's compliant with Ecma-48
    #         # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
    #         # a case would tend to support setf rather than setaf.)
    #         color_prompt=yes
    #     else
    #         color_prompt=
    #     fi
    # fi

    # if [ "$color_prompt" = yes ]; then
    #     PS1="''${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "
    # else
    #     PS1="''${debian_chroot:+($debian_chroot)}\u@\h:\w\$ "
    # fi

    # unset color_prompt force_color_prompt
    # '';
  # };

  home.file.".bashrc".source = ./bashrc;

  programs.zsh = {
    enable = true;
    shellAliases = myAliases;
    enableCompletion = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  
  # programs.vscode = {
  #   enable = true;
  #   extensions = with pkgs.vscode-extensions; [
  #     mkhl.direnv
  #     njpwerner.autodocstring
  #     ms-vscode.cpptools
  #     ms-vscode.cmake-tools
  #     ms-vscode-remote.remote-ssh
  #     ms-vscode-remote.remote-containers
  #     ms-python.python
  #     ms-python.vscode-pylance
  #     njpwerner.autodocstring
  #     tailscale.vscode-tailscale
  #   ];
  # };

  programs.tmux = {
    enable = true;
    historyLimit = 10000;
  };

  programs.ssh = {
    enable = true;
    extraConfig = ''
    Host *
      StrictHostKeyChecking no
    '';
    matchBlocks = {
      "new-util" = {
        hostname = "new-util.milius.home";
        user = "lmilius";
      };
      "parent-util" = {
        hostname = "192.168.88.5";
        user = "lmilius";
      };
      "util" = {
        hostname = "util.milius.home";
        user = "lmilius";
      };
      "pve1" = {
        hostname = "pve1";
        user = "root";
      };
      "pve2" = {
        hostname = "pve2";
        user = "root";
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
    };
  }; 

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userEmail = "lmilius12@gmail.com";
    userName = "Luke Milius";
    diff-so-fancy.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";
}
