# 013. Lightweight Ops Command

Date: 2026-05-07

## Status

Accepted

## Context

We needed a very lightweight `/pro:ops` command that can infer whether a task is external‑only or repo‑affecting, create a branch only when required, and automatically merge and push without a PR. Existing `/pro:feature` and `/pro:chore` commands were heavyweight and always forced branch creation, which was unnecessary for simple external‑only operations.

## Decision

Implement a new command in `opencode/pro/commands/ops.md` that:
- Infers task type (external‑only vs repo‑affecting).
- Creates a branch only for repo‑affecting tasks; otherwise runs in‑place.
- Auto‑merges to `main` and pushes directly when the task modifies the repository.
- Records any inference overrides locally for future tuning.
- Provides safety stops and clear error messages.

## Consequences

### Positive
- Faster workflow for simple operations.
- Reduces unnecessary branches and PRs.
- Keeps history clean.
- Still respects safety invariants for repo‑affecting work.

### Negative
- Adds complexity in inference logic that must be maintained.
- Users accustomed to PR‑based workflow may need to adjust expectations.

## Alternatives Considered

1. **Keep existing heavyweight commands** – Rejected because it forces branching for all tasks, slowing down simple operations.
2. **Create a separate script outside `/pro`** – Rejected to maintain consistency within the `/pro` command framework.

## Related

- Planning artifacts: `doc/.plan/.done/feat-add-lightweight-workflow-command/`
