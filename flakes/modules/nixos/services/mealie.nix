{ pkgs, ... }:
{
  services.mealie = {
    enable = true;
    package = pkgs.unstable.mealie;
    listenAddress = "127.0.0.1";
    port = "9000";
    settings = {
      ALLOW_SIGNUP = "false";
    };
  };
}