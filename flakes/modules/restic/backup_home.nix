{ config, home_dir, hostname, repo_file, password_file, ... }:
let
  # home_dir = config.users.users.lmilius.home;
  # hostname = "t480s";
in
{
  age.secrets = {
    "restic/repo".file = ../../secrets/restic_repo.age;
    "restic/password".file = ../../secrets/restic_password.age;
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