---
description: "Convert project build scripts to Make targets"
agent: build
---

## Context

Let's convert the project's build scripts to Make targets. The Make targets will delegate to the existing build system, so the original scripts remain the source of truth but all development tasks can be run via `make`.

## Your Task

1. **Detect build system** - Check for:
   - Node.js: `package.json` with scripts
   - Rust: `Cargo.toml` with scripts
   - Python: `pyproject.toml`, `setup.py` with console_scripts
   - Go: `go.mod` with build commands
   - Ruby: `Gemfile` with rake tasks
   - PHP: `composer.json` with scripts
2. **Extract scripts** - Get all build/test/lint/dev commands
3. **Generate Make targets** - Create equivalent Make targets
4. **Update Makefile** - Add the new targets (create if needed)

## Implementation

For each build script, generate a Make target:

```makefile
# Converted from project build system
.PHONY: dev build test lint

dev: ## Run development server
	npm run dev

build: ## Build the project
	npm run build

test: ## Run tests
	npm run test

lint: ## Run linter
	npm run lint
```

The conversion should:
- Use the script name as the target name
- Add a `##` comment for help text
- Delegate to the appropriate command based on detected ecosystem
- Handle pre/post scripts appropriately

> ⚠️ **Important:** All recipe lines must be indented with TAB characters.

## Definition of Done

- All detected build scripts converted to Make targets
- Make targets delegate to the appropriate build tool
- Running `make <target>` works the same as the original command
- `make help` shows all converted targets
