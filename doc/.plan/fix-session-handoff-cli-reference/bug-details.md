# Bug Details

## Steps to Reproduce

1. In a client project repo (any repo that does NOT contain `bin/session-handoff.mjs`), run the session handoff workflow:
   - via `/pro:session.handoff`, or
   - via the session handoff plugin prompt (if installed).
2. Observe the generated ledger/snapshot "Next Steps" commands.

## Expected Behavior

The ledger/snapshot should suggest a CLI invocation that exists and works from the client project, e.g.:

`node "$HOME/.config/opencode/bin/session-handoff.mjs" list|ack|dismiss|write ...`

and it should be clear those commands are run from the client project root.

## Actual Behavior

The ledger/snapshot suggests running `node bin/session-handoff.mjs ...`, which is missing in most client repos, leading to confusing commentary and broken next steps.

## Environment

- OS: macOS (assumed; update if different)
- Toolkit: `config-opencode` installed via `make install`
- Invocation: session handoff command/plugin

## Severity

Critical (blocks work)
