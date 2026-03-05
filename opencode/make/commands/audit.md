---
description: "Audit the Makefile for best practices and common issues"
agent: build
---

## Context

Let's audit the project's Makefile for best practices, common issues, and improvements.

## Your Task

1. **Read the Makefile** - Check for existence and parse contents
2. **Run audit checks** - Verify best practices are followed
3. **Report findings** - List issues and recommendations

## Audit Checks

The audit should check for:

1. **Help target** - Is there a `make help` target?
2. **.PHONY declarations** - Are all non-file targets declared in .PHONY?
3. **Shell specification** - Is `SHELL` specified explicitly?
4. **Error handling** - Does the Makefile use `-e` or `set -e`?
5. **Consistent indentation** - Are targets properly indented with tabs?
6. **Variable usage** - Are common values (like node_modules) in variables?
7. **Silent by default** - Are commands prefixed with `@` to reduce noise?

## Implementation

Run these checks and report:

```
=== Makefile Audit ===

✓ Help target present
✗ Missing .PHONY declarations: clean, install
⚠ Consider adding SHELL := /bin/bash
⚠ Commands should use @ prefix for silence

Recommendations:
1. Add .PHONY: clean install dev build test
2. Add @ prefix to suppress command echo
3. Consider adding SHELL specification
```

## Definition of Done

- Makefile is audited comprehensively
- All issues are reported with severity levels
- Recommendations are actionable
