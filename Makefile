# Makefile for Nix development tasks

.PHONY: format lint check test clean help install-hooks

# Default target
.DEFAULT_GOAL := help

help: ## Show this help
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

format: ## Format all Nix files
	@echo "🎨 Formatting Nix files..."
	@find . -name "*.nix" -type f -not -path "./result/*" -exec nixfmt {} \;
	@echo "✅ Formatting complete!"

format-check: ## Check formatting without changing files
	@echo "🔍 Checking formatting..."
	@find . -name "*.nix" -type f -not -path "./result/*" -exec nixfmt --check {} \; || (echo "❌ Formatting issues found. Run 'make format' to fix." && exit 1)
	@echo "✅ Formatting check passed!"

lint-statix: ## Run statix linter
	@echo "🔍 Running statix..."
	@statix check . || true

lint-deadnix: ## Run deadnix linter
	@echo "🔍 Running deadnix..."
	@deadnix . || true

lint: lint-statix lint-deadnix ## Run all linters
	@echo "✅ Linting complete!"

check: ## Run nix flake check
	@echo "🔍 Running flake checks..."
	@nix flake check --all-systems
	@echo "✅ Flake check complete!"

test: format-check lint check ## Run all tests
	@echo "✅ All tests passed!"

clean: ## Clean build artifacts
	@echo "🧹 Cleaning..."
	@rm -rf result result-*
	@find . -name "*.backup-before-nix-darwin" -delete
	@echo "✅ Clean complete!"

install-hooks: ## Install git hooks
	@echo "🔧 Installing git hooks..."
	@git config core.hooksPath .githooks
	@chmod +x .githooks/*
	@echo "✅ Git hooks installed!"

# Development workflow commands
dev: ## Enter development shell
	@nix develop

update: ## Update flake inputs
	@echo "📦 Updating flake inputs..."
	@nix flake update
	@echo "✅ Update complete!"

build: ## Build the system configuration
	@echo "🔨 Building configuration..."
	@nix build .#darwinConfigurations.$(shell hostname | tr '[:upper:]' '[:lower:]').system
	@echo "✅ Build complete!"

switch: ## Switch to the new configuration
	@echo "🚀 Switching configuration..."
	@nix run nix-darwin -- switch --flake .
	@echo "✅ Switch complete!"

# Show what would change without applying
dry-run: ## Show what would change without applying
	@echo "👀 Dry run..."
	@nix run nix-darwin -- switch --flake . --dry-run