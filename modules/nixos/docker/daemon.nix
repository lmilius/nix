{ ... }:
{
  # Docker setup
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
    enableOnBoot = true;
    #daemon.settings = {
    #  log-opts = {
    #    max-size = "10m";
    #  };
    #};
  };
}