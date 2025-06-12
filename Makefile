# Makefile for Nix development tasks

.PHONY: format lint check test clean help install-hooks format-check

# Default target
.DEFAULT_GOAL := help

# Variables
NIX_FILES := $(shell find . -name "*.nix" -type f ! -path "./result*" ! -path "./.git/*" 2>/dev/null)

help: ## Show this help
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

format: ## Format all Nix files
	@echo "🎨 Formatting Nix files..."
	@echo "Found $(words $(NIX_FILES)) Nix files"
	@for file in $(NIX_FILES); do \
		echo "  Formatting: $$file"; \
		nixfmt "$$file" || exit 1; \
	done
	@echo "✅ Formatting complete!"

format-check: ## Check formatting without changing files
	@echo "🔍 Checking formatting..."
	@FAILED=0; \
	for file in $(NIX_FILES); do \
		nixfmt --check "$$file" 2>/dev/null || { \
			echo "  ❌ $$file needs formatting"; \
			FAILED=1; \
		}; \
	done; \
	if [ $$FAILED -eq 1 ]; then \
		echo "❌ Formatting issues found. Run 'make format' to fix."; \
		exit 1; \
	fi
	@echo "✅ All files properly formatted!"

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

dry-run: ## Show what would change without applying
	@echo "👀 Dry run..."
	@nix run nix-darwin -- switch --flake . --dry-run

# Debug command to show which files will be formatted
show-files: ## Show all Nix files that would be formatted
	@echo "Nix files found:"
	@for file in $(NIX_FILES); do \
		echo "  $$file"; \
	done
	@echo "Total: $(words $(NIX_FILES)) files"