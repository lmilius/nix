let
  ssh_key = (builtins.readFile ~/.ssh/id_ed25519.pub);
in
{
  "restic/password.age".publicKeys = [ ssh_key ];
  "restic/repo.age".publicKeys = [ ssh_key ];
}