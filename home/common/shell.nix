{ config, pkgs, ... }:

{
  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      # Navigation
      ll = "eza -l -g -a --icons";
      ls = "eza --icons";
      lt = "eza --tree --level=2 --icons";
      
      # Git
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git log --oneline --graph";
      
      # Nix - using absolute path for flake
      rebuild = "darwin-rebuild switch --flake $HOME/.config/nix-config";
      update = "cd $HOME/.config/nix-config && nix flake update && darwin-rebuild switch --flake $HOME/.config/nix-config";
      cleanup = "nix-collect-garbage -d";
      
      # Docker
      d = "docker";
      dc = "docker-compose";
      
      # Other
      cat = "bat";
      find = "fd";
      grep = "rg";
      vim = "nvim";
    };
    
    initExtra = ''
      # Custom prompt
      eval "$(starship init zsh)"
      
      # Direnv hook
      eval "$(direnv hook zsh)"
      
      # FZF integration
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      source ${pkgs.fzf}/share/fzf/completion.zsh
      
      # Custom functions
      mkcd() {
        mkdir -p "$1" && cd "$1"
      }
      
      # Set editor
      export EDITOR="nvim"
      export VISUAL="nvim"
    '';
  };
  
  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };
      git_branch = {
        symbol = " ";
      };
      git_status = {
        ahead = "⇡\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        behind = "⇣\${count}";
      };
      nix_shell = {
        symbol = " ";
        format = "via [$symbol$state( \\($name\\))]($style) ";
      };
    };
  };
}