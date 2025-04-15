# nix
Nix related configuration

# Flake Configs

This contains configuration for hosts/users that are using flakes to configure nixos and home-manager to manage user profiles.

## Update Flake

`nix flake update`

## Build OS configuration

`sudo nixos-rebuild switch --flake .`

## Build home-manager configuration

`home-manager switch --flake .`

## NixOS Flake Inspiration Repositories

- https://github.com/reckenrode/nixos-configs/blob/main/README.md
- https://github.com/cjlarose/nixos-dev-env/

## Update age files

```bash
cd flakes/secrets
nix run github:ryantm/agenix -- -e restic_repo.age -i ~/.ssh/id_ed25519
```

or, if agenix is installed:

```bash
agenix -e restic_repo.age
```

## New System Setup

```bash
export hostname=<hostname here>
nix-shell -p git
git clone https://github.com/lmilius/nix.git /tmp/nix
sudo nix --extra-experimental-features 'flakes nix-command' run github:nix-community/disko -- --mode destroy,format,mount "/tmp/nix/flakes/hosts/$hostname/disko-config.nix"
sudo nixos-install --root /mnt --flake "/tmp/nix/flakes#$hostname"
```