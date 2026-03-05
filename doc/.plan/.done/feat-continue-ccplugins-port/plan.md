# Plan: Continue ccplugins command port

## ADR Review

- `doc/decisions/` does not exist in this repo, so there are currently no ADRs to constrain this work.

## Requirements & Scope

1. Inventory which `/pro:*` command specs already exist in `opencode/pro/commands/` versus the legacy `_tmp_ccplugins/pro/commands/` directory.
2. Summarize the completed ports and enumerate the outstanding commands so the user can pick the next batch to translate.
3. Capture the findings in the backlog and report while keeping all planning artifacts under `.plan/` for future traceability.

## Current State Snapshot

- Ported commands (10): `feature.md`, `pr.md`, `pr.merged.md`, `bug.md`, `chore.md`, `copy.questions.md`, `pr.resolve.md`, `product.brief.md`, `readme.md`, `refactor.md`.
- Remaining Claude Code commands to port (38): `app.icon.md`, `audit.md`, `audit.quality.md`, `audit.repo.md`, `audit.security.md`, `backlog.add.md`, `backlog.md`, `backlog.mvp.md`, `backlog.resume.md`, `bip.md`, `bip.setup.md`, `bounty.hunter.md`, `bounty.recon.md`, `bounty.scout.md`, `branch.park.md`, `branch.rmrf.md`, `content-fight.md`, `demo.md`, `dev.setup.md`, `git.main.md`, `handoff.md`, `og.md`, `onboarding.md`, `permissionless-proof.md`, `product.pitch.md`, `product.validate.md`, `quality-gate.md`, `react.to.next.md`, `roadmap.md`, `rules.install.md`, `rules.md`, `scaffold.chrome-extension.md`, `social.md`, `spec.import.md`, `spec.md`, `spike.md`, `supabase.local.md`, `wtf.md`.

## Implementation Steps

1. Diff the command inventories (OpenCode vs. legacy ccplugins) to confirm the counts above and store the results for reference.
2. Update `.plan/backlog.json` with this branch as an in-progress item to track the continuation effort.
3. Maintain this plan under `.plan/feat-continue-ccplugins-port/` for future audits.
4. Prepare a concise report highlighting ported vs. remaining commands so the user can choose the next batch.
5. Run `coderabbit --prompt-only` to collect any automated feedback before closing the task.
6. Port the selected batch (`bug.md`, `chore.md`, `copy.questions.md`, `pr.resolve.md`, `product.brief.md`, `readme.md`, `refactor.md`) from `_tmp_ccplugins/pro/commands/` into `opencode/pro/commands/`, translating frontmatter/tooling directives to OpenCode conventions.
7. For each ported command, sanity-check references for instructions incompatible with OpenCode agents and adjust where necessary while preserving workflow intent.
8. Capture any new gaps or follow-ups in `.plan/backlog.json` using `/pro:feature` metadata when manual entry is required.

## Batch Progress Log

- 2026-03-03: Ported `/pro:{bug,chore,copy.questions,pr.resolve,product.brief,readme,refactor}` into `opencode/pro/commands/` and added the supporting `opencode/pro/skills/product-brief/` reference files.
- 2026-03-03: Updated `install-handoff`/`uninstall` logic in `Makefile` so symlink remediation guidance matches install-colon and `make uninstall` now calls `uninstall-handoff`.
- 2026-03-03: Add `make help` target that prints a command summary similar to GNU CLI help text.
- 2026-03-03: Restructured Makefile install/uninstall flow into `install-commands`, `install-plugins`, and unified `install`/`uninstall` orchestration.
- 2026-03-03: Added `/pro:session.handoff.check` command so sessions end with a freshly written `.plan/session-handoff.md` snapshot.

## Related ADRs

- [001. Split Installer Targets for Commands and Plugins](../../doc/decisions/001-split-install-targets.md)
- [002. Add Manual Session Handoff Verification Command](../../doc/decisions/002-session-handoff-check-command.md)
