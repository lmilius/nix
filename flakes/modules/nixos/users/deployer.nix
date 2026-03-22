{ ... }:
let
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJr6u53xcfqXT8h42hTG2S7QEDOavh4AQmqfRVAgOvK6 lmilius@util"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF lmilius@x1carbon"
  ];
in
{
  users.groups.deployer = {
    gid = 1100;
  };

  users.users.deployer = {
    isNormalUser = true;
    extraGroups = [
      "deployer"
      "wheel"
      "docker"
      "libvirtd"
    ];
    createHome = true;
    uid = 1100;
    group = "deployer";
    openssh.authorizedKeys.keys = sshKeys;
  };

  security.sudo.extraRules = [
    {
      users = [ "deployer" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
