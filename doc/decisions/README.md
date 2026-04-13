# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) documenting significant technical decisions.

## What is an ADR?

An ADR captures the context, decision, and consequences of an architecturally significant choice.

## Format

We use the Michael Nygard format.

## Naming Convention

- Filename: `NNN-kebab-case-title.md`
- NNN is zero-padded sequence (`001`, `002`, ...)
- Title heading: `# NNN. Title`

## Index

<!-- New ADRs added below -->

- [001. Split Installer Targets for Commands and Plugins](001-split-install-targets.md)
- [002. Add Manual Session Handoff Verification Command](002-session-handoff-check-command.md)
- [003. Adopt Per-Session Handoff Ledger and CLI](003-adopt-per-session-handoff-ledger.md)
- [004. Maintain Session Handoff Metadata Integrity](004-maintain-session-handoff-metadata.md)
- [005. Standardize Planning Root at doc/.plan](005-standardize-plan-root.md)
- [006. Add Plan-by-default Safety Rail](006-plan-by-default-safety-rail.md)
- [007. Add /rules Toolkit Commands and Opt-in AGENTS Install](007-add-rules-toolkit-and-opt-in-agents-install.md)
- [008. Project-Scoped Instruction Discovery for /pro Commands](008-project-scoped-instruction-discovery.md)
- [009. /pro:backlog.resume Recommends a Default Using Session Handoff](009-backlog-resume-recommendation-uses-session-handoff.md)
- [010. Install Session Handoff CLI Globally and Reference It in Ledgers](010-install-session-handoff-cli-globally-and-reference-it-in-ledgers.md)
