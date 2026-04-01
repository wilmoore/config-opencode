# Plan: Port /pro:backlog* + /pro:spec* + /pro:spike (and resume helpers)

Branch: `feat/port-pro-backlog-spec-spike`

## Planning Mode

This work is planned first, then implemented.

## Relevant ADRs

- `doc/decisions/005-standardize-plan-root.md`: read both `doc/.plan/` and `.plan/`, write only `doc/.plan/`.
- `doc/decisions/003-adopt-per-session-handoff-ledger.md`: session-handoff snapshots persist under `doc/.plan/session-handoff/`.
- `doc/decisions/004-maintain-session-handoff-metadata.md`: snapshot metadata must remain consistent between `index.json` and markdown.
- `doc/decisions/001-split-install-targets.md`: installer targets stay split and auto-discover commands.

## Scope

Port these ccplugins commands into OpenCode command markdown:

- `/pro:backlog`
- `/pro:backlog.add`
- `/pro:backlog.resume`
- `/pro:backlog.mvp`
- `/pro:spec`
- `/pro:spec.import`
- `/pro:spike`

Also port "resume helper" commands that are referenced by backlog flows:

- `/pro:branch.park`
- `/pro:branch.rmrf`
- `/pro:handoff`
- `/pro:git.main`
- `/pro:roadmap`

## Key Behavior Requirement

`/pro:backlog.resume` is the "new session entrypoint":

- If there is in-progress work, recommend the best candidate.
- If multiple candidates exist, prompt the user and clearly mark the recommendation.
- If there is no in-progress work, recommend the next best open item.

Tie-breaker preference when multiple in-progress items exist:

- Prefer the newest pending session-handoff snapshot's `branch` as the recommended default.
- Still prompt the user (recommendation is the default choice).

## Plan Root + Backlog Schema

- Canonical backlog path: `doc/.plan/backlog.json`.
- Backlog schema in this repo currently uses `status: open|in-progress|completed` and does not require `phase` or MVP fields.
- Ported commands must be tolerant of legacy fields (e.g. `resolved`, `wont-fix`) but should not require them.

## Implementation Steps

1. Read legacy command sources under `_tmp_ccplugins/pro/commands/`.
2. For each target command:
   - Translate references from `.plan/` to `doc/.plan/`.
   - Remove Claude-specific tool metadata (`allowed-tools`, `AskUserQuestion`, `TodoWrite`), but keep the interaction as plain prompts and defaults.
   - Ensure commands are self-contained (do not require AGENTS.md bloat).
3. Implement files under `opencode/pro/commands/`.
4. Update `doc/.plan/product/briefs/2026-03-08-ccplugins-port-roadmap.md` if ordering/scope changes.
5. Run `coderabbit --prompt-only` and address findings.
6. Run `make doctor` and `node --test test/*.test.mjs`.

## Related ADRs

- [008. Project-Scoped Instruction Discovery for /pro Commands](../../decisions/008-project-scoped-instruction-discovery.md)
- [009. /pro:backlog.resume Recommends a Default Using Session Handoff](../../decisions/009-backlog-resume-recommendation-uses-session-handoff.md)
