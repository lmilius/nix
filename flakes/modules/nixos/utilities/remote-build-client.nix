{ lib, config, pkgs, ... }:
let
  cfg = config.nix-remote-build;
in
{
  options.nix-remote-build = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Nix remote build client configuration";
    };
    builder = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Builder address (e.g., nixbuilder@10.10.200.93)";
    };
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      builders = lib.mkIf (cfg.builder != "") [
        "${cfg.builder} x86_64-linux - - 8 1 kvm"
        "${cfg.builder} aarch64-linux - - 8 1 kvm"
      ];
      builders-use-substitutes = true;
    };
  };
}
