# config-opencode

Local development workspace for translating Claude Code plugin artifacts into OpenCode-compatible configuration.

## Pro command stubs

Source files live in `opencode/pro/commands/`.

Install symlinks into global OpenCode config:

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
