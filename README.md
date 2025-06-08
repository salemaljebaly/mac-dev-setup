# Mac Development Environment with Nix

A comprehensive, reproducible macOS development environment using Nix, nix-darwin, and home-manager. Perfect for developers and CTOs who want a declarative, version-controlled system configuration.

## 🚀 Quick Start

### One-Line Installation

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/mac-dev-setup/main/install.sh)"
```

### Manual Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/mac-dev-setup.git ~/.config/nix-config
cd ~/.config/nix-config

# Run the installer
./install.sh
```

## 📋 What's Included

### Development Tools
- **Editors**: VSCode, Cursor
- **Mobile Development**: Android Studio, Xcode (automated installation)
- **Containers**: Docker Desktop
- **Version Control**: Git with enhanced configuration
- **Package Managers**: Homebrew (managed by Nix)

### Productivity Tools
- **Communication**: Slack
- **Design**: Figma
- **AI Assistant**: ChatGPT Desktop
- **Laravel Development**: Herd

### Utilities
- **VPN**: ProtonVPN, WireGuard, Cloudflare Warp
- **Terminal**: Wave Terminal
- **File Sharing**: LocalSend
- **Automation**: fastlane

## 🏗️ Architecture

This setup uses a modular architecture:
- **nix-darwin**: System-level configuration and macOS preferences
- **home-manager**: User-specific configurations and dotfiles
- **nix-homebrew**: Declarative Homebrew management
- **Flakes**: Reproducible, version-locked dependencies

## 🎯 Customization

### Adding New Tools

1. **For Nix packages**, edit `home/common/packages.nix`:
```nix
myPackages = with pkgs; [
  # Add your package here
  neovim
];
```

2. **For Homebrew casks**, edit `modules/system/homebrew.nix`:
```nix
casks = [
  # Add your cask here
  "discord"
];
```

3. **For App Store apps**, edit `modules/system/homebrew.nix`:
```nix
masApps = {
  "App Name" = APP_ID;
};
```

### Rebuilding After Changes

```bash
# Apply system changes
darwin-rebuild switch --flake .

# Or use the helper alias
rebuild
```

## 🧪 Testing Your Configuration

### Dry Run
```bash
darwin-rebuild switch --dry-run --flake .
```

### Check Configuration
```bash
nix flake check
```

### List Generations
```bash
darwin-rebuild --list-generations
```

### Rollback
```bash
darwin-rebuild switch --rollback
```

## 📁 Directory Structure

- `flake.nix` - Main entry point and dependency management
- `hosts/` - Machine-specific configurations
- `home/` - User environment configurations
- `modules/` - Reusable configuration modules
- `lib/` - Helper functions and utilities

## 🔧 Troubleshooting

### Common Issues

1. **"error: experimental Nix feature 'nix-command' is disabled"**
   - Run: `echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf`

2. **Homebrew casks fail to install**
   - Ensure Xcode Command Line Tools are installed: `xcode-select --install`

3. **Permission denied errors**
   - Some apps need manual permission grants in System Preferences > Security & Privacy

4. **Can't find applications**
   - GUI apps are in `/Applications/Nix Apps/`
   - Add to Spotlight: System Preferences > Spotlight > Privacy

### Reset Everything

```bash
# Uninstall nix-darwin
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A uninstaller
./result/bin/darwin-uninstaller

# Uninstall Nix
/nix/nix-installer uninstall
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes using conventional commits
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Conventional Commits

- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `style:` Code style changes
- `refactor:` Code refactoring
- `test:` Test additions or modifications
- `chore:` Maintenance tasks

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- [nix-darwin](https://github.com/LnL7/nix-darwin) maintainers
- [home-manager](https://github.com/nix-community/home-manager) community
- [Determinate Systems](https://determinate.systems/) for the improved Nix installer

## 📚 Resources

- [Nix Pills](https://nixos.org/guides/nix-pills/) - Learn Nix fundamentals
- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/index.html)
- [home-manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes) - Understanding flakes

---

Built with ❤️ for the developer community. Contributions welcome!