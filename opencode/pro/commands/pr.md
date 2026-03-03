---
description: "Feature complete and tested? Archive planning docs, capture ADRs/versioning, and create a comprehensive pull request"
agent: build
---

Clean up completed planning documentation, document architectural decisions, and create a pull request.

Mode selection:

- Default: `full`
- Optional: pass `fast` in `$ARGUMENTS` to skip ADR/version workflows now and defer to `/pro:pr.merged`.

---

## Git and Remote Prerequisites

Run these checks before proceeding to "Your Task".

### Step 1: Verify GitHub CLI authentication

```bash
gh auth status
```

If not authenticated:

1. Inform user that GitHub CLI auth is required for automatic PR creation.
2. Offer:
   - Authenticate now with `gh auth login` (recommended)
   - Skip automation and follow manual PR instructions at the end

### Step 2: Check git repository status

```bash
git rev-parse --git-dir 2>/dev/null
```

If not a git repository:

1. Inform user.
2. Offer:
   - Initialize now (recommended):
     ```bash
     git init
     git add .
     git commit -m "Initial commit"
     gh repo create --source=. --push
     ```
   - Skip and provide manual instructions

### Step 3: Check for git remote

```bash
git remote -v
```

If no remote exists, offer:

- Create GitHub repo and push now (recommended):
  ```bash
  gh repo create --source=. --push
  ```
- Skip and provide manual instructions

---

## Browser Verification

For web applications, prefer Playwright MCP (if available) over screenshots for:

- visual verification and UI state inspection
- console log and error analysis
- network request inspection

## Your Task

1. Resolve current branch name and its plan directory slug (`feat/x/y` -> `feat-x-y`).
2. Move planning documentation from `.plan/{branch-slug}` to `.plan/.done/{branch-slug}` when present.
3. If mode is `full` (default):
   - Run ADR workflow below.
   - Run version check workflow below.
4. If mode is `fast`:
   - Skip ADR creation/version check for now.
   - Add reminder note in `.plan/.done/{branch-slug}/deferred-pr-tasks.md` listing deferred ADR/version tasks for `/pro:pr.merged`.
5. Create and push pull request.
6. Document known issues not addressed:
   - Preferred: `/pro:backlog.add <description>`
   - Fallback: append directly to `.plan/backlog.json` with:
     - `source` = `/pro:pr`
     - `sourceBranch` = current branch

---

## ADR Instructions

Architecture Decision Records capture implementation rationale.

### Step 1: Setup (if needed)

Create these if missing:

1. `doc/decisions/`
2. `doc/decisions/README.md`:

```markdown
# Architecture Decision Records

This directory contains Architecture Decision Records (ADRs) documenting significant technical decisions.

## What is an ADR?

An ADR captures the context, decision, and consequences of an architecturally significant choice.

## Format

We use the Michael Nygard format.

## Naming Convention

- Filename: `NNN-kebab-case-title.md`
- NNN is zero-padded sequence (`001`, `002`, ...)
- Title heading: `# NNN. Title`

## Index

<!-- New ADRs added below -->
```

3. `.plan/adr-index.json`:

```json
{
  "lastSequence": 0,
  "entries": []
}
```

### Step 2: Check existing ADR coverage

Read `.plan/adr-index.json` for the current branch:

- If ADRs already exist and no new decisions were made, skip ADR creation.
- If new architectural decisions exist, continue.

### Step 3: Determine next ADR number

- `next = lastSequence + 1`

### Step 4: Extract decisions

Review:

- `.plan/.done/{branch-slug}/`
- `git log main..HEAD`
- `git diff main...HEAD`

Look for decisions about architecture, APIs, data, technology choices, and trade-offs.

### Step 5: Create ADR files

For each decision, create `doc/decisions/{NNN}-{kebab-case-title}.md`:

```markdown
# {NNN}. {Title}

Date: {YYYY-MM-DD}

## Status

Accepted

## Context

{What prompted this decision?}

## Decision

{What was decided?}

## Consequences

{Positive and negative outcomes}

## Alternatives Considered

{Alternatives and rejection rationale}

## Related

- Planning: `.plan/.done/{branch-slug}/`
```

### Step 6: Update tracking files

1. Update `.plan/adr-index.json` (`lastSequence`, branch ADR list).
2. Update `doc/decisions/README.md` index.
3. Add "Related ADRs" section to `.plan/.done/{branch-slug}/plan.md` when that file exists.

---

## Version Check Instructions

Before opening PR, verify project version updates.

### Step 1: Find version file

Common candidates:

- `package.json`, `Cargo.toml`, `pyproject.toml`, `composer.json`, `mix.exs`
- `pom.xml`, `build.gradle`, `*.csproj`
- `**/.claude-plugin/plugin.json`
- `VERSION`, `version.txt`, `lib/**/version.rb`

If no version file is found, skip version check.

### Step 2: Compare with base branch

Compare version in `main` vs current branch.

### Step 3: If version is unchanged

Warn user and offer:

- Bump now (recommended for `feat/*` and `fix/*`)
- Proceed without bump (often acceptable for docs-only)

Suggested bump type by branch prefix:

- `feat/*` -> minor
- `fix/*` -> patch
- `docs/*` -> none

### Step 4: Record version bump for post-merge tagging

Write `.plan/{branch-slug}/version-bump.json`:

```json
{
  "version": "{new_version}",
  "confirmedAt": "{ISO 8601 timestamp}",
  "bumpType": "minor|patch|major"
}
```

This is archived and consumed by `/pro:pr.merged` for tag creation.

---

## Commit Message Rules

Omit:

- "Generated with" lines
- "Co-Authored-By" lines

---

## Manual PR Instructions

If automation is skipped, provide:

```text
Next Steps (Manual Setup Required):

1. Initialize git (if needed):
   git init
   git add .
   git commit -m "Initial commit"

2. Create a GitHub repository at https://github.com/new

3. Add remote:
   git remote add origin <your-repo-url>

4. Push branch:
   git push -u origin {current-branch-name}

5. Create PR:
   gh pr create
   # or use GitHub web UI
```

After manual setup, user can re-run `/pro:pr`.
