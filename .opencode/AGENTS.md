name: nix
description: NixOS flake configuration repository for managing multiple hosts
language: nix

commands:
  build: sudo nixos-rebuild switch --flake .
  build-dry: sudo nixos-rebuild dry-activate --flake .
  home-switch: home-manager switch --flake .
  update-flake: nix flake update
  format: nix fmt
  format-check: nix fmt -- --check
  lint: nix flake check
  test: sudo nixos-rebuild test --flake .
  show-config: nix eval .#nixosConfigurations.<host>.config.system.build.toplevel --json

directories:
  configs: flakes/
  hosts: flakes/hosts/
  modules: flakes/modules/
  secrets: flakes/secrets/
  users: flakes/users/
  shared-modules: flakes/modules/nixos/

ignore:
  - flakes/flake.lock
  - "**/*.age"
  - "**/result*"

module-types:
  gui: flakes/modules/nixos/gui/
  services: flakes/modules/nixos/services/
  utilities: flakes/modules/nixos/utilities/
  users: flakes/modules/nixos/users/

notes:
  - Secrets in flakes/secrets/ are age-encrypted, do not modify directly
  - Each host has its own directory under flakes/hosts/
  - Common configuration is in flakes/hosts/common/
  - Shared user modules: lmilius_user, deployer_user
  - Shared server module: shared_server (libvirtd, virt-manager, nix-ld, fstrim, openssh)
  - NixOS modules are registered in flakes/modules/nixos/default.nix
  - Build commands require sudo for system-level changes
  - Use `nh os switch` as alternative to nixos-rebuild
  - Home manager config: flakes/users/lmilius/home.nix
