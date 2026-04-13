---
description: "Deep security scan? → CVE + OWASP + secrets + framework analysis → Scorecard + detailed findings"
agent: build
---

# Comprehensive Security Audit

A deep security analysis covering CVEs, OWASP Top 10, secrets scanning, and framework-specific attack vectors. Far more comprehensive than `/pro:audit.quality`'s basic security checks.

## Your Task

Execute a multi-layered security audit and generate both a scorecard and detailed findings report.

---

## Phase 1: Project Detection

Detect the project profile to enable targeted scanning:

### Package Managers (for CVE scanning)

| File | Ecosystem | Audit Tool |
|------|-----------|------------|
| package-lock.json | npm | `npm audit --json` |
| yarn.lock | Yarn | `yarn audit --json` |
| pnpm-lock.yaml | pnpm | `pnpm audit --json` |
| requirements.txt, Pipfile, pyproject.toml | Python | `pip-audit --format json` |
| Cargo.lock | Rust | `cargo audit --json` |
| Gemfile.lock | Ruby | `bundle-audit check --format json` |
| composer.lock | PHP | `composer audit --format json` |
| go.mod | Go | `govulncheck -json ./...` |

### Frameworks (for attack vector analysis)

| Detection | Framework | Priority Checks |
|-----------|-----------|-----------------|
| next.config.js, .next/ | Next.js | SSR data exposure, API route auth, middleware bypass |
| express in package.json | Express | helmet, rate limiting, CORS, session security |
| settings.py, manage.py | Django | DEBUG, SECRET_KEY, CSRF, SQL injection |
| config/application.rb | Rails | mass assignment, CSRF, SQL injection |
| react in package.json | React | XSS via dangerouslySetInnerHTML, API keys in bundle |
| vue in package.json | Vue | v-html XSS, template injection |
| pom.xml with spring | Spring Boot | actuator exposure, SpEL injection |
| fastapi in requirements | FastAPI | auth dependency, Pydantic bypass |

### Infrastructure Files

