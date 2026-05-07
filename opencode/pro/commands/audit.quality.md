---
description: "Ready to verify completeness? → Analyzes requirements, tests, security, and more → Report + capture to backlog"
agent: build
---

## Context

Audit analyzes the current branch for gaps and issues, generates a report, and optionally captures findings to the backlog.

## Your Task

### 1. Run Comprehensive Analysis

Analyze the current branch against these categories:

#### Requirements Coverage
- Check `doc/.plan/{branch}/` for planning docs, requirements, or specs
- Compare stated requirements against implemented code
- Flag any requirements not addressed

#### Unit Tests
- Check if new/changed functions have corresponding unit tests
- Look for test files matching source files (e.g., `foo.ts` → `foo.test.ts`)
- Flag functions without test coverage

#### Integration Tests
- Check for tests that verify component interactions
- Look for test files with integration patterns

#### E2E Tests
- Check for end-to-end test coverage of user workflows
- Look for e2e/playwright/cypress test files

#### Edge Cases
- Identify boundary conditions in the code
- Check for empty state handling, null checks, limits
- Be conservative — avoid false positives

#### Error Handling
- Check for try/catch blocks, error boundaries
- Verify error messages are user-friendly
- Flag unhandled promise rejections

#### Documentation
- Check if README needs updates for new features
- Verify JSDoc/comments on complex or exported functions

#### Production Readiness

| Check | What to look for |
|-------|------------------|
| console.log | Flag for removal — use production logger |
| debugger | Allow if using conditional debug tools (e.g., `debug` package) |
| TODO/FIXME | Extract as potential backlog items |
| Hardcoded secrets | API keys, passwords, tokens in code |
| Hardcoded env values | URLs, ports, config that should come from env |
| Security basics | Input validation, injection prevention, auth checks |
| Performance | Obvious N+1 queries, blocking operations, memory leaks |
| Accessibility | A11y basics for UI changes |
| i18n | Hardcoded user-facing strings that should be localized |

### 2. Generate Report

Create a structured report with findings grouped by category:

```markdown
# Audit Report

Generated: {ISO 8601 timestamp}
Branch: {current branch}
Project: {project name}

## Summary

- Total findings: X
- Critical: X | High: X | Medium: X | Low: X

## Findings

### Security (2 findings)

#### [critical] Hardcoded API key in config.ts
- **File:** config.ts:42
- **Description:** API key should be in environment variable
- **Fingerprint:** config.ts:42-42|hardcoded-secret

#### [high] Missing auth check on /api/users
- **File:** routes/users.ts:15
- **Description:** Endpoint accessible without authentication
- **Fingerprint:** routes/users.ts:15-20|missing-auth

### Tests (1 finding)
...
```

### 3. Output Report

1. Display report on screen
2. Write timestamped report to temp directory:
   - Path: `$TMPDIR/audit-report-{YYYY-MM-DD-HHmmss}.md` (filesystem-friendly format)
   - Example: `$TMPDIR/audit-report-2024-12-25-143000.md`
   - Tell user: "Report saved to {path}"

### 4. Prompt for Capture

1. Ask: "Would you like to capture any findings to backlog?"

2. Present findings for selection:
   - Group by category
   - Sort by severity within category
   - Show priority badge: `[critical]`, `[high]`, `[medium]`, `[low]`
   - Nothing selected by default
   - Mark items already in backlog as non-selectable (show backlog ID)

3. Use `AskUserQuestion` with `multiSelect: true`

4. For each selected finding:
   - Check fingerprint against existing backlog items
   - Skip if already exists (inform user)
   - Add new items to `doc/.plan/backlog.json`
   - Set `source: "/pro:audit.quality"` and `sourceBranch: "{current branch}"`

### 5. Offer to Open Report

Ask: "Would you like to open the report?"
- If yes, open in default editor based on platform:
  - macOS: `open {report-path}`
  - Linux: `xdg-open {report-path}`
  - Windows: `start {report-path}`

## Fingerprint Format

For deduplication, each finding has a fingerprint:

```
{file}:{start-line}-{end-line}|{issue-type}
```

Examples:
- `config.ts:42-42|hardcoded-secret`
- `routes/users.ts:15-20|missing-auth`
- `manual|1|split-gaps-command` (for manual items)

## Category Mapping

Map findings to backlog categories:

| Audit Category | Backlog Category |
|----------------|------------------|
| Security, Secrets | security |
| Tests (unit, integration, e2e) | tests |
| i18n, Accessibility | i18n |
| TODO/FIXME, Debt | debt |
| Requirements gaps | feature |
| Error handling | bug |

## CI Mode

When running non-interactively (CI):
- Generate report to temp file
- Skip capture prompt
- Exit with code 1 if critical/high findings exist

## Definition of Done

- All categories analyzed
- Report displayed on screen
- Report written to temp file
- User prompted for capture (interactive mode)
- Selected items added to backlog with fingerprints
