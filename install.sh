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
    
    # Check if there's a broken installation
    if [ -f "/nix/receipt.json" ]; then
        print_error "Found incomplete Nix installation"
        print_info "Run '/nix/nix-installer uninstall' first, then re-run this script"
        exit 1
    fi
    
    # Use the official Nix installer with daemon mode (required for macOS)
    # The installer will handle all backups and system modifications
    print_info "The Nix installer will ask for your sudo password and show what it's doing"
    curl -L https://nixos.org/nix/install | sh -s -- --daemon
    
    # Source Nix
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
    
    # Enable experimental features for flakes
    print_info "Configuring Nix with flakes support..."
    mkdir -p ~/.config/nix
    echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
    
    # Also add to system config
    if [ -f /etc/nix/nix.conf ]; then
        if ! grep -q "experimental-features" /etc/nix/nix.conf; then
            echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf > /dev/null
        fi
    fi
else
    print_success "Nix already installed (version: $(nix --version))"
    
    # Ensure Nix is available in current shell
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
    
    # Enable flakes if not already enabled
    if ! nix show-config 2>/dev/null | grep -q "experimental-features.*flakes"; then
        print_info "Enabling Nix flakes..."
        mkdir -p ~/.config/nix
        if ! grep -q "experimental-features" ~/.config/nix/nix.conf 2>/dev/null; then
            echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
        fi
    else
        print_success "Nix flakes already enabled"
    fi
fi

# Clone or update repository
REPO_DIR="$HOME/.config/nix-config"
if [ ! -d "$REPO_DIR" ]; then
    print_info "Cloning configuration repository..."
    git clone https://github.com/salemaljebaly/mac-dev-setup.git "$REPO_DIR"
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

# Build and switch to the configuration
print_info "Building and activating configuration..."
print_info "This may take a while on first run..."

# Always use nix run for reliability
# This works whether darwin-rebuild is in PATH or not
print_info "Applying system configuration..."
print_info "You will be prompted for your password to make system changes"

# Build and switch to the configuration
print_info "Building and activating configuration..."
print_info "This may take a while on first run..."
print_info "You will be prompted for your password to make system changes"

# The --impure flag allows nix to work with sudo
nix --extra-experimental-features "nix-command flakes" build "$REPO_DIR#darwinConfigurations.${HOSTNAME}.system"

# Activate using the built result
if [ -L result ]; then
    sudo ./result/activate
    print_success "System configuration activated!"
else
    print_error "Build failed - no result symlink found"
    exit 1
fi

# Clean up the result symlink
rm -f result

# Check if darwin-rebuild is now available
if command -v darwin-rebuild &> /dev/null; then
    print_success "darwin-rebuild is now available in PATH"
else
    print_info "Note: darwin-rebuild may not be in PATH until you open a new terminal"
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