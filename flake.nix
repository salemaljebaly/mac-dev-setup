{
  description = "Mac Development Environment - Declarative macOS Configuration";

  inputs = {
    # Nix packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nix-darwin for macOS system configuration
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # home-manager for user configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Homebrew integration
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs =
    inputs@{
      nixpkgs,
      darwin,
      home-manager,
      nix-homebrew,
      ...
    }:
    let
      # Configuration for your system
      username = "YOUR_USERNAME"; # TODO: Update this
      hostname = "YOUR_HOSTNAME"; # TODO: Update this (run `scutil --get LocalHostName`)
      system = "aarch64-darwin"; # For M1/M4 Macs. Use "x86_64-darwin" for Intel
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      darwinConfigurations = {
        ${hostname} = darwin.lib.darwinSystem {
          inherit system;

          modules = [
            # System configuration
            ./hosts/common/configuration.nix
            (
              if builtins.pathExists ./hosts/${hostname}/configuration.nix then
                ./hosts/${hostname}/configuration.nix
              else
                ./hosts/default/configuration.nix
            )

            # Homebrew integration
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = true;
                user = username;
                autoMigrate = true;
              };
            }

            # Home Manager integration
            home-manager.darwinModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = import (
                  if builtins.pathExists ./home/${username}/home.nix then
                    ./home/${username}/home.nix
                  else
                    ./home/default/home.nix
                );
                extraSpecialArgs = { inherit inputs username; };
              };
            }
          ];

          specialArgs = { inherit inputs username; };
        };
      };

      # Development shell for the repository
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # Nix formatter
          nixfmt-rfc-style

          # Nix linters
          statix
          deadnix

          # Other useful tools
          nil # Nix language server
          git
        ];

        shellHook = ''
          echo "🛠️  Nix development environment loaded!"
          echo ""
          echo "Available commands:"
          echo "  make format    - Format all Nix files"
          echo "  make lint      - Run linters"
          echo "  make check     - Run flake check"
          echo "  make test      - Run all checks"
          echo ""
        '';
      };

      # Formatter configuration
      formatter.${system} = pkgs.nixfmt-rfc-style;
    };
}
