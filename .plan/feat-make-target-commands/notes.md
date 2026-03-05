# Plan: /make: Commands for Makefile Automation

## Overview

Create root-level `/make:` commands (sibling to `/pro:`) for Makefile-related utilities.

**Core principle:** These commands must be **ecosystem-agnostic**. They detect project type automatically and adapt accordingly.

## Proposed Commands

### 1. `/make:help`
- Adds a `make help` target where there's a Makefile but no help target

### 2. `/make:setup`
- Auto-detects project type: Node.js, Rust, Python, Go, Ruby, PHP, generic
- Interactive confirmation when detection is uncertain
- Generates appropriate Makefile targets

### 3. `/make:convert`
- Detects build system and converts scripts to Make targets

### 4. `/make:audit`
- Audit the Makefile for best practices

## Implementation Status

- ✅ Created `opencode/make/commands/` directory
- ✅ Created `help.md`, `setup.md`, `convert.md`, `audit.md`
- ✅ Updated to be ecosystem-agnostic
- ✅ Ran coderabbit validation
- ✅ Fixed TAB indentation warnings
