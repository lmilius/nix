{ trusted_domains, ... }:
{
  services.nextcloud = {
    enable = true;
    hostName = "localhost";
    database.createLocally = true;
    config = {
      dbtype = "pgsql";
      adminpassFile = "/etc/nextcloud-admin-pass";
    };
    settings = {
      trusted_domains = trusted_domains;
    };
  };
}