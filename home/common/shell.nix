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
      
      # Nix - using nix run for reliability
      rebuild = "nix run nix-darwin -- switch --flake $HOME/.config/nix-config";
      update = "cd $HOME/.config/nix-config && nix flake update && nix run nix-darwin -- switch --flake $HOME/.config/nix-config";
      cleanup = "nix-collect-garbage -d";
      
      # Alternative if darwin-rebuild is in PATH
      rebuild-direct = "darwin-rebuild switch --flake $HOME/.config/nix-config";
      
      # Docker
      d = "docker";
      dc = "docker-compose";
      
      # Other
      cat = "bat";
      find = "fd";
      grep = "rg";
      vim = "nvim";
    };

    # Changed from initExtra to initContent
    initContent = ''
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
  
  # Starship prompt configuration remains the same...
}