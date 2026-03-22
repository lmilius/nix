{ lib, config, pkgs, ... }:
let
  cfg = config.lmilius-remote-build-client;
in
{
  options.lmilius-remote-build-client = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Nix remote build client configuration";
    };
    builderHost = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Builder hostname or IP address";
    };
    sshUser = lib.mkOption {
      type = lib.types.str;
      default = "nixbuilder";
      description = "SSH user for builder";
    };
    maxJobs = lib.mkOption {
      type = lib.types.int;
      default = 8;
      description = "Maximum jobs to run on builder";
    };
    speedFactor = lib.mkOption {
      type = lib.types.int;
      default = 2;
      description = "Speed factor relative to local machine";
    };
  };

  config = lib.mkIf cfg.enable {
    nix = {
      distributedBuilds = true;
      settings.builders-use-substitutes = true;
    };

    nix.buildMachines = lib.mkIf (cfg.builderHost != "") [
      {
        hostName = cfg.builderHost;
        sshUser = cfg.sshUser;
        system = "x86_64-linux";
        protocol = "ssh-ng";
        maxJobs = cfg.maxJobs;
        speedFactor = cfg.speedFactor;
      }
    ];
  };
}
