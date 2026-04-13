---
description: "Ready to go public? → Secrets in history + .gitignore hygiene + env file audit → Public readiness score"
agent: build
---

# Repository Health Audit

A repository-level audit focused on secrets exposure, sensitive file hygiene, and public-readiness assessment. This is the **single source of truth** for secrets scanning - `/pro:audit.security` delegates to this command for secrets analysis.

## Your Task

Execute a comprehensive repository health audit and generate a public readiness assessment.

---

## Phase 1: Secrets in Git History

Scan the full git history for committed secrets, not just the current HEAD.

### Tool Detection

Check for available scanning tools:

```bash
# Prefer truffleHog (more comprehensive)
command -v trufflehog &>/dev/null && echo "trufflehog available"

# Fallback to gitleaks
command -v gitleaks &>/dev/null && echo "gitleaks available"
```

### Execution Strategy

**If truffleHog is available:**
```bash
trufflehog git file://. --json --no-update 2>/dev/null | head -100
```

**If gitleaks is available:**
```bash
gitleaks detect --source . --report-format json --report-path /dev/stdout 2>/dev/null | head -100
```

**If neither is available:**
- Log that history scan was skipped
- Fall back to current file scan only (Phase 1b)
- Suggest installation:
  ```
  Skipped: Git history secrets scan (no tool available)
  Install one of:
  - trufflehog: pip install trufflehog OR brew install trufflehog
  - gitleaks: brew install gitleaks OR go install github.com/gitleaks/gitleaks/v8@latest
  ```

### Current File Scan (Phase 1b)

Regardless of history scan availability, also scan current files using pattern matching:

**Patterns to detect:**

| Type | Regex Pattern |
|------|---------------|
| AWS Access Key | `AKIA[0-9A-Z]{16}` |
| AWS Secret Key | `(?i)aws_secret_access_key.*['\"][0-9a-zA-Z/+=]{40}['\"]` |
| GitHub Token | `ghp_[a-zA-Z0-9]{36}` |
| GitHub OAuth | `gho_[a-zA-Z0-9]{36}` |
| GitHub App Token | `ghu_[a-zA-Z0-9]{36}` |
| GitHub Refresh Token | `ghr_[a-zA-Z0-9]{36}` |
| Generic API Key | `(?i)(api[_-]?key|apikey)\s*[:=]\s*['\"][a-zA-Z0-9]{20,}['\"]` |
| Generic Secret | `(?i)(secret|password|passwd|pwd)\s*[:=]\s*['\"][^'\"]{8,}['\"]` |
| Private Key Header | `-----BEGIN (RSA|DSA|EC|OPENSSH|PGP) PRIVATE KEY-----` |
| Connection String | `(mongodb|postgres|postgresql|mysql|redis|amqp)://[^:]+:[^@]+@` |
| JWT Secret | `(?i)jwt[_-]?(secret|key)\s*[:=]\s*['\"][^'\"]+['\"]` |
| Slack Token | `xox[baprs]-[0-9a-zA-Z-]+` |
| Stripe Key | `sk_live_[0-9a-zA-Z]{24,}` |
| SendGrid Key | `SG\.[a-zA-Z0-9_-]{22}\.[a-zA-Z0-9_-]{43}` |

**Files to scan:**
- All source files: `*.ts`, `*.js`, `*.py`, `*.go`, `*.rb`, `*.java`, `*.php`
- Configuration files: `*.json`, `*.yaml`, `*.yml`, `*.toml`, `*.ini`
- Environment files: `.env*` (except `.env.example`)
- CI/CD files: `.github/workflows/*`, `.gitlab-ci.yml`, `Jenkinsfile`

**Files to exclude:**
- `node_modules/`, `vendor/`, `.git/`, `dist/`, `build/`
- Lock files: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- Test fixtures with obvious fake values

### Output Schema

Normalize all findings to:

