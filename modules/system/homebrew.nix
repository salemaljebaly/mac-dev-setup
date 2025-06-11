_:

{
  # Homebrew configuration
  homebrew = {
    enable = true;

    # Prevent auto-update during builds (faster)
    global = {
      autoUpdate = false; # We update manually with onActivation
    };

    # Auto update on rebuild
    onActivation = {
      autoUpdate = true;
      cleanup = "zap"; # Remove unlisted packages
      upgrade = true;
    };

    # No taps needed - all are built-in now
    taps = [ ];

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

      # Security
      "bitwarden"

      # VPN
      "protonvpn"
      "cloudflare-warp"

      # Utilities
      "localsend"
    ];

    # App Store Applications
    masApps = {
      # "Xcode" = 497799835; # Commented out due to Apple ID issues
    };
  };

  # Set environment variables to reduce Homebrew noise
  environment.variables = {
    HOMEBREW_NO_AUTO_UPDATE = "1";
    HOMEBREW_NO_ENV_HINTS = "1";
  };
}
