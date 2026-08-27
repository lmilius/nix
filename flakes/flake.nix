{
  description = "Nix Config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-bitcoin = {
      url = "github:fort-nix/nix-bitcoin/release";
    };

    openclaw = {
      url = "github:Lillecarl/openclaw-nix";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixos-hardware,
    disko,
    vscode-server,
    # nixos-06cb-009a-fingerprint-sensor,
    agenix,
    nix-bitcoin,
    openclaw,
    ...
  } @ inputs: let
    inherit (self) outputs;
    systems = [
      "x86_64-linux"
    ];
    # This is a function that generates an attribute by calling a function you
    # pass to it, with each system as an argument
    forAllSystems = nixpkgs.lib.genAttrs systems;

    nixosSystem = hostname:
      nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs hostname;};
        modules = [
          # > Our main nixos configuration file <
          { networking.hostName = "${hostname}"; }
          ./hosts/${hostname}
          ./hosts/common/nixos-common.nix
          ./hosts/common/common-packages.nix
        ];
      };
  in {
    overlays = import ./overlays {inherit inputs;};
    nixosModules = import ./modules/nixos;

    nixosConfigurations = {
      t480s = nixosSystem "t480s";
      util = nixosSystem "util";
      parent-util = nixosSystem "parent-util";
      nas = nixosSystem "nas";
      nvr = nixosSystem "nvr";
      nixbook = nixosSystem "nixbook";
      game-pc = nixosSystem "game-pc";
    };
  };
}
