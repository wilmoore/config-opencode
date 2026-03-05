---
description: "Set up a Make-based workflow in a project"
agent: build
---

## Context

Let's set up a new Make-based workflow in this project. The Makefile should adapt to the project's ecosystem automatically.

## Your Task

1. **Detect project type** - Check for:
   - Node.js: `package.json`, `yarn.lock`, `pnpm-lock.yaml`, `bun.lockb`
   - Rust: `Cargo.toml`
   - Python: `pyproject.toml`, `setup.py`, `Pipfile`
   - Go: `go.mod`
   - Ruby: `Gemfile`
   - PHP: `composer.json`
2. **Confirm with user** - If multiple types detected or uncertain, ask for confirmation
3. **Generate Makefile** - Create targets appropriate to the detected ecosystem

## Project-Specific Targets

### Node.js
```makefile
install:
	npm install

dev:
	npm run dev

build:
	npm run build

test:
	npm test

lint:
	npm run lint
```

### Rust
```makefile
install:
	cargo fetch

dev:
	cargo run

build:
	cargo build

test:
	cargo test

lint:
	cargo clippy
```

### Python
```makefile
install:
	pip install -e .

dev:
	python -m whatever_dev

build:
	python -m build

test:
	pytest

lint:
	ruff check .
```

### Go
```makefile
install:
	go mod download

dev:
	go run .

build:
	go build -o bin/app .

test:
	go test ./...

lint:
	golangci-lint run
```

### Generic Fallback
If no project type detected, create a generic Makefile with common targets.

> ⚠️ **Important:** Makefile recipes must be indented with TAB characters, not spaces.

## Definition of Done

- Makefile created with ecosystem-appropriate targets
- User confirmed project type if detection was uncertain
- `make help` displays all available targets
