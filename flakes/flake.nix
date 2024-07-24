{

  description = "My first flake!";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server.url = "github:nix-community/nixos-vscode-server";

    # Enable fingerprint reader
    nixos-06cb-009a-fingerprint-sensor = {
      url = "github:ahbnr/nixos-06cb-009a-fingerprint-sensor";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # agenix = {
    #   url   = "github:ryantm/agenix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.darwin.follows = "";
    #   inputs.home-manager.follows = "";
    # };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, home-manager, disko, vscode-server, nixos-06cb-009a-fingerprint-sensor, nixos-hardware, ... }:
  let
    inputs = { inherit disko home-manager nixpkgs nixpkgs-unstable nixos-06cb-009a-fingerprint-sensor nixos-hardware; };

    # creates correct package sets for specified arch
    genPkgs = system: import nixpkgs { inherit system; config.allowUnfree = true; };
    genUnstablePkgs = system: import nixpkgs-unstable { inherit system; config.allowUnfree = true; };

    nixosSystem = system: hostname: username:
      let
        pkgs = genPkgs system;
        unstablePkgs = genUnstablePkgs system;
      in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit pkgs unstablePkgs hostname nixos-06cb-009a-fingerprint-sensor nixos-hardware;

            # lets us use these things in modules
            customArgs = { inherit system hostname username pkgs unstablePkgs disko nixos-06cb-009a-fingerprint-sensor nixos-hardware; };
          };
          modules = [
            disko.nixosModules.disko
            ./hosts/${hostname}

            vscode-server.nixosModules.default
            home-manager.nixosModules.home-manager {
              # networking.hostname = hostname;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.${username} = { imports = [ ./users/${username}/home.nix ]; };

              home-manager.extraSpecialArgs = { inherit pkgs unstablePkgs; };
            }

            ./hosts/common/nixos-common.nix
            ./hosts/common/common-packages.nix
            nixos-06cb-009a-fingerprint-sensor.nixosModules.open-fprintd
            nixos-06cb-009a-fingerprint-sensor.nixosModules.python-validity
            # nixos-hardware
          ];
        };
  in {
    nixosConfigurations = {
      # clients
      x1carbon = nixosSystem "x86_64-linux" "x1carbon" "lmilius";

      # servers
      new-util = nixosSystem "x86_64-linux" "new-util" "lmilius";
      parent-util = nixosSystem "x86_64-linux" "parent-util" "lmilius";
      nix-cache = nixosSystem "x86_64-linux" "nix-cache" "lmilius";

      # blank ISO + disko
      nixos = nixosSystem "x86_64-linux" "nixos" "lmilius";
    };
  };







  #   overlay = final: prev: let
  #     unstablePkgs = import unstable { inherit (prev) system; config.allowUnfree = true; };
  #   in {
  #     unstable = unstablePkgs;
  #   };

  #   # lib = nixpkgs.lib;
  #   # system = "x86_64-linux";
  #   pkgs = nixpkgs.legacyPackages.x86_64-linux;

  #   # Ref: https://github.com/jakubgs/nixos-config/tree/master
  #   # Overlays-module makes "pkgs.unstable" available in configuration.nix
  #   overlayModule = ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay ]; });
  #   # To generate host configurations for all hosts.
  #   hostnames = builtins.attrNames (builtins.readDir ./hosts);
  #   # To generate user configurations for home-manager.
  #   users = builtins.attrNames (builtins.readDir ./users);
  #   # For future, not all hosts may be x86_64
  #   systemForHost = hostname: 
  #     if builtins.elem hostname [] then "aarch64-linux"
  #     else "x86_64-linux";
  # in {
  #   nixosConfigurations = builtins.listToAttrs (builtins.map (host: {
  #     name = host;
  #     value = nixpkgs.lib.nixosSystem {
  #       system = systemForHost host;
  #       specialArgs.channels = { inherit nixpkgs unstable; };
  #       modules = [
  #         overlayModule
  #         agenix.nixosModules.default
  #         ./hosts/${host}/configuration.nix
  #       ];
  #     };
  #   }) hostnames);

  #   # nixosConfigurations = {
  #   #   x1carbon = nixpkgs.lib.nixosSystem {
  #   #     system = "x86_64-linux";
  #   #     specialArgs.channels = { inherit nixpkgs unstable; };
  #   #     modules = [
  #   #       overlayModule
  #   #       agenix.nixosModules.default
  #   #       ./hosts/x1carbon/configuration.nix
  #   #     ];
  #   #   };
  #   # };


  #   homeConfigurations = builtins.listToAttrs (builtins.map (user: {
  #     name = user;
  #     value = home-manager.lib.homeManagerConfiguration {
  #       inherit pkgs;
  #       modules = [
  #         overlayModule
  #         ./users/${user}/home.nix
  #       ];
  #     };
  #   }) users);

  #   # homeConfigurations = {
  #   #   lmilius = home-manager.lib.homeManagerConfiguration {
  #   #     inherit pkgs;
  #   #     modules = [ ./home.nix ];
  #   #   };
  #   # };
  # };

}
