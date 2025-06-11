{ username, ... }:

{
  # Hostname configuration
  networking = {
    computerName = "MacBook Pro";
    hostName = "macbook-pro";
    localHostName = "macbook-pro";
  };

  # User configuration
  users.users.${username} = {
    name = username;
    home = "/Users/${username}";
  };
}
