---
description: "Generate a comprehensive codebase handoff report (saved + copied to clipboard)"
agent: build
---

## Context

Generate a comprehensive codebase handoff report for onboarding and transitions.

## Your Task

1. Read the report template from `opencode/pro/commands/_templates/handoff-report.md` (relative to this repo).
   - Prefer locating the template via the installed command symlink so it works from any project:

```bash
COMMAND_LINK="$HOME/.config/opencode/commands/pro:handoff.md"
COMMAND_SOURCE="$(readlink "$COMMAND_LINK" 2>/dev/null || true)"
TEMPLATE_PATH=""

if [ -n "$COMMAND_SOURCE" ]; then
  TEMPLATE_PATH="$(dirname "$COMMAND_SOURCE")/_templates/handoff-report.md"
fi

test -f "$TEMPLATE_PATH" || TEMPLATE_PATH=""
```

   - If the template cannot be found, fall back to generating the report using the same section headings as the template.
2. Explore the codebase and fill out all template sections with actual findings.
3. If data is unavailable, say "Not found".
4. Save report to a temp file:
   - Filename: `handoff-<project>-<timestamp>.md` (timestamp format: `YYYYMMDD-HHMMSS`)
   - Temp dir: `${TMPDIR:-/tmp}` on unix; `%TEMP%` on Windows
5. Copy the report markdown to clipboard (cross-platform detection).
6. Print the output file path and confirm clipboard copy.

Footer:

- Report generated: timestamp
- Git commit: current HEAD
- Generator: `/pro:handoff`
