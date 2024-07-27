{ config, agenix, ... }:
let
  home_dir = config.users.users.lmilius.home;
  hostname = "t480s";
in
{
  age.secrets = {
    "restic/repo".file = "../../secrets/restic/repo.age";
    "restic/password".file = "../../secrets/restic/password.age";
  };

  services.restic.backups = {
    daily = {
      initialize = true;

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