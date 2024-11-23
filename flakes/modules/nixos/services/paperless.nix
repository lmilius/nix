{ admin_pass_file, appdata_path, domain, ... }: 
{
  services.paperless = {
    enable = true;
    package = pkgs.unstable.paperless-ngx;
    port = 28981;
    passwordFile = admin_pass_file;
    mediaDir = "${appdata_path}/paperless/media";
    dataDir = "${appdata_path}/paperless/data";
    consumptionDirIsPublic = true;
    consumeDir = "${appdata_path}/paperless/consume";
    settings = {
      PAPERLESS_CONSUMER_IGNORE_PATTERN = [
        ".DS_STORE/*"
        "desktop.ini"
      ];
      PAPERLESS_URL = "https://paperless.${domain}";
    };
  };

  services.nginx.virtualHosts."paperless.${domain}" = {
    enableACME = false;
    useACMEHost = domain;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:${config.services.paperless.port}";
      proxyWebsockets = true;
    };
  };
}