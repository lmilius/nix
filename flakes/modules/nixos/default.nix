# Add your reusable NixOS modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{
  # List your module files here
  # my-module = import ./my-module.nix;
  gnome = import ./gui/gnome.nix;
  plasma = import ./gui/plasma.nix;
  plasma6 = import ./gui/plasma6.nix;
  xfce = import ./gui/xfce.nix;
  restic_home_backup = import ./restic/backup_home.nix;
  docker_daemon = import ./docker/daemon.nix;
  systemd_oom = import ./utilities/systemd_oom.nix;
  pipewire = import ./utilities/pipewire.nix;
  bluetooth = import ./utilities/bluetooth.nix;
  intel_gpu = import ./utilities/intel_gpu.nix;
  nextcloud = import ./services/nextcloud.nix;
  cockpit = import ./services/cockpit.nix;
  nix_cache = import ./services/nix_cache.nix;
  ansible = import ./utilities/ansible.nix;
  syncthing = import ./services/syncthing.nix;
  mealie = import ./services/mealie.nix;
  #TODO
  # Samba
  # docker containers?
}
