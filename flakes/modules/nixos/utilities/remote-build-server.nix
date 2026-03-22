{ lib, config, pkgs, ... }:
let
  cfg = config.lmilius-remote-build-server;
in
{
  options.lmilius-remote-build-server = {
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
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      trusted-users = [ "nixbuilder" "@wheel" ];
    };

    users.users.nixbuilder = {
      isNormalUser = true;
      description = "Nix Remote Builder";
      extraGroups = [ "nixbld" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF lmilius@x1carbon"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHFS37jVQ7sp3sFLwJQvttR9x0i8ZO4drypjBBjXCNii nas"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKqqO9aLsBuZBE2Q1UkjpBQlAqWOuB5iGTOD2TewW0Lq parent-util"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBYW1f/8TDDBbFd5AnPYCok5sYGJCRNkMyeR38Gs4Q1+ util"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmyQ2xYPwVp2gJmen/xrvBZo9nNH+2ryY/FVRLmS8r6 t480s"
      ];
    };

    users.groups.nixbld = {};

    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ cfg.sshPort ];
    };
  };
}