```json
{
  "type": "secret",
  "secretType": "aws-access-key|github-token|generic-api-key|...",
  "file": "path/to/file",
  "line": 42,
  "commit": "abc1234",
  "isHistorical": false,
  "severity": "critical|high|medium",
  "fingerprint": "file:line|secret-type OR git|commit|file|secret-type"
}
```

### Severity Classification

| Finding | Severity |
|---------|----------|
| Secret currently exposed in tracked file | Critical |
| Secret in git history (removed from HEAD) | High |
| Potential secret (pattern match, may be false positive) | Medium |

---

## Phase 2: Sensitive File Tracking

Check if sensitive files are being tracked by git when they shouldn't be.

### Check for Tracked Sensitive Files

```bash
# List tracked files that match sensitive patterns
git ls-files | grep -E '\.(env|pem|key|p12|pfx|secret)$|credentials\.json|secrets\.(json|yaml|yml)$'
```

If any matches are found, these are **Critical** findings - sensitive files should not be tracked.

### Validate .gitignore Coverage

Read `.gitignore` (if it exists) and check for presence of these patterns:

**Required patterns for sensitive files:**

| Category | Expected Patterns |
|----------|-------------------|
| Environment | `.env`, `.env.*`, `!.env.example` |
| Keys | `*.pem`, `*.key`, `*.p12`, `*.pfx` |
| Credentials | `credentials.json`, `secrets.*`, `*.secret` |
| Cloud | `.aws/`, `.gcloud/`, `.azure/` |
| SSH | `id_rsa`, `id_dsa`, `id_ecdsa`, `id_ed25519` |
| IDE/Local | `.idea/`, `.vscode/settings.json` (if contains secrets) |

**Analysis:**
1. Read `.gitignore` file
2. Check which patterns are present vs missing
3. For missing patterns, check if any matching files exist in the repo
4. Only flag as issue if pattern is missing AND matching files could exist

### Output

Report:
- Which sensitive file patterns are covered by `.gitignore`
- Which patterns are missing
- Any sensitive files currently tracked (critical)

---

## Phase 3: Environment File Audit

Verify `.env` and `.env.example` consistency and safety.

### Checks

1. **Is .env gitignored?**
   ```bash
   git check-ignore .env && echo "OK: .env is gitignored"
   ```

2. **Does .env.example exist?**
   - If project has `.env` but no `.env.example`, flag as warning (no template for developers)

3. **Does .env.example contain actual values?**

   Read `.env.example` and check each line:
   - Empty value (`KEY=` or `KEY=""`) → OK (placeholder)
   - Placeholder value (`KEY=your_api_key_here`, `KEY=xxx`, `KEY=changeme`) → OK
   - Actual-looking value (`KEY=sk_live_abc123...`) → **Warning** (may be real secret)

   **Patterns indicating placeholder (OK):**
   - Empty: `^[A-Z_]+=\s*$`
   - Explicit placeholder: `your_.*_here`, `xxx+`, `changeme`, `replace_me`, `TODO`, `FIXME`
   - Example format: `example\.com`, `localhost`, `127\.0\.0\.1`

   **Patterns indicating real value (Warning):**
   - Matches secret patterns from Phase 1
   - Long alphanumeric strings (20+ chars)
   - Base64-looking values

