# Plan: Port `/pro:{feature,pr,pr.merged}` to OpenCode

## Scope

Port full functionality for these commands while preserving command names:

- `/pro:feature`
- `/pro:pr`
- `/pro:pr.merged`

## Requirements

1. Preserve behavior parity where possible.
2. Keep `/pro:pr` default behavior as `full`.
3. Support optional `/pro:pr fast` profile for reduced runtime workflow.
4. Add non-git bootstrap flow for `/pro:feature`.
5. Document all concessions between Claude Code and OpenCode precisely.

## Steps

1. Replace stub command files with translated command instructions.
2. Keep OpenCode-supported frontmatter only (`description`, `agent`).
3. Preserve JSON artifact contracts (`.plan/backlog.json`, `.plan/adr-index.json`, `version-bump.json`).
4. Update research ledger with clean ports and concessions.
5. Validate via `make status` and command discovery in OpenCode.

## Risks

- Command instruction size may increase execution latency.
- Claude-specific tool/interaction directives may not map 1:1.

## Mitigations

- Use explicit `fast` profile in `/pro:pr` without changing default behavior.
- Capture each translation difference in a concession ledger.
