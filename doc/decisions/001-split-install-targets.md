# 001. Split Installer Targets for Commands and Plugins

Date: 2026-03-03

## Status

Accepted

## Context

The Makefile originally offered a single `install` target that only linked
`/pro:*` commands. Installing the session handoff plugin required running a
separate `make install-handoff`, which was confusing because users expected one
command to provision everything. The uninstall flow exhibited the same
asymmetry.

## Decision

Refactor the Makefile to introduce explicit `install-commands` and
`install-plugins` targets. Redefine `make install` to depend on both, so a single
invocation sets up commands and plugins. Mirror the pattern with
`uninstall-commands`, `uninstall-plugins`, and a composite `make uninstall`.
Enhance `make help` to describe the updated targets.

## Consequences

- ✅ One command now installs the entire toolchain, reducing onboarding errors.
- ✅ Advanced users can still run command-only or plugin-only installs.
- ⚠️ Slightly more Makefile complexity, but mitigated by the help text.

## Alternatives Considered

1. **Keep `install-handoff` separate** – rejected because it perpetuated the
   confusion and required memorizing extra commands.
2. **Auto-install plugin from inside `install` silently** – rejected because it
   hid the plugin workflow and made targeted uninstall difficult.

## Related

- Planning: `.plan/.done/feat-continue-ccplugins-port/`
