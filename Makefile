YEAR := $(shell date +%Y)

define COPYRIGHT
/*
 * Copyright (c) $(YEAR), lapic-ufjf
 * Licensed under The MIT License [see LICENSE for details]
 */
endef
export COPYRIGHT

FILES := $(shell find . -type f \( -name "*.ts" -o -name "*.js" \) \
	! -path "./node_modules/*" \
	! -path "./dist/*" \
	! -path "./build/*")

.PHONY: all help test test-api test-watch test-cov test-debug test-e2e check-copyright add-copyright lint lint-check

help:
	@echo "======================================================================"
	@echo "Available make targets:"
	@echo "======================================================================"
	@echo ""
	@echo "  make all              Run all tests and check copyright statements"
	@echo "  make help             Show this help message"
	@echo ""
	@echo "Testing Targets:"
	@echo "  make test             Run all API tests (27 test suites, 55 tests)"
	@echo "  make test-api         Run all API tests (same as 'make test')"
	@echo "  make test-watch       Run tests in watch mode (re-run on file changes)"
	@echo "  make test-cov         Run tests with coverage report"
	@echo "  make test-debug       Run tests in debug mode"
	@echo "  make test-e2e         Run end-to-end tests"
	@echo ""
	@echo "Linting:"
	@echo "  make lint             Fix linting issues in API code"
	@echo "  make lint-check       Check for linting issues without fixing"
	@echo ""
	@echo "Copyright Management:"
	@echo "  make check-copyright  Verify all source files have copyright headers"
	@echo "  make add-copyright    Add copyright headers to files missing them"
	@echo ""
	@echo "======================================================================"

all: test check-copyright
	@echo "✅ All checks passed!"

add-copyright:
	@echo "Adding copyright statements to files..."
	@find . -type f \( -name "*.ts" -o -name "*.js" \) \
		! -path "./node_modules/*" \
		! -path "./*/node_modules/*" \
		! -path "./dist/*" \
		! -path "./*/dist/*" \
		! -path "./build/*" \
		! -path "./*/build/*" \
		! -path "./coverage/*" \
		! -path "./.next/*" | while read file; do \
		if ! grep -q "Copyright (c)" "$$file"; then \
			echo "Updating $$file"; \
			{ \
				printf "%s\n\n" "$$COPYRIGHT"; \
				cat "$$file"; \
			} > "$$file.tmp" && mv "$$file.tmp" "$$file"; \
		fi; \
	done
	@echo "✅ Done adding copyright statements."

check-copyright:
	@bash ./check-license.sh

lint:
	@echo "Fixing linting issues..."
	@cd api && pnpm lint
	@echo "✅ Linting complete!"

lint-check:
	@echo "Checking for linting issues..."
	@cd api && pnpm eslint "{src,apps,libs,test}/**/*.ts" --max-warnings=0 || (echo "❌ Linting issues found!"; exit 1)

test-api:
	@echo "Running API tests..."
	@cd api && pnpm test

test:
	@echo "Running all tests..."
	@cd api && pnpm test

test-watch:
	@echo "Running API tests in watch mode..."
	@cd api && pnpm test:watch

test-cov:
	@echo "Running API tests with coverage..."
	@cd api && pnpm test:cov

test-debug:
	@echo "Running API tests in debug mode..."
	@cd api && pnpm test:debug

test-e2e:
	@echo "Running end-to-end tests..."
	@cd api && pnpm test:e2e