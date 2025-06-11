{ username, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage
  home = {
    inherit username;
    homeDirectory = "/Users/${username}";
    stateVersion = "23.11";
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Import common configurations
  imports = [
    ../common/packages.nix
    ../common/shell.nix
    ../common/programs.nix
  ];

  # Additional user-specific configuration can go here
}
