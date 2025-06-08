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
    
    # No taps needed - all are built-in now
    taps = [];
    
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
      "whatsapp"
    ];
    
    # App Store Applications
    # ignore mas cuz has some issue with OS
    masApps = {};
  };
}