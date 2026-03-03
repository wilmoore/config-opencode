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

### Ported commands (v1)

- `opencode/pro/commands/feature.md`
- `opencode/pro/commands/pr.md`
- `opencode/pro/commands/pr.merged.md`

These files are now full workflow command drafts (not stubs), translated from
`_tmp_ccplugins/pro/commands/`.

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

## Command Port Ledger (Precise)

Rule: no silent concessions. Every meaningful change from Claude source behavior
must be logged below.

### `/pro:feature`

#### Ported cleanly

- Preserved mandatory branch-first safety invariant and step ordering intent.
- Preserved ADR lookup requirement (`doc/decisions/`) before proposing changes.
- Preserved backlog JSON contract and `.plan/{branch-slug}` planning directory.
- Preserved browser verification guidance and debugging constraints.

#### Concessions

1. `type`: syntax
   - `source`: Claude command frontmatter uses `allowed-tools`.
   - `target`: OpenCode command frontmatter does not include `allowed-tools`.
   - `change`: removed `allowed-tools` and retained `description` + `agent`.
   - `why`: OpenCode command schema only supports documented command keys.
   - `impact`: minor.
   - `mitigation`: keep command text explicit about required actions and tool use.

2. `type`: workflow
   - `source`: branch creation is step 0 with implicit git context.
   - `target`: added explicit non-git bootstrap flow before branch creation.
   - `change`: offer `git init` + initial commit + optional `gh repo create`.
   - `why`: user requirement to support non-git directories.
   - `impact`: minor.
   - `mitigation`: flow still blocks all other work until branch exists.

3. `type`: ecosystem
   - `source`: definition of done references `@claude.md`.
   - `target`: references `AGENTS.md` or `CLAUDE.md` fallback.
   - `change`: broadened instruction file reference.
   - `why`: OpenCode native + compatibility model.
   - `impact`: none.
   - `mitigation`: preserves intent while matching OpenCode docs.

### `/pro:pr`

#### Ported cleanly

- Preserved git/remote/GitHub CLI preflight gating.
- Preserved planning archive behavior (`.plan/{branch}` -> `.plan/.done/{branch}`).
- Preserved ADR workflow structure and tracking artifacts.
- Preserved version-check flow and `version-bump.json` contract.
- Preserved manual PR fallback path.

#### Concessions

1. `type`: syntax
   - `source`: Claude command uses `allowed-tools` and `AskUserQuestion` framing.
   - `target`: OpenCode command markdown only.
   - `change`: removed tool schema metadata and expressed decisions as guided prompts.
   - `why`: OpenCode command format difference.
   - `impact`: minor.
   - `mitigation`: preserved decision branches and recommended defaults in text.

2. `type`: performance
   - `source`: single monolithic full workflow.
   - `target`: default full workflow plus optional `fast` mode via `$ARGUMENTS`.
   - `change`: `fast` defers ADR/version steps and writes explicit defer note.
   - `why`: reduce runtime when users choose speed while preserving default parity.
   - `impact`: none for default; moderate if user chooses `fast`.
   - `mitigation`: default remains `full`; deferred work handed to `/pro:pr.merged`.

### `/pro:pr.merged`

#### Ported cleanly

- Preserved ADR backfill workflow when missing from `/pro:pr`.
- Preserved tag creation flow from archived `version-bump.json`.
- Preserved tag format detection and duplicate-tag guard.
- Preserved local/remote merged branch cleanup flow.

#### Concessions

1. `type`: syntax
   - `source`: Claude frontmatter includes `allowed-tools`.
   - `target`: OpenCode command frontmatter.
   - `change`: removed `allowed-tools` metadata.
   - `why`: unsupported command key in OpenCode command files.
   - `impact`: minor.
   - `mitigation`: preserved execution instructions in command body.

## Current Status for This Conversion Slice

- Command namespaced UX parity: achieved (`/pro:*` works in OpenCode).
- Functional workflow parity for the three selected commands: largely achieved.
- Required concessions: documented above.
- Intentional optimization concession: `/pro:pr fast` available, default remains
  `full`.

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
