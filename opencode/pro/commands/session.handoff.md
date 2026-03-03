---
description: "Ending a session? Refresh `.plan/session-handoff.md` and confirm the snapshot is current before you leave"
agent: build
---

## Context

Run this command right before you step away. It recreates the session handoff
snapshot so the next session can resume exactly where you stopped.

## Your Task

### Step 1: Verify prerequisites

1. Confirm this is a git repository:
   ```bash
   git rev-parse --show-toplevel
   ```
2. Ensure the session handoff plugin exists (installed automatically via
   `make install`). If `opencode/pro/plugins/session-handoff.js` or
   `.plan/` is missing, install via `make install` before continuing.

### Step 2: Collect repo state

1. Record the repo root:
   ```bash
   root=$(git rev-parse --show-toplevel)
   ```
2. Capture metadata:
   ```bash
   branch=$(git rev-parse --abbrev-ref HEAD)
   status=$(git status --short)
   working_tree="$( [ -z "$status" ] && echo clean || echo dirty )"
   recent_commit=$(git log -1 --pretty=format:"%h %s" || echo "unknown")
   now=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
   ```

### Step 3: Summarize backlog

Parse `.plan/backlog.json` if present. Count `status === "in-progress"` items
and capture the most recent title. If the file is missing or unreadable, record
"unknown" in the summary.

Example (Python):

```bash
python - <<'PY'
import json, pathlib
root = pathlib.Path("$root")
backlog = root/".plan"/"backlog.json"
summary = "- In-progress items: unknown (no readable backlog)"
if backlog.exists():
    data = json.loads(backlog.read_text())
    items = [i for i in data.get("items", []) if i.get("status") == "in-progress"]
    if items:
        latest = items[-1]
        summary = f"- In-progress items: {len(items)} (latest: {latest.get('title') or 'untitled'})"
    else:
        summary = "- In-progress items: none"
print(summary)
PY
```

Store the printed summary for the next step.

### Step 4: Write refreshed snapshot

1. Build the markdown payload (match the plugin template):
   ```bash
   cat <<'EOF' > "$root/.plan/session-handoff.md"
   # Session Handoff

   Updated: $now
   Trigger: /pro:session.handoff.check

   ## Current State

   - Branch: `$branch`
   - Working tree: $working_tree
   - Last commit: `$recent_commit`
   $summary

   ## Resume Checklist

   1. Open this repository in OpenCode.
   2. Run `make status` to verify command links.
   3. Type `/pro:` to confirm command availability.
   4. Continue from active backlog item(s) in `.plan/backlog.json`.
   EOF
   ```
2. Re-read `.plan/session-handoff.md` and confirm the `Updated:` line matches
   `$now`. If it differs, repeat the write step.

### Step 5: Report readiness

Show the user:

```
## Session Handoff Verified

- Updated: 2026-03-03T19:05:00Z
- Branch: main
- Working tree: clean
- Summary: - In-progress items: 2 (latest: Fix checkout bug)

You can now end the session safely.
```

If any check fails (missing file, git errors, stale timestamp), surface the
issue, fix it, and rerun the verification before declaring success.
