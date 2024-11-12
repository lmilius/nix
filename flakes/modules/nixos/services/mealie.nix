{ local_domain, appdata_path, ... }:
{
  # services.mealie = {
  #   enable = true;
  #   package = pkgs.unstable.mealie;
  #   listenAddress = "127.0.0.1";
  #   port = 9000;
  #   settings = {
  #     ALLOW_SIGNUP = "false";
  #     TZ = "America/Chicago";
  #   };
  # };

  virtualisation.oci-containers.containers.mealie = {
    image = "hkotel/mealie:v2.2.0";
    environment = {
      DB_TYPE = "sqlite";
      ALLOW_SIGNUP = "false";
      BASE_URL = "https://mealie.${local_domain}";
    };
    hostname = "speedtest.${local_domain}";
    volumes = [
      "${appdata_path}/mealie/data:/app/data"
    ];
    ports = [
      "127.0.0.1:9000:9000"
    ];
  };
}