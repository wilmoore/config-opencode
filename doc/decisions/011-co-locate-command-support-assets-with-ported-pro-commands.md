# 011. Co-locate Command Support Assets with Ported /pro Commands

Date: 2026-05-01

## Status

Accepted

## Context

Porting `/pro:quality-gate` and `/pro:dev.setup` from ccplugins required template and script assets that previously lived under `_tmp_ccplugins/pro/commands/_templates/*` and `_tmp_ccplugins/pro/commands/_bins/*`.

Keeping command files without these assets would break command behavior, while leaving dependencies under `_tmp_ccplugins` would keep production command paths tied to migration scaffolding.

## Decision

Store command support assets inside `opencode/pro/commands/` next to the ported commands:

- templates in `opencode/pro/commands/_templates/quality-gate/`
- scripts and docs in `opencode/pro/commands/_bins/dev/`

Update command references to these OpenCode-localized paths.

## Consequences

Positive:

- Ported commands are self-contained and runnable without `_tmp_ccplugins`.
- Asset ownership is clear and versioned with the command markdown that uses it.
- Future command maintenance happens in one command namespace.

Negative:

- Repository size increases from committed template/script artifacts.
- Future ports must follow the same co-location convention to avoid path drift.

## Alternatives Considered

- Keep assets in `_tmp_ccplugins/`: rejected because it preserves a migration-only dependency.
- Inline all assets into command markdown: rejected because it is hard to maintain for multi-file templates/scripts.

## Related

- Planning: `doc/.plan/.done/feat-port-pro-audit-quality-product/`
