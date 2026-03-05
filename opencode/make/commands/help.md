---
description: "Add a 'make help' target to your Makefile if missing"
agent: build
---

## Context

Let's add a `make help` target to the project's Makefile. This provides a GNU-style help system that shows available targets and their descriptions.

## Your Task

1. **Check if Makefile exists** - Look for `Makefile` in the current directory
2. **Check if help target already exists** - Search for a `help:` target
3. **Analyze existing targets** - Parse Makefile to find documented targets (look for comment lines above targets)
4. **Generate help target** - Add a help target that displays all available targets with descriptions

## Implementation

Add this help target to the Makefile:

```makefile
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  help     - Show this help message"
	@echo "  (add other targets here)"
```

> ⚠️ **Important:** Makefile recipes must be indented with TAB characters, not spaces.

For a more sophisticated version that auto-discovers targets from comments:

```makefile
.PHONY: help
help:
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*## "}; {printf "  %-15s %s\n", $$1, $$2}'
```

Then document each target with `##` comments:

```makefile
.PHONY: build test help

build: ## Build the project
	npm run build

test: ## Run tests
	npm test
```

> ⚠️ **Important:** All recipe lines (commands) must be indented with TAB characters.

The grep pattern for auto-discovery should include digits and dots:

```makefile
help:
	@grep -E '^[a-zA-Z0-9_.-]+:.*##' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*## "}; {printf "  %-15s %s\n", $$1, $$2}'
```

## Definition of Done

- Makefile has a working `help` target
- Running `make help` displays available targets
- Existing targets are documented in the help output
