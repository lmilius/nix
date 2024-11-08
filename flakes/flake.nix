{
  description = "Nix Config";

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

    agenix = {
      url   = "github:ryantm/agenix";
      # inputs.nixpkgs.follows = "nixpkgs";
      # inputs.darwin.follows = "";
      # inputs.home-manager.follows = "";
    };

    compose2nix = {
      url = "github:aksiksi/compose2nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
    compose2nix,
    ...
  } @ inputs: let
    inherit (self) outputs;
    # Supported systems for your flake packages, shell, etc.
    systems = [
      # "aarch64-linux"
      # "i686-linux"
      "x86_64-linux"
      # "aarch64-darwin"
      # "x86_64-darwin"
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
    # Your custom packages
    # Accessible through 'nix build', 'nix shell', etc
    packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
    # Formatter for your nix files, available through 'nix fmt'
    # Other options beside 'alejandra' include 'nixpkgs-fmt'
    # formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.alejandra);

    # Your custom packages and modifications, exported as overlays
    overlays = import ./overlays {inherit inputs;};
    # Reusable nixos modules you might want to export
    # These are usually stuff you would upstream into nixpkgs
    nixosModules = import ./modules/nixos;
    # Reusable home-manager modules you might want to export
    # These are usually stuff you would upstream into home-manager
    # homeManagerModules = import ./modules/home-manager;

    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      # FIXME replace with your hostname
      t480s = nixosSystem "t480s";
      nix-server = nixosSystem "nix-server";
      util = nixosSystem "util";
      # t480s = nixpkgs.lib.nixosSystem {
      #   specialArgs = {inherit inputs outputs;};
      #   modules = [
      #     # > Our main nixos configuration file <
      #     { networking.hostName = "t480s"; }
      #     ./hosts/t480s
      #     ./hosts/common/nixos-common.nix
      #     ./hosts/common/common-packages.nix
      #   ];
      # };
    };
  };
}
