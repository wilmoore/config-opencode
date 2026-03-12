---
description: "Plan a rule change conversationally and output an Apply Pack (no writes)"
agent: plan
---

## Context

Use this when rules are being ignored, going stale, or their provenance is unclear.

This command MUST stay in planning: it produces an Apply Pack but does not write files.

Input: $ARGUMENTS (free-form description of the rule/policy problem, include 1 example)

Example:

`/rules:propose agents keep ignoring the most important rules; policies go stale; provenance is unclear`

## Your Task

### Step 1: Enter planning

Explicitly announce that you are in planning mode.

### Step 2: Diagnose

Ask a short sequence of questions (keep it tight):

- What is the concrete issue? (one example)
- Who is impacted? (you only vs team)
- Guidance vs enforcement? (should vs must)
- Desired longevity? (permanent vs time-boxed)

### Step 3: Choose placement

Recommend the best home, in this order:

1) command (workflow)
2) plugin/enforcement (guardrail code that enforces behavior automatically, e.g. OpenCode plugin logic under `opencode/**/plugins/*.js`)
3) ADR (`doc/decisions/*`)
4) `doc/rules/*`
5) reluctantly `AGENTS.md`

If the recommended home is ADR or `doc/rules/*`, prefer:

- ADR when there are trade-offs and future readers will ask "why"
- `doc/rules/*` when it is a durable guideline without deep trade-offs

### Step 4: Determine author identity (for provenance)

Read git identity (do not modify git config automatically):

```bash
git config --get user.name
git config --get user.email
```

If git config is unavailable or returns empty values, fall back to environment variables:

`GIT_AUTHOR_NAME`, `GIT_AUTHOR_EMAIL`.

If email matches either of these patterns, warn and require an explicit choice:

- provide an override identity to use in the Apply Pack (recommended), or
- explicitly confirm using the noreply identity for this Apply Pack

- `*@users.noreply.github.com`
- `*@noreply.github.com`

Preferred format:

`"Full Name" <email@example.com>`

### Step 5: Output an Apply Pack

Output a single Apply Pack containing:

- placement decision (why this file)
- full file contents for any added files
- exact edits for any updated files
- provenance stamp included in the resulting artifact(s):
  - `Source:`
  - `Added:` (ISO 8601)
  - `Owner:` (from git identity or override)
  - `ReviewBy:` (date or trigger; if permanent, write `ReviewBy: none`)

Use this format:

```text
BEGIN APPLY PACK

Author: "Name" <email>
Rationale: <1-3 lines explaining the placement decision>

Add File: path/to/file
Rationale: <why this file exists and why it lives here>
<full contents>

Update File: path/to/file
Rationale: <why this change belongs in this file>
<exact replacement blocks or patch instructions>

END APPLY PACK
```

### Step 6: Next step

Tell the user to run `/rules:apply` to apply the pack. Do not write anything in this command.
