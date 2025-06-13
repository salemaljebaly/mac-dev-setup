{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Development tools
    git
    gh # GitHub CLI
    lazygit
    delta # Better git diff

    # Build tools
    gnumake
    cmake
    pkg-config

    # Languages and runtimes
    nodejs_20
    python3
    go
    rustup

    # Terminal utilities
    htop
    btop
    ncdu
    tree
    ripgrep
    fd
    bat
    eza # Better ls
    fzf
    jq
    yq
    tldr

    # Network tools
    wget
    curl
    httpie
    mtr

    # Archive tools
    zip
    unzip
    p7zip

    # Cloud tools
    awscli2
    google-cloud-sdk

    # Container tools
    docker-compose
    kubectl
    k9s

    # Development utilities
    direnv
    tmux
    neovim
  ];
}
