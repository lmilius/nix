{
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
  syncthing_server = import ./services/syncthing_server.nix;
  mealie = import ./services/mealie.nix;
  paperless = import ./services/paperless.nix;
  py2mqtt = import ./services/py2mqtt.nix;
  shared_server = import ./utilities/shared-server.nix;
  remote_build_client = import ./utilities/remote-build-client.nix;
  remote_build_server = import ./utilities/remote-build-server.nix;
  lmilius_user = import ./users/lmilius.nix;
  deployer_user = import ./users/deployer.nix;
}