| File | Type | Checks |
|------|------|--------|
| Dockerfile | Container | root user, secrets in layers, base image CVEs |
| k8s/*.yaml, kubernetes/ | Kubernetes | privileged, network policies, RBAC |
| *.tf | Terraform | public buckets, open security groups |
| .github/workflows/*.yml | GitHub Actions | secrets exposure, injection in run |

Record what was detected for the report summary.

---

## Phase 2: CVE Scanning

For each detected package manager, run the corresponding audit tool.

### Execution Strategy

```bash
# Check tool availability before running
command -v npm &>/dev/null && npm audit --json 2>/dev/null
command -v pip-audit &>/dev/null && pip-audit --format json 2>/dev/null
# ... etc for each ecosystem
```

### Output Normalization

Normalize all CVE findings to this schema:

```json
{
  "id": "CVE-2024-XXXXX",
  "package": "lodash",
  "version": "4.17.20",
  "severity": "critical|high|medium|low",
  "cvss": 9.8,
  "title": "Remote Code Execution",
  "fix": "Upgrade to 4.17.21",
  "fingerprint": "cve|lodash|4.17.20|CVE-2024-XXXXX"
}
```

### Tool-Specific Parsing

**npm audit:**
```bash
npm audit --json | jq '.vulnerabilities | to_entries[] | {
  id: .value.via[0].url // "N/A",
  package: .key,
  severity: .value.severity,
  fix: .value.fixAvailable
}'
```

**pip-audit:**
```bash
pip-audit --format json | jq '.[] | {
  id: .vulns[].id,
  package: .name,
  version: .version,
  severity: .vulns[].fix_versions
}'
```

Record which tools ran and which were skipped (not installed).

---

## Phase 3: OWASP Top 10 Static Analysis

Analyze the codebase for OWASP Top 10 (2021) vulnerabilities:

### A01: Broken Access Control

**Patterns to detect:**
- Routes without authentication middleware
- Missing authorization checks on sensitive endpoints
- Direct object references without ownership validation
- Missing CORS configuration or overly permissive CORS

**Search examples:**
```bash
# Express routes without auth
grep -rn "app\.\(get\|post\|put\|delete\)" --include="*.ts" --include="*.js" | grep -v "auth\|middleware\|protect"

# Next.js API routes without session check
grep -rn "export.*function.*handler" pages/api/ --include="*.ts" | xargs -I{} grep -L "getSession\|getServerSession" {}
```

### A02: Cryptographic Failures

**Patterns to detect:**
- Weak algorithms: MD5, SHA1, DES, RC4
- Hardcoded encryption keys or IVs
- HTTP instead of HTTPS for sensitive data
- Missing TLS configuration
- Insecure random number generation

**Search examples:**
```bash
# Weak crypto
grep -rn "md5\|sha1\|des\|rc4\|Math\.random" --include="*.ts" --include="*.js" --include="*.py"

# Hardcoded keys
grep -rn "key.*=.*['\"][a-zA-Z0-9]{16,}['\"]" --include="*.ts" --include="*.js"
```

### A03: Injection

**Patterns to detect:**
- SQL: String concatenation in queries
- NoSQL: Unvalidated object in queries
- Command: exec(), spawn() with user input
- LDAP: Unescaped DN components
- XPath: String concatenation in XPath

**Search examples:**
```bash
# SQL injection
grep -rn "query.*\`.*\${" --include="*.ts" --include="*.js"
grep -rn "execute.*%s" --include="*.py"

# Command injection
grep -rn "exec(\|spawn(\|system(" --include="*.ts" --include="*.js" --include="*.py"
```

### A04: Insecure Design

**Patterns to detect:**
- Missing rate limiting on auth endpoints
- No input validation schema/library usage
- Missing CAPTCHA on sensitive forms
- Lack of account lockout mechanism

**Search examples:**
```bash
# Check for rate limiting libraries
grep -rn "express-rate-limit\|rate-limit\|throttle" package.json

# Check for validation libraries
grep -rn "joi\|yup\|zod\|class-validator" package.json
```

### A05: Security Misconfiguration

**Patterns to detect:**
- Debug mode enabled in production configs
- Default credentials in code
- Exposed error stack traces
- Unnecessary features enabled
- Missing security headers

**Search examples:**
```bash
# Debug flags
grep -rn "DEBUG.*=.*[Tt]rue\|NODE_ENV.*development" --include="*.env*" --include="*.ts" --include="*.py"

# Default credentials
grep -rn "password.*=.*['\"]admin\|password.*=.*['\"]123\|password.*=.*['\"]password" --include="*.ts" --include="*.js" --include="*.py"
```

### A06: Vulnerable Components

Covered by Phase 2 (CVE Scanning).

### A07: Identification and Authentication Failures

**Patterns to detect:**
- Weak password requirements
- Missing MFA implementation
- Session fixation vulnerabilities
- Credential exposure in logs

**Search examples:**
```bash
# Weak password validation
grep -rn "password.*length.*[<].*8\|minLength.*[<].*8" --include="*.ts" --include="*.js"

# Session configuration
grep -rn "session\|cookie" --include="*.ts" --include="*.js" | grep -i "secure\|httponly\|samesite"
```

### A08: Software and Data Integrity Failures

**Patterns to detect:**
- Insecure deserialization (pickle, yaml.load, eval)
- Missing integrity checks on downloads
- Unsigned CI/CD pipelines

**Search examples:**
```bash
# Insecure deserialization
grep -rn "pickle\.load\|yaml\.load\|eval(" --include="*.py"
grep -rn "JSON\.parse.*req\.\|deserialize" --include="*.ts" --include="*.js"
```

### A09: Security Logging and Monitoring Failures

**Patterns to detect:**
- Missing audit logging for auth events
- Sensitive data in logs (passwords, tokens)
- No alerting configuration

**Search examples:**
```bash
# Sensitive data in logs
grep -rn "console\.log.*password\|log.*token\|print.*secret" --include="*.ts" --include="*.js" --include="*.py"

# Check for logging libraries
grep -rn "winston\|pino\|bunyan\|logging" package.json requirements.txt
```

### A10: Server-Side Request Forgery (SSRF)

**Patterns to detect:**
- Unvalidated URLs in fetch/request calls
- User-controlled redirect targets
- Internal service URLs exposed

**Search examples:**
```bash
# URL from user input
grep -rn "fetch.*req\.\|axios.*req\.\|request.*req\." --include="*.ts" --include="*.js"
grep -rn "requests\.get.*request\.\|urllib.*request\." --include="*.py"
```

---

## Phase 4: Repository Secrets & Hygiene Audit

This phase delegates to `/pro:audit.repo` for comprehensive repository-level analysis.

Execute all checks from `/pro:audit.repo`:

1. **Secrets in Git History** - Full history scan using truffleHog/gitleaks
2. **Secrets in Current Files** - Pattern-based detection across source files
3. **Sensitive File Tracking** - Verify .gitignore covers sensitive patterns
4. **Environment File Audit** - .env/.env.example consistency
5. **CI/CD Secrets Hygiene** - Workflow files using proper secrets references
6. **Public Readiness Score** - Aggregate go/no-go assessment

Collect all findings with their fingerprints. The fingerprint formats from audit.repo are:

| Finding Type | Fingerprint Format |
|--------------|-------------------|
| Secret (current) | `{file}:{line}\|secret-{type}` |
| Secret (historical) | `git\|{commit}\|{file}\|secret-{type}` |
| Tracked sensitive file | `tracked\|{file}\|sensitive-file` |
| Missing gitignore pattern | `gitignore\|missing-{pattern}` |
| Env example issue | `.env.example:{line}\|real-value` |
| CI inline secret | `{workflow-file}:{line}\|ci-inline-secret` |

**Note:** When running as part of `/pro:audit.security`, audit.repo skips its own backlog capture phase - findings are collected here for the unified security report.

---

## Phase 5: Framework-Specific Analysis

Based on detected frameworks, run targeted security checks:

### Next.js

| Check | Pattern | Severity |
|-------|---------|----------|
| Data exposure in getServerSideProps | Returning sensitive data to client | High |
| API routes without auth | Missing getSession/getServerSession | High |
| Middleware bypass | Misconfigured matcher patterns | Medium |
| Image domain allow-all | domains: ['*'] in next.config | Low |

### Express

| Check | Pattern | Severity |
|-------|---------|----------|
| Missing helmet | No helmet() middleware | High |
| Missing rate limiting | No express-rate-limit | Medium |
| CORS allow-all | origin: '*' or origin: true | High |
| Body parser limits | Missing limit option | Medium |

### Django

| Check | Pattern | Severity |
|-------|---------|----------|
| DEBUG=True in prod settings | DEBUG = True | Critical |
| Hardcoded SECRET_KEY | SECRET_KEY = '...' (not env) | Critical |
| ALLOWED_HOSTS = ['*'] | Overly permissive hosts | High |
| Missing CSRF middleware | CsrfViewMiddleware not in MIDDLEWARE | High |

### React (Client-Side)

| Check | Pattern | Severity |
|-------|---------|----------|
| dangerouslySetInnerHTML | XSS risk | High |
| API keys in source | Exposed in bundle | Critical |
| eval() usage | Code injection risk | High |

Weight framework-specific findings +1 severity level when the framework is actually detected.

---

## Phase 6: Report Generation

### Security Score Calculation

```
Category scores (0-100):
score = max(0, 100 - (critical * 30 + high * 15 + medium * 5 + low * 2))

Category weights:
- CVE Scanning: 25%
- OWASP A01-A03 (Critical Security): 35% (split evenly)
- OWASP A04-A10: 25% (split evenly)
- Repository Secrets (from audit.repo): 15%

Overall = sum(category_score * weight)

Rating thresholds:
- 90-100: EXCELLENT
- 75-89: GOOD
- 50-74: NEEDS WORK
- 25-49: POOR
- 0-24: CRITICAL
```

### Output

1. Display scorecard summary on screen
2. Write full report to: `$TMPDIR/security-audit-{YYYY-MM-DD-HHmmss}.md`
3. Tell user: "Full report saved to {path}"

---

## Phase 7: Backlog Capture

1. Ask: "Would you like to capture any findings to the backlog?"

2. Present findings for selection:
   - Group by category (CVE, OWASP category, Repository/Secrets, Framework)
   - Sort by severity within category
   - Show severity badge: `[critical]`, `[high]`, `[medium]`, `[low]`
   - Nothing selected by default
   - Mark items already in backlog as non-selectable
   - Repository/Secrets includes all findings from audit.repo

3. Use `AskUserQuestion` with `multiSelect: true`

4. For each selected finding:
   - Generate fingerprint (see below)
   - Check against existing `doc/.plan/backlog.json`
   - Skip duplicates (inform user)
   - Add new items with:
     - `source: "/pro:audit.security"`
     - `sourceBranch: "{current branch}"`
     - `category: "security"`

### Fingerprint Formats

| Finding Type | Fingerprint Format |
|--------------|-------------------|
| CVE | `cve\|{package}\|{version}\|{cve-id}` |
| OWASP | `{file}:{line}-{line}\|owasp-{category}` |
| Framework | `{file}:{line}\|{framework}-{check}` |

**From audit.repo:**

| Finding Type | Fingerprint Format |
|--------------|-------------------|
| Secret (current) | `{file}:{line}\|secret-{type}` |
| Secret (historical) | `git\|{commit}\|{file}\|secret-{type}` |
| Tracked sensitive file | `tracked\|{file}\|sensitive-file` |
| Missing gitignore pattern | `gitignore\|missing-{pattern}` |
| Env example issue | `.env.example:{line}\|real-value` |
| CI inline secret | `{workflow-file}:{line}\|ci-inline-secret` |

---

## Graceful Degradation

When tools are unavailable:

1. **Log which scans were skipped** in the report
2. **Suggest installation** for missing tools:

```
Skipped Scans (tools not installed):
- pip-audit: Install with `pip install pip-audit`
- trufflehog: Install with `pip install trufflehog` or `brew install trufflehog`
- cargo audit: Install with `cargo install cargo-audit`
```

3. **Never fail the audit** due to missing tools - run what's available

---

## Definition of Done

- [ ] Project profile detected (package managers, frameworks, infra)
- [ ] CVE scan completed for all available package managers
- [ ] OWASP Top 10 static analysis completed
- [ ] Repository audit completed (via audit.repo):
  - [ ] Secrets scanned in current files
  - [ ] Secrets scanned in git history (if tools available)
  - [ ] Sensitive file tracking validated
  - [ ] Environment file audit completed
  - [ ] CI/CD secrets hygiene checked
- [ ] Framework-specific checks completed
- [ ] Security score calculated
- [ ] Scorecard displayed on screen
- [ ] Full report saved to temp file
- [ ] User prompted for backlog capture
- [ ] Selected findings added to backlog with fingerprints
