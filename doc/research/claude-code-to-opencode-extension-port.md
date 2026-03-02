# Claude Code -> OpenCode Extension Port Findings

Date: 2026-03-02

## Context

This repo explores translating the Claude Code plugin marketplace package
`SavvyAI/ccplugins` into OpenCode-native structures.

Initial focus was validating the `pro` plugin command UX for:

- `/pro:feature`
- `/pro:pr`
- `/pro:pr.merged`

The goal of this phase was to confirm what maps directly, what requires
translation, and which installation workflow is safest for iterative local
development.

## Objective

Gather empirical evidence (docs + runtime verification) about differences and
similarities between Claude Code and OpenCode extension mechanisms, and capture
a repeatable local testing approach.

## Evidence Collected

### OpenCode commands

- OpenCode custom commands are markdown files in:
  - Global: `~/.config/opencode/commands/`
  - Project: `.opencode/commands/`
- Command name is derived from filename.
- Command frontmatter supports fields like `description`, `agent`, and `model`.
- Source: `https://opencode.ai/docs/commands/`

### OpenCode plugins

- OpenCode plugins are JavaScript/TypeScript runtime extensions loaded from:
  - `~/.config/opencode/plugins/`
  - `.opencode/plugins/`
  - or npm packages listed in `opencode.json` `plugin` array
- Source: `https://opencode.ai/docs/plugins/`

### OpenCode rules and Claude compatibility

- OpenCode native rule file: `AGENTS.md`.
- Claude compatibility fallbacks are supported:
  - Project `CLAUDE.md` (if no project `AGENTS.md`)
  - Global `~/.claude/CLAUDE.md` (if no global `~/.config/opencode/AGENTS.md`)
  - Claude skills compatibility is also available.
- Source: `https://opencode.ai/docs/rules/`

### Claude plugin architecture (source model)

- Claude plugin bundles use `.claude-plugin/plugin.json` plus directories such
  as `commands/`, `skills/`, `agents/`, `hooks/`, and `.mcp.json`.
- Plugin command names are namespaced (`/plugin-name:command-name`).
- Sources:
  - `https://code.claude.com/docs/en/plugins`
  - `https://code.claude.com/docs/en/plugins-reference`

## Runtime Validation Results

### Namespaced command behavior in OpenCode

Result: **Confirmed**.

- Creating these files under `~/.config/opencode/commands/`:
  - `pro:feature.md`
  - `pro:pr.md`
  - `pro:pr.merged.md`
- Causes OpenCode command list to show:
  - `/pro:feature`
  - `/pro:pr`
  - `/pro:pr.merged`

This preserves Claude-style command UX for `pro` without renaming conventions.

### Local install strategy

Result: **Scoped symlinks preferred**.

- Recommended approach: symlink only the relevant namespace/component into
  `~/.config/opencode` (for example, only `commands/pro:*`).
- Avoid symlinking the entire repo to `~/.config/opencode` because it broadens
  side effects and may expose unrelated files to config loading.

## Implemented in This Repo

### Command stubs

- `opencode/pro/commands/feature.md`
- `opencode/pro/commands/pr.md`
- `opencode/pro/commands/pr.merged.md`

### Install automation

`Makefile` includes:

- `make install` (default `NS=colon`)
- `make install NS=slash` (fallback mode)
- `make uninstall`
- `make status`
- `make doctor`

Safety behavior:

- If destination exists and is not the expected symlink, install fails with
  instructions instead of overwriting.

## Similarities and Differences

### Similarities

- Both systems support reusable prompt-driven command workflows.
- Both systems support skills, agents, and MCP-related extensibility concepts.
- Rules/instructions can be made compatible due to OpenCode Claude fallback
  behavior.

### Differences

- **Plugin model differs materially**:
  - Claude plugin: bundle metadata and declarative component directories
  - OpenCode plugin: runtime JS/TS hooks and tool/event extensions
- **Hooks differ materially**:
  - Claude hooks are declarative config
  - OpenCode hooks are code-level plugin event handlers
- **MCP packaging differs**:
  - Claude: plugin-local `.mcp.json`
  - OpenCode: `opencode.json` MCP configuration

## Porting Implications

1. Preserve `pro` command namespace with `:` in OpenCode command filenames.
2. Translate command internals from Claude frontmatter/instructions to
   OpenCode-supported command schema.
3. Treat hooks as reimplementation work (behavior-level port, not file copy).
4. Map MCP server definitions into OpenCode config format.
5. Decide rule strategy per target (native `AGENTS.md` vs Claude compatibility).

## Operational Notes

- A temporary `uv_cwd` / `ENOENT` startup error was observed while launching
  `opencode` from a stale shell working directory. This was environmental and
  unrelated to command symlinking.

## Conclusion

The high-value initial hypothesis is validated:

- OpenCode can expose `pro` commands with Claude-style names (`/pro:*`).
- A safe iterative development loop is possible via scoped symlinks and
  Makefile automation.
- Full plugin migration should proceed as a semantic translation, not a 1:1
  file structure port.
