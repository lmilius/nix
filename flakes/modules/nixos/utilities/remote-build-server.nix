{ lib, config, pkgs, ... }:
let
  cfg = config.nix-remote-build-server;
in
{
  options.nix-remote-build-server = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Configure this host as a Nix remote build server";
    };
    sshPort = lib.mkOption {
      type = lib.types.port;
      default = 22;
      description = "SSH port for build connections";
    };
    maxJobs = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "Maximum concurrent builds";
    };
    supportedSystems = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "x86_64-linux" ];
      description = "Systems this builder supports";
    };
  };

  config = lib.mkIf cfg.enable {
    # Nix daemon settings for serving builds
    nix.settings = {
      accept-flake-configs = true;
      trusted-users = [ "nixbuilder" "@wheel" ];
    };

    # Build user - used by remote hosts to connect
    users.users.nixbuilder = {
      isNormalUser = true;
      description = "Nix Remote Builder";
      extraGroups = [ "nixbld" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF lmilius@x1carbon"
      ];
    };

    # Create nixbld group if it doesn't exist
    users.groups.nixbld = {};

    # Ensure SSH is configured for remote connections
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    # Firewall - allow SSH from local network
    networking.firewall = {
      enable = true;
      allowedTCPPPorts = [ cfg.sshPort ];
      trustedInterfaces = [ "tailscale0" ];
    };
  };
}
