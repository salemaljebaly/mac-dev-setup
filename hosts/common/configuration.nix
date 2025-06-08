{ config, pkgs, inputs, username, ... }:

{
  # Auto upgrade nix package and the daemon service
  services.nix-daemon.enable = true;
  
  # Nix configuration
  nix = {
    settings = {
      # Enable flakes and new commands
      experimental-features = "nix-command flakes";
      
      # Optimize storage
      auto-optimise-store = true;
      
      # Users allowed to use Nix
      trusted-users = [ "@admin" username ];
    };
    
    # Garbage collection
    gc = {
      automatic = true;
      interval = { Weekday = 7; }; # Run weekly
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