# config-opencode

Local development workspace for translating Claude Code plugin artifacts into OpenCode-compatible configuration.

Research notes for the Claude Code -> OpenCode extension mapping are documented in:

- `doc/research/claude-code-to-opencode-extension-port.md`

## Pro command stubs

Source files live in `opencode/pro/commands/`.

Install symlinks into global OpenCode config (commands + plugins):

```bash
make install
```

Fallback namespace (slash style):

```bash
make install NS=slash
```

Check links:

```bash
make status
```

Remove symlinks:

```bash
make uninstall
```

## Automatic session handoff

`make install` already links the session handoff plugin so `.plan/session-handoff.md`
stays fresh during OpenCode sessions. To operate on plugins alone:

```bash
make install-plugins
```

Remove plugin links only:

```bash
make uninstall-plugins
```
