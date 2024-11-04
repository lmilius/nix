# Example using a lot of secrets: https://github.com/chvp/nixos-config/blob/main/secrets.nix

let
  lmilius = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF"
  ];
  t480s = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmyQ2xYPwVp2gJmen/xrvBZo9nNH+2ryY/FVRLmS8r6";
  x1carbon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhSoYcDeYh2F+L4cRIA51dNi+1jJ8kwysslmFeq8k+N";
  nixosHosts = [
    t480s
    x1carbon
  ];
  users = lmilius;
in
{
  "restic_password_x1carbon_home.age".publicKeys = x1carbon ++ users;
  "restic_repo_x1carbon_home.age".publicKeys = x1carbon ++ users;
  "restic_password_t480s_home.age".publicKeys = t480s ++ users;
  "restic_repo_t480s_home.age".publicKeys = t480s ++ users;
  # "cloudflare_dns_credentials.age".publicKeys = [ ssh_key ];
  # "nextcloud_postgres_admin.age".publicKeys = [ ssh_key ];
  # "nextcloud_domain_name.age".publicKeys = [ ssh_key ];
}