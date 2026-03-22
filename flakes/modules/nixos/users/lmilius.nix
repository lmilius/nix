{ ... }:
let
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF lmilius@x1carbon"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIGxP4uuwDHt55l/TjdJNnS+legL8oUgk/3FFtev/NBvsAAAABHNzaDo= Yubikey Personal SSH Key"
  ];
in
{
  users.users.lmilius = {
    isNormalUser = true;
    description = "Luke Milius";
    extraGroups = [
      "wheel"
      "docker"
      "libvirtd"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = sshKeys;
  };
}
