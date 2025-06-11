{
  pkgs,
  inputs,
  username,
  ...
}:

let
  # Try to detect the nixbld GID
  nixbldGid = 350; # Default value for modern Nix installations
in
{
  # System configuration
  system = {
    # Set the primary user for nix-darwin
    primaryUser = username;

    # Set Git commit hash for darwin-version
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    # Used for backwards compatibility
    stateVersion = 4;
  };

  # Fix the nixbld group ID to match the actual system
  ids.gids.nixbld = nixbldGid;

  # Nix configuration
  nix = {
    # Enable nix
    enable = true;

    settings = {
      # Enable flakes and new commands
      experimental-features = "nix-command flakes";

      # Users allowed to use Nix
      trusted-users = [
        "@admin"
        username
      ];

      # Additional binary caches
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    # Use the new optimise option
    optimise.automatic = true;

    # Garbage collection
    gc = {
      automatic = true;
      interval = {
        Weekday = 7;
      }; # Run weekly
      options = "--delete-older-than 7d";
    };
  };

  # The platform the configuration will be used on
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    curl
    wget
  ];

  # Create /etc/zshrc that loads the nix-darwin environment
  programs.zsh.enable = true;

  # Load configuration modules
  imports = [
    ../../modules/system/defaults.nix
    ../../modules/system/homebrew.nix
  ];
}
