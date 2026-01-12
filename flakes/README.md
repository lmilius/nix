# nix
Nix related configuration

# Flake Configs

This contains configuration for hosts/users that are using flakes to configure nixos and home-manager to manage user profiles.

## Update Flake

`nix flake update`

## Build OS configuration

`sudo nixos-rebuild switch --flake .`

### Or using nh:

`nh os switch`
or
`nh os boot`

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

### Rekey all secrets with host keys:

```bash
agenix -r
```

## New System Setup

```bash
export hostname=<hostname here>
git clone https://github.com/lmilius/nix.git /tmp/nix
sudo nix --extra-experimental-features 'flakes nix-command' run github:nix-community/disko -- --mode destroy,format,mount "/tmp/nix/flakes/hosts/$hostname/disko-config.nix"
sudo nixos-install --root /mnt --flake "/tmp/nix/flakes#$hostname"
```

## Restoration from Backups

### Borg local restoration (full)

To not have to paste the passphrase each time, set the environment variable: `BORG_PASSPHRASE` to the passphrase.

First, list the snapshots/versions available. The first column will be the name to use in the extract command

```bash
borg list <repo>
```

The extract command will restore the repo's contents to the current working directory. NOTE: the `--strip-components` value must match the desired leading path elements to be restored. For example, with a value of 2, a path of `tank2/appdata/service/data` would become just `service/data` in the extracted directory. 

When ready to restore, remove the `--dry-run` flag.

```bash
cd <target directory of restored data>
borg extract --dry-run --list --strip-components 2 <repo>::<snapshot/version>
```