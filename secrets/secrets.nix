let
  mastodon = "";
in {
  "mastodonDBPassword.age".publicKeys = [ mastodon ];
  "mastodonSMTPPassword.age".publicKeys = [ mastodon ];
}