{ pkgs, ...}:
let

in
{
  environment.systemPackages = with pkgs; [
    ansible
    python311Packages.ansible
    python311Packages.dnspython
    sshpass
  ];
}