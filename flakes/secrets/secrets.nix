let
  ssh_key = (builtins.readFile ~/.ssh/id_ed25519.pub);
in
{
  "t480s/restic/password.age".publicKeys = [ ssh_key ];
  "t480s/restic/repo.age".publicKeys = [ ssh_key ];
}