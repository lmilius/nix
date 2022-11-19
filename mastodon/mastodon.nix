{ lib, config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mastodon
    # agenix
  ];

  security.acme.acceptTerms = true;

  services.mastodon = {
    enable = true;
    trustedProxy = "10.10.200.90";
    smtp = {
      user = "lmiliusnas@gmail.com";
      passwordFile = "/home/administrator/smtppass.txt";
      port = 587;
      host = "smtp.gmail.com";
      authenticate = true;
      fromAddress = "lmiliusnas@gmail.com";
    };
    localDomain = "social.lukemilius.com";
    # localDomain = "localhost";
    enableUnixSocket = true;
    # elasticsearch.host = "127.0.0.1";
    configureNginx = false;

  };

  # security.acme.defaults.email = "lmilius12@gmail.com";

}
