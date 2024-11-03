{ config, pkgs, home_dir, hostname, repo_file, password_file, ... }:
let

in
{
  users.groups.restic = {
    name = "restic";
  };
  users.users.restic = {
    isNormalUser = true;
    group = "restic";
  };

  security.wrappers.restic = {
    source = "${pkgs.restic.out}/bin/restic";
    owner = "root";
    group = "restic";
    permissions = "u=rwx,g=rx,o=";
    capabilities = "cap_dac_read_search=+ep";
  };

  age.secrets = {
    "restic/repo" = {
      file = repo_file;
      owner = "restic";
    };
    "restic/password" = {
      file = password_file;
      owner = "restic";
    };
  };

  services.restic.backups = {
    daily = {
      initialize = true;
      # user = "restic";

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