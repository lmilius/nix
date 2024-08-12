# { config, lib, pkgs, cloudflare_creds_file, domain_file, postgres_file, ... }: 
# let 
#   domain_name = builtins.readFile(config.age.secrets."nextcloud/domain_name".path);
# in
# {
  
#   age.secrets = {
#     "nextcloud/cloudflare".file = cloudflare_creds_file;
#     "nextcloud/domain_name".file = domain_file;
#     "nextcloud/postgres".file = postgres_file;
#   };
  
#   # Based on https://carjorvaz.com/posts/the-holy-grail-nextcloud-setup-made-easy-by-nixos/
#   security.acme = {
#     acceptTerms = true;
#     defaults = {
#       email = "lmilius12+acme@gmail.com";
#       dnsProvider = "cloudflare";
#       # location of your CLOUDFLARE_DNS_API_TOKEN=[value]
#       # https://www.freedesktop.org/software/systemd/man/latest/systemd.exec.html#EnvironmentFile=
#       environmentFile = config.age.secrets."nextcloud/cloudflare".path;
#     };
#   };
#   services = {
#     nginx.virtualHosts = {
#       domain_name = {
#         forceSSL = true;
#         enableACME = true;
#         # Use DNS Challenege.
#         acmeRoot = null;
#       };
#     };
#     # 
#     nextcloud = {
#       enable = true;
#       hostName = domain_name;
#       # Need to manually increment with every major upgrade.
#       package = pkgs.nextcloud28;
#       # Let NixOS install and configure the database automatically.
#       database.createLocally = true;
#       # Let NixOS install and configure Redis caching automatically.
#       configureRedis = true;
#       # Increase the maximum file upload size.
#       maxUploadSize = "16G";
#       https = true;
#       autoUpdateApps.enable = true;
#       extraAppsEnable = true;
#       extraApps = with config.services.nextcloud.package.packages.apps; {
#         # List of apps we want to install and are already packaged in
#         # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json
#         inherit calendar contacts notes onlyoffice tasks cookbook qownnotesapi;
#         # Custom app example.
#         # socialsharing_telegram = pkgs.fetchNextcloudApp rec {
#         #   url =
#         #     "https://github.com/nextcloud-releases/socialsharing/releases/download/v3.0.1/socialsharing_telegram-v3.0.1.tar.gz";
#         #   license = "agpl3";
#         #   sha256 = "sha256-8XyOslMmzxmX2QsVzYzIJKNw6rVWJ7uDhU1jaKJ0Q8k=";
#         # };
#       };
#       settings = {
#         overwriteProtocol = "https";
#         default_phone_region = "US";
#       };
#       config = {
#         dbtype = "pgsql";
#         adminuser = "admin";
#         adminpassFile = config.age.secrets."nextcloud/postgres".path;
#       };
#       # Suggested by Nextcloud's health check.
#       phpOptions."opcache.interned_strings_buffer" = "16";
#     };
#     # Nightly database backups.
#     postgresqlBackup = {
#       enable = true;
#       startAt = "*-*-* 01:15:00";
#     };
#   };
# }