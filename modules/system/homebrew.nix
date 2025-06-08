{ config, ... }:

{
  # Homebrew configuration
  homebrew = {
    enable = true;
    
    # Auto update on rebuild
    onActivation = {
      autoUpdate = true;
      # todo: needs to check
      cleanup = "zap"; # Remove unlisted packages
      upgrade = true;
    };
    
    # Taps
    taps = [
      "homebrew/cask"
      "homebrew/core"
      "homebrew/services"
    ];
    
    # Packages from Homebrew
    brews = [
      "mas" # Mac App Store CLI
      "fastlane" # Mobile automation
    ];
    
    # GUI Applications
    casks = [
      # Development
      "android-studio"
      "docker"
      "cursor"
      
      # Communication
      "slack"
      "chatgpt"
      
      # Design
      "figma"
      
      # VPN
      "protonvpn"
      "cloudflare-warp"
      
      # Utilities
      "localsend"
      "bitwarden"
    ];
    
    # App Store Applications
    masApps = {
      # "Xcode" = 497799835;
    };
  };
}