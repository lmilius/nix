# Example using a lot of secrets: https://github.com/chvp/nixos-config/blob/main/secrets.nix

let
  lmilius = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDAtjRZRmD5R38oShBAtJ0XjXdJWtz38Z6Vj6F1l0pYF"
  ];
  t480s = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBmyQ2xYPwVp2gJmen/xrvBZo9nNH+2ryY/FVRLmS8r6";
  x1carbon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIhSoYcDeYh2F+L4cRIA51dNi+1jJ8kwysslmFeq8k+N";
  nix-server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0eXc38UytBOcJFK/Eb6eg/76RyngHyyZluPe2ta6Or";
  util = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIrSax0GGxvb2DLadMqRZxKfllYikCV518icOC8WbZX7";
  parent-util = "";
  nixosHosts = [
    t480s
    x1carbon
    nix-server
    util
  ];
  users = lmilius;
in
{
  "restic_password_x1carbon_home.age".publicKeys = nixosHosts ++ users;
  "restic_repo_x1carbon_home.age".publicKeys = nixosHosts ++ users;
  "restic_password_t480s_home.age".publicKeys = nixosHosts ++ users;
  "restic_repo_t480s_home.age".publicKeys = nixosHosts ++ users;
  "nix-server/traefik_env.age".publicKeys = nixosHosts ++ users;
  "nix-server/traefik_conf.age".publicKeys = nixosHosts ++ users;
  "nix-server/traefik_rules.age".publicKeys = nixosHosts ++ users;
  "nix-server/traefik_conf_toml.age".publicKeys = nixosHosts ++ users;
  "nix-server/traefik_rules_toml.age".publicKeys = nixosHosts ++ users;
  # "cloudflare_dns_credentials.age".publicKeys = [ ssh_key ];
  # "nextcloud_postgres_admin.age".publicKeys = [ ssh_key ];
  # "nextcloud_domain_name.age".publicKeys = [ ssh_key ];
}