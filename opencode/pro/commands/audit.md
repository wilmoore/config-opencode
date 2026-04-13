---
description: "Full audit? → Runs quality + security audits → Combined report with unified scorecard"
agent: build
---

# Full Audit

Runs the complete audit suite: `/pro:audit.quality` + `/pro:audit.security`. Generates a unified report combining all findings.

## Your Task

Execute both audit commands and produce a combined report.

---

## Phase 1: Run Quality Audit

Execute all checks from `/pro:audit.quality`:

- Requirements coverage
- Unit tests
- Integration tests
- E2E tests
- Edge cases
- Error handling
- Documentation
- Production readiness (console.log, debugger, TODO/FIXME, hardcoded values, i18n, a11y)

Collect all findings with their fingerprints.

---

## Phase 2: Run Security Audit

Execute all checks from `/pro:audit.security`:

- **Project Detection**: Package managers, frameworks, infrastructure files
- **CVE Scanning**: Run available audit tools (npm/pip/cargo/etc.)
- **OWASP Top 10**: Static analysis for all categories
- **Repository Audit** (via `/pro:audit.repo`):
  - Secrets in current files + git history
  - .gitignore hygiene validation
  - Environment file audit
  - CI/CD secrets hygiene
  - Public readiness assessment
- **Framework Analysis**: Targeted checks for detected frameworks

Collect all findings with their fingerprints.

---

## Phase 3: Generate Combined Report

### Unified Scorecard

```
═══════════════════════════════════════════════════════════════════════════════
  FULL AUDIT REPORT                                            {project-name}
═══════════════════════════════════════════════════════════════════════════════

  Generated: {ISO 8601 timestamp}
  Branch: {current branch}
  Commit: {short SHA}

  ┌─────────────────────────────────────────────────────────────────────────┐
  │                                                                          │
  │   OVERALL SCORE: {score}/100                          {rating}           │
  │                                                                          │
  │   Quality: {q-score}/100    Security: {s-score}/100                      │
  │                                                                          │
  └─────────────────────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════════════════════════

  QUALITY AUDIT                                              Score: {q}/100
  ───────────────────────────────────────────────────────────────────────────

  Category                              Status       Findings
  ─────────────────────────────────────────────────────────────────────────
  Requirements Coverage                 {PASS/WARN/FAIL}   {n}
  Unit Tests                            {PASS/WARN/FAIL}   {n}
  Integration Tests                     {PASS/WARN/FAIL}   {n}
  E2E Tests                             {PASS/WARN/FAIL}   {n}
  Error Handling                        {PASS/WARN/FAIL}   {n}
  Documentation                         {PASS/WARN/FAIL}   {n}
  Production Readiness                  {PASS/WARN/FAIL}   {n}

═══════════════════════════════════════════════════════════════════════════════

  SECURITY AUDIT                                             Score: {s}/100
  ───────────────────────────────────────────────────────────────────────────

  Category                              Score      Status       Findings
  ─────────────────────────────────────────────────────────────────────────
  Dependency CVEs                       {xx}/100   {PASS/WARN/FAIL}   {n}
  OWASP A01 - Access Control            {xx}/100   {PASS/WARN/FAIL}   {n}
  OWASP A02 - Crypto Failures           {xx}/100   {PASS/WARN/FAIL}   {n}
  OWASP A03 - Injection                 {xx}/100   {PASS/WARN/FAIL}   {n}
  OWASP A04 - Insecure Design           {xx}/100   {PASS/WARN/FAIL}   {n}
  OWASP A05 - Misconfiguration          {xx}/100   {PASS/WARN/FAIL}   {n}
  OWASP A07 - Auth Failures             {xx}/100   {PASS/WARN/FAIL}   {n}
  OWASP A08 - Integrity Failures        {xx}/100   {PASS/WARN/FAIL}   {n}
  OWASP A09 - Logging Failures          {xx}/100   {PASS/WARN/FAIL}   {n}
  OWASP A10 - SSRF                      {xx}/100   {PASS/WARN/FAIL}   {n}
  Repository (audit.repo)               {xx}/100   {PASS/WARN/FAIL}   {n}
  Framework: {name}                     {xx}/100   {PASS/WARN/FAIL}   {n}

═══════════════════════════════════════════════════════════════════════════════
```

### Score Calculation

```
Quality Score = average of quality category pass rates (0-100)
Security Score = weighted security score per /pro:audit.security

Overall Score = (Quality Score * 0.4) + (Security Score * 0.6)

Rating thresholds:
- 90-100: EXCELLENT
- 75-89: GOOD
- 50-74: NEEDS WORK
- 25-49: POOR
- 0-24: CRITICAL
```

### Combined Findings

Merge all findings from both audits:
1. Group by severity (Critical → High → Medium → Low)
2. Within severity, group by source (Security vs Quality)
3. Deduplicate by fingerprint

```markdown
## All Findings

### Critical ({n})

#### [Security] {title}
...

#### [Quality] {title}
...

### High ({n})
...
```

---

## Phase 4: Output Report

1. Display unified scorecard on screen
2. Write full report to: `$TMPDIR/audit-full-{YYYY-MM-DD-HHmmss}.md`
3. Tell user: "Full report saved to {path}"

---

## Phase 5: Backlog Capture

Present ALL findings for selection (from both audits):

1. Ask: "Would you like to capture any findings to the backlog?"

2. Present findings grouped by source:
   ```
   Select items to capture:

   SECURITY FINDINGS
   [ ] [critical] CVE-2024-XXXXX in lodash
   [ ] [high] Missing auth on /api/users

   QUALITY FINDINGS
   [ ] [medium] Missing unit tests for auth flow
   [ ] [low] TODO: Refactor login component
   ```

3. Use `AskUserQuestion` with `multiSelect: true`

4. For each selected finding:
   - Check fingerprint against existing backlog
   - Skip duplicates (inform user)
   - Add with `source: "/pro:audit"` and `sourceBranch: "{current branch}"`
   - Use appropriate category (security vs tests/debt/feature)
   - Backlog path: `doc/.plan/backlog.json`

---

## When to Use Each Command

| Command | Use When |
|---------|----------|
| `/pro:audit` | Pre-release, comprehensive review, new team member onboarding |
| `/pro:audit.quality` | Quick completeness check during development |
| `/pro:audit.security` | Security-focused review, compliance prep, before public release |
| `/pro:audit.repo` | Quick public readiness check, .gitignore validation, secrets hygiene |

---

## Definition of Done

- [ ] Quality audit completed (all categories checked)
- [ ] Security audit completed (all available scans run)
  - [ ] Including repository audit (via audit.repo)
- [ ] Unified scorecard displayed
- [ ] Combined report saved to temp file
- [ ] User prompted for backlog capture
- [ ] Selected findings added to backlog with fingerprints
