let
  ssh_key = (builtins.readFile ~/.ssh/id_ed25519.pub);
in
{
  "restic_password.age".publicKeys = [ ssh_key ];
  "restic_repo.age".publicKeys = [ ssh_key ];
  "restic_password_x1carbon_home.age".publicKeys = [ ssh_key ];
  "restic_repo_x1carbon_home.age".publicKeys = [ ssh_key ];
}