4. **Are all .env keys documented in .env.example?**

   If both files exist, compare keys:
   ```bash
   # Extract keys from .env
   grep -E '^[A-Z_]+=' .env | cut -d= -f1 | sort > /tmp/env_keys

   # Extract keys from .env.example
   grep -E '^[A-Z_]+=' .env.example | cut -d= -f1 | sort > /tmp/example_keys

   # Find keys in .env but not in .env.example
   comm -23 /tmp/env_keys /tmp/example_keys
   ```

   Missing keys = Warning (developers won't know they need these)

---

## Phase 4: CI/CD Secrets Hygiene

Analyze GitHub Actions (and other CI) configuration for secrets handling.

### GitHub Actions Analysis

For each file in `.github/workflows/*.yml`:

1. **Check for hardcoded secrets**

   Look for patterns that should use `${{ secrets.* }}` instead:
   ```yaml
   # BAD - hardcoded
   env:
     API_KEY: "sk_live_abc123..."

   # GOOD - using secrets
   env:
     API_KEY: ${{ secrets.API_KEY }}
   ```

2. **Check for secrets in `run` commands**

   Look for inline credentials:
   ```yaml
   # BAD
   run: curl -H "Authorization: Bearer abc123" ...

   # GOOD
   run: curl -H "Authorization: Bearer ${{ secrets.TOKEN }}" ...
   ```

3. **Check environment variable exposure**

   Flag if secrets are echoed or logged:
   ```yaml
   # BAD
   run: echo ${{ secrets.TOKEN }}
   run: printenv | grep TOKEN
   ```

### Other CI Systems

If detected, apply similar analysis:
- `.gitlab-ci.yml` - check for hardcoded variables
- `Jenkinsfile` - check for credentials in plain text
- `.circleci/config.yml` - check for hardcoded env vars

### Severity

| Finding | Severity |
|---------|----------|
| Hardcoded secret in workflow file | Critical |
| Secret potentially logged/echoed | High |
| Missing secrets reference (uses plain env var) | Medium |

---

## Phase 5: Public Readiness Score

Aggregate all findings into a go/no-go recommendation for making the repository public.

### Scoring Logic

```
Public Readiness = based on finding severity counts

CRITICAL findings (any) → ❌ DO NOT MAKE PUBLIC
HIGH findings (any) → ⚠️ REVIEW RECOMMENDED
MEDIUM only → ⚠️ REVIEW RECOMMENDED
No findings → ✅ SAFE TO BE PUBLIC
```

### Detailed Criteria

| Status | Criteria |
|--------|----------|
| ❌ DO NOT MAKE PUBLIC | Any: secrets in current files, tracked sensitive files, hardcoded CI secrets |
| ⚠️ REVIEW RECOMMENDED | Any: secrets in history only, missing .gitignore patterns, .env.example issues |
| ✅ SAFE TO BE PUBLIC | No findings across all checks |

---

## Phase 6: Report Generation

### Report Template

```
Repository Audit: {project-name}
══════════════════════════════════════════════════════════════════════════

  Generated: {ISO 8601 timestamp}
  Branch: {current branch}
  Commit: {short SHA}

  ┌────────────────────────────────────────────────────────────────────┐
  │                                                                     │
  │   PUBLIC READINESS: {✅/⚠️/❌} {SAFE TO BE PUBLIC/REVIEW/DO NOT}     │
  │                                                                     │
  └────────────────────────────────────────────────────────────────────┘

══════════════════════════════════════════════════════════════════════════

  SUMMARY
  ────────────────────────────────────────────────────────────────────────
  Total Findings: {n}
  Critical: {n} | High: {n} | Medium: {n}

══════════════════════════════════════════════════════════════════════════

  CHECK RESULTS
  ────────────────────────────────────────────────────────────────────────

  Secrets in History .......................... {✅ PASS / ⚠️ WARN / ❌ FAIL}
    {details or "No secrets found in git history"}
    {if skipped: "Skipped: Install trufflehog or gitleaks for history scan"}

  Secrets in Current Files .................... {✅ PASS / ⚠️ WARN / ❌ FAIL}
    {details or "No secrets found in current files"}

  Sensitive Files ............................. {✅ PASS / ⚠️ WARN / ❌ FAIL}
    {.gitignore coverage: X/Y patterns covered}
    {any tracked sensitive files listed}

  Environment Files ........................... {✅ PASS / ⚠️ WARN / ❌ FAIL}
    {.env gitignored: yes/no}
    {.env.example: exists/missing}
    {any issues with .env.example values}

  CI/CD Secrets ............................... {✅ PASS / ⚠️ WARN / ❌ FAIL}
    {workflow files analyzed: n}
    {issues found or "All secrets properly referenced"}

══════════════════════════════════════════════════════════════════════════

  FINDINGS
  ────────────────────────────────────────────────────────────────────────

  {If any findings, list by severity}

  ### Critical ({n})

  #### {title}
  - **File:** {path}:{line}
  - **Type:** {secret-type}
  - **Description:** {details}
  - **Fingerprint:** {fingerprint}

  ### High ({n})
  ...

  ### Medium ({n})
  ...

══════════════════════════════════════════════════════════════════════════

  RECOMMENDATIONS
  ────────────────────────────────────────────────────────────────────────

  {Prioritized list of actions to address findings}

  1. {Most critical action}
  2. {Next action}
  ...

══════════════════════════════════════════════════════════════════════════

  SKIPPED SCANS
  ────────────────────────────────────────────────────────────────────────

  {List any scans that were skipped due to missing tools}

  - {scan name}: {reason} - Install with: {command}

══════════════════════════════════════════════════════════════════════════
```

### Output

1. Display summary (Public Readiness status + finding counts) on screen
2. Write full report to: `$TMPDIR/repo-audit-{YYYY-MM-DD-HHmmss}.md`
3. Tell user: "Full report saved to {path}"

---

## Phase 7: Backlog Capture

Offer to capture findings to the backlog.

### Process

1. Ask: "Would you like to capture any findings to the backlog?"

2. Present findings for selection:
   ```
   Select items to capture:

   CRITICAL
   [ ] [critical] AWS Access Key exposed in config/settings.py:42
   [ ] [critical] Tracked .env file contains secrets

   HIGH
   [ ] [high] GitHub token in git history (commit abc1234)
   [ ] [high] Missing .gitignore patterns: *.pem, *.key

   MEDIUM
   [ ] [medium] .env.example may contain real API key at line 15
   ```

3. Use `AskUserQuestion` with `multiSelect: true`

4. For each selected finding:
   - Generate fingerprint (see below)
   - Check against existing `doc/.plan/backlog.json`
   - Skip duplicates (inform user)
   - Add new items with:
     - `source: "/pro:audit.repo"`
     - `sourceBranch: "{current branch}"`
     - `category: "security"`

### Fingerprint Formats

| Finding Type | Fingerprint Format |
|--------------|-------------------|
| Secret (current file) | `{file}:{line}\|secret-{type}` |
| Secret (historical) | `git\|{commit}\|{file}\|secret-{type}` |
| Tracked sensitive file | `tracked\|{file}\|sensitive-file` |
| Missing gitignore pattern | `gitignore\|missing-{pattern}` |
| Env example value issue | `.env.example:{line}\|real-value` |
| CI inline secret | `{workflow-file}:{line}\|ci-inline-secret` |

---

## Graceful Degradation

When tools are unavailable:

1. **Log which scans were skipped** in the report
2. **Suggest installation** for missing tools
3. **Never fail the audit** - run what's available

### Tool Availability Matrix

| Tool | Purpose | Fallback |
|------|---------|----------|
| trufflehog | Git history scan | Try gitleaks |
| gitleaks | Git history scan | Current file patterns only |
| git | All checks | Required - fail if missing |

---

## When Called by audit.security

When invoked as part of `/pro:audit.security`:
- Skip the backlog capture phase (audit.security handles this)
- Return findings in normalized format for inclusion in security report
- Include all check results for the unified scorecard

---

## Definition of Done

- [ ] Secrets scanned in current files (always)
- [ ] Secrets scanned in git history (if tools available)
- [ ] Sensitive file tracking analyzed
- [ ] .gitignore coverage validated
- [ ] Environment file audit completed
- [ ] CI/CD secrets hygiene checked
- [ ] Public readiness score calculated
- [ ] Report displayed and saved
- [ ] User prompted for backlog capture (standalone mode)
