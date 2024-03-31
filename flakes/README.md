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