{

  description = "My first flake!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url   = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.darwin.follows = "";
      inputs.home-manager.follows = "";
    };
  };

  outputs = { self, nixpkgs, unstable, home-manager, agenix, ... }:
  let
    overlay = final: prev: let
      unstablePkgs = import unstable { inherit (prev) system; config.allowUnfree = true; };
    in {
      unstable = unstablePkgs;
    };

    # lib = nixpkgs.lib;
    # system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.x86_64-linux;

    # Ref: https://github.com/jakubgs/nixos-config/tree/master
    # Overlays-module makes "pkgs.unstable" available in configuration.nix
    overlayModule = ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay ]; });
    # To generate host configurations for all hosts.
    hostnames = builtins.attrNames (builtins.readDir ./hosts);
    # To generate user configurations for home-manager.
    users = builtins.attrNames (builtins.readDir ./users);
    # For future, not all hosts may be x86_64
    systemForHost = hostname: 
      if builtins.elem hostname [] then "aarch64-linux"
      else "x86_64-linux";
  in {
    nixosConfigurations = builtins.listToAttrs (builtins.map (host: {
      name = host;
      value = nixpkgs.lib.nixosSystem {
        system = systemForHost host;
        specialArgs.channels = { inherit nixpkgs unstable; };
        modules = [
          overlayModule
          agenix.nixosModules.default
          ./hosts/${host}/configuration.nix
        ];
      };
    }) hostnames);

    # nixosConfigurations = {
    #   x1carbon = nixpkgs.lib.nixosSystem {
    #     system = "x86_64-linux";
    #     specialArgs.channels = { inherit nixpkgs unstable; };
    #     modules = [
    #       overlayModule
    #       agenix.nixosModules.default
    #       ./hosts/x1carbon/configuration.nix
    #     ];
    #   };
    # };


    homeConfigurations = builtins.listToAttrs (builtins.map (user: {
      name = user;
      value = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          overlayModule
          ./users/${user}/home.nix
        ];
      };
    }) users);

    # homeConfigurations = {
    #   lmilius = home-manager.lib.homeManagerConfiguration {
    #     inherit pkgs;
    #     modules = [ ./home.nix ];
    #   };
    # };
  };

}
