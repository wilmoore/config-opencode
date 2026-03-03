---
description: "PR successfully merged? Clean up planning artifacts and branches, and complete post-merge tagging"
agent: build
---

The pull request `$ARGUMENTS` was successfully merged and closed.

## Your Task

1. Determine merged branch name (from `$ARGUMENTS` or git context).
2. Check for ADR coverage:
   - If ADRs were not created during `/pro:pr`, create them now (see ADR instructions).
3. Switch to main branch and pull latest.
4. Create version tag if a version bump was recorded (see tagging instructions).
5. Delete merged branch (local and remote).
6. Summarize cleanup completion.

---

## ADR Instructions (if missing)

### Step 1: Check ADR index

Read `.plan/adr-index.json` and check for an entry matching merged branch slug.

- If ADRs exist for this branch, skip ADR creation.
- If missing, continue.

### Step 2: Setup (if needed)

Create missing structure/files:

1. `doc/decisions/`
2. `doc/decisions/README.md` with ADR format/index boilerplate
3. `.plan/adr-index.json`:

```json
{
  "lastSequence": 0,
  "entries": []
}
```

### Step 3: Determine next ADR number

- `next = lastSequence + 1`

### Step 4: Extract decisions

Review:

- `.plan/.done/{branch-slug}/` planning artifacts
- commits merged from PR

Identify architecture and trade-off decisions.

### Step 5: Create ADRs

Create `doc/decisions/{NNN}-{kebab-case-title}.md` using standard sections:

- Status
- Context
- Decision
- Consequences
- Alternatives Considered
- Related (`.plan/.done/{branch-slug}/`)

### Step 6: Update tracking

1. Update `.plan/adr-index.json`
2. Update `doc/decisions/README.md` index
3. Add related ADR links into `.plan/.done/{branch-slug}/plan.md` (if present)

### Step 7: Commit and push ADRs on main

```bash
git add doc/decisions/ .plan/adr-index.json .plan/.done/
git commit -m "Add ADRs for {feature-name}"
git push origin main
```

---

## Tagging Instructions

If a version bump was recorded during `/pro:pr`, create and push a git tag.

### Step 1: Check for version bump file

Look for `.plan/.done/{branch-slug}/version-bump.json`.

- If missing: skip tagging.
- If present: continue.

### Step 2: Determine tag format

Inspect existing tags:

```bash
git tag --list | head -5
```

- Existing tags with `v` prefix -> use `v{version}`
- Existing tags without prefix -> use `{version}`
- No tags -> default to `v{version}`

### Step 3: Check if tag already exists

```bash
git tag --list {tag}
```

- If exists, warn and skip.
- If not, continue.

### Step 4: Create and push tag

```bash
git tag {tag}
git push origin {tag}
```

Report success after push.

---

## Cleanup Commands

```bash
git fetch origin main && git checkout main && git pull origin main
git branch -d {merged-branch-name}
git push origin --delete {merged-branch-name}
```
