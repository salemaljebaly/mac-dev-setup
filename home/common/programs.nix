{ config, pkgs, ... }:

{
  # VS Code
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        # Nix
        bbenoist.nix
        
        # General development
        eamodio.gitlens
        ms-vscode-remote.remote-ssh
        ms-azuretools.vscode-docker
        
        # Languages
        ms-python.python
        golang.go
        rust-lang.rust-analyzer
        
        # Formatting
        esbenp.prettier-vscode
        
        # Themes
        dracula-theme.theme-dracula
      ];
      
      userSettings = {
        "editor.fontSize" = 14;
        "editor.fontFamily" = "'JetBrains Mono', 'Courier New', monospace";
        "editor.fontLigatures" = true;
        "editor.formatOnSave" = true;
        "editor.minimap.enabled" = false;
        "editor.renderWhitespace" = "selection";
        "editor.tabSize" = 2;
        "files.autoSave" = "afterDelay";
        "files.trimTrailingWhitespace" = true;
        "terminal.integrated.fontSize" = 13;
        "workbench.colorTheme" = "Dracula";
        "workbench.startupEditor" = "none";
      };
    };
  };
  
  # Git
  programs.git = {
    enable = true;
    delta.enable = true;
    
    userEmail = "your.email@example.com"; # TODO: Update
    userName = "Your Name"; # TODO: Update
    
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = false;
      
      core = {
        editor = "nvim";
        whitespace = "trailing-space,space-before-tab";
      };
      
      diff = {
        colorMoved = "default";
      };
      
      merge = {
        conflictstyle = "diff3";
      };
    };
    
    aliases = {
      st = "status -s";
      co = "checkout";
      br = "branch";
      ci = "commit";
      unstage = "reset HEAD --";
      last = "log -1 HEAD";
      visual = "!gitk";
    };
    
    ignores = [
      ".DS_Store"
      "*.swp"
      ".idea"
      ".vscode"
      "node_modules"
      ".env.local"
    ];
  };
  
  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  
  # SSH
  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    extraConfig = ''
      Host *
        UseKeychain yes
    '';
  };
}