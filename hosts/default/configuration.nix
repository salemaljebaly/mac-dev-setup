{
  config,
  pkgs,
  username,
  ...
}:

{
  # Hostname configuration
  networking.computerName = "MacBook Pro";
  networking.hostName = "macbook-pro";
  networking.localHostName = "macbook-pro";

  # User configuration
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };
}
