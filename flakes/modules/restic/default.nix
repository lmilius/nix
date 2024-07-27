{ config, agenix, ... }:
let
  home_dir = config.users.users.lmilius.home;
  hostname = "t480s";
in
{
  age.secrets = {
    "${hostname}/restic/repo".file = "../../secrets/${hostname}/restic/repo.age";
    "${hostname}/restic/password".file = "../../secrets/${hostname}/restic/password.age";
  };

  services.restic.backups = {
    daily = {
      initialize = true;

      repositoryFile = config.age.secrets."${hostname}/restic/repo".path;
      passwordFile = config.age.secrets."${hostname}/restic/password".path;

      paths = [
        "${home_dir}"
      ];

      exclude = [
        "${home_dir}/.local/share/Steam"
      ];

      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
      ];
    };
  };
}