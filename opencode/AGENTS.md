# OpenCode Toolkit Rules (Constitution)

These rules are intentionally short. They are global defaults for how this toolkit operates.

Everything workflow-specific should live in commands (`/pro:*`, `/make:*`, `/rules:*`) and project-local docs (ADRs, `doc/rules/*`).

## Core Invariants

- Prefer planning before implementation for non-trivial work; make a plan explicit.
- Preserve safety rails: avoid irreversible/destructive actions unless explicitly requested.
- Keep guidance explainable: for non-obvious rules, write provenance near the rule (Source/Owner/Added/ReviewBy).
- Avoid instruction bloat: do not stuff large procedures into this file.

## Rules Engineering

- Use `/rules:where` to choose where a rule belongs.
- Use `/rules:propose` to draft an Apply Pack (no writes).
- Use `/rules:apply` to apply the pack (writes happen only there).

Source: config-opencode
