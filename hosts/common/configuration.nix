{
  config,
  pkgs,
  inputs,
  username,
  ...
}:

{
  # Set the primary user for nix-darwin
  system.primaryUser = username;

  # Fix the nixbld group ID to match the actual system
  ids.gids.nixbld = 350;

  # Nix configuration
  nix = {
    # Enable nix (this replaces services.nix-daemon.enable)
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

    # Use the new optimise option instead of auto-optimise-store
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

  # Set Git commit hash for darwin-version
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility
  system.stateVersion = 4;

  # The platform the configuration will be used on
  nixpkgs.hostPlatform = "aarch64-darwin"; # Updated by install script

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
