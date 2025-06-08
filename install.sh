#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This script is only for macOS!"
    exit 1
fi

print_info "Starting Mac Development Environment Setup..."

# Get system information
ARCH=$(uname -m)
HOSTNAME=$(scutil --get LocalHostName)
USERNAME=$(whoami)

print_info "Detected configuration:"
print_info "  Architecture: $ARCH"
print_info "  Hostname: $HOSTNAME"
print_info "  Username: $USERNAME"

# Check for Rosetta 2 on Apple Silicon
if [[ "$ARCH" == "arm64" ]]; then
    print_info "Apple Silicon detected. Checking Rosetta 2..."
    if ! pgrep -q oahd; then
        print_info "Installing Rosetta 2..."
        softwareupdate --install-rosetta --agree-to-license
    else
        print_success "Rosetta 2 already installed"
    fi
fi

# Check for Xcode Command Line Tools
if ! xcode-select -p &> /dev/null; then
    print_info "Installing Xcode Command Line Tools..."
    xcode-select --install
    print_info "Please complete the installation in the popup window, then press Enter to continue..."
    read -r
else
    print_success "Xcode Command Line Tools already installed"
fi

# Install Nix if not present
if ! command -v nix &> /dev/null; then
    print_info "Installing Nix..."
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    
    # Source Nix
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
else
    print_success "Nix already installed"
fi

# Clone or update repository
REPO_DIR="$HOME/.config/nix-config"
if [ ! -d "$REPO_DIR" ]; then
    print_info "Cloning configuration repository..."
    git clone https://github.com/YOUR_USERNAME/mac-dev-setup.git "$REPO_DIR"
else
    print_info "Repository already exists, pulling latest changes..."
    cd "$REPO_DIR" && git pull
fi

cd "$REPO_DIR"

# Update configuration with actual values
print_info "Updating configuration with your system details..."
if [[ "$ARCH" == "arm64" ]]; then
    SYSTEM="aarch64-darwin"
else
    SYSTEM="x86_64-darwin"
fi

# Create personalized configuration
if [ ! -d "hosts/$HOSTNAME" ]; then
    print_info "Creating configuration for $HOSTNAME..."
    cp -r hosts/default "hosts/$HOSTNAME"
fi

if [ ! -d "home/$USERNAME" ]; then
    print_info "Creating home configuration for $USERNAME..."
    cp -r home/default "home/$USERNAME"
fi

# Update flake.nix with actual values
sed -i '' "s/YOUR_USERNAME/$USERNAME/g" flake.nix
sed -i '' "s/YOUR_HOSTNAME/$HOSTNAME/g" flake.nix
sed -i '' "s/aarch64-darwin/$SYSTEM/g" flake.nix

# Backup existing configurations
# Note: nix-darwin will create /etc/bashrc and /etc/zshrc
# These might not exist on a fresh system, but could exist from previous installs
if [ -f /etc/bashrc ]; then
    print_info "Backing up existing /etc/bashrc..."
    sudo mv /etc/bashrc /etc/bashrc.backup-before-nix-darwin
fi

if [ -f /etc/zshrc ]; then
    print_info "Backing up existing /etc/zshrc..."
    sudo mv /etc/zshrc /etc/zshrc.backup-before-nix-darwin
fi

# Also backup user shell configs if they exist
if [ -f "$HOME/.zshrc" ]; then
    print_info "Backing up ~/.zshrc..."
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup-before-nix-darwin"
fi

if [ -f "$HOME/.bashrc" ]; then
    print_info "Backing up ~/.bashrc..."
    cp "$HOME/.bashrc" "$HOME/.bashrc.backup-before-nix-darwin"
fi

# Build and switch to the configuration
print_info "Building and activating configuration..."
print_info "This may take a while on first run..."

# First time setup needs special handling
if ! command -v darwin-rebuild &> /dev/null; then
    nix run nix-darwin -- switch --flake .
else
    darwin-rebuild switch --flake .
fi

print_success "Installation complete! 🎉"
print_info ""
print_info "Next steps:"
print_info "1. Restart your terminal or run:"
print_info "   - For zsh: source /etc/zshrc"
print_info "   - For bash: source /etc/bashrc"
print_info "2. Some apps may require manual permission grants in System Preferences"
print_info "3. GUI applications are available in /Applications/Nix Apps/"
print_info "4. Run 'rebuild' to apply future configuration changes"
print_info ""
print_info "Repository location: $REPO_DIR"
print_info "To update your configuration, edit files in $REPO_DIR and run 'rebuild'"