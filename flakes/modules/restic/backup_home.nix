{ config, pkgs, home_dir, hostname, repo_file, password_file, ... }:
let
  # home_dir = config.users.users.lmilius.home;
  # hostname = "t480s";
in
{
  users.users.restic = {
    isNormalUser = true;
  };

  security.wrappers.restic = {
    source = "${pkgs.restic.out}/bin/restic";
    owner = "restic";
    group = "users";
    permissions = "u=rwx,g=,o=";
    capabilities = "cap_dac_read_search=+ep";
  };

  age.secrets = {
    "restic/repo".file = repo_file;
    "restic/password".file = password_file;
  };

  services.restic.backups = {
    daily = {
      initialize = true;
      user = "restic";

      repositoryFile = config.age.secrets."restic/repo".path;
      passwordFile = config.age.secrets."restic/password".path;

      paths = [
        "${home_dir}"
      ];

      exclude = [
        "${home_dir}/.local/share/Steam"
        "${home_dir}/workspace"
      ];

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
      ];
    };
  };
}