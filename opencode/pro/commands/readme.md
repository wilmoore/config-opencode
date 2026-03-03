---
description: "Need a professional README? Analyze the repo, choose beautify vs. preserve, and ship polished docs"
agent: build
---

# README Generator & Beautifier

Create or update a README with explicit control over beautification. Supports two modes: full beautification for elite open-source quality, or light cleanup that preserves existing structure.

## Context

Target README: $ARGUMENTS (defaults to `./README.md` if not specified)

## Your Task

### Phase 0: Context Detection

Before asking questions, detect what needs documenting by analyzing the current state.

#### 0.1 Check Git Status

```bash
git status --porcelain
git diff --name-only HEAD~5 2>/dev/null || git diff --name-only
```

Identify:
- **New files** (untracked or recently added)
- **Modified files** (staged or unstaged changes)
- **Current branch** (feature branch suggests active work)

#### 0.2 Detect Undocumented Items

**For Claude Code Plugin Projects** (detected by `.claude-plugin/` directory):

1. List all command files:
   ```bash
   ls -1 */commands/*.md 2>/dev/null | grep -v readme.md
   ```

2. Parse the plugin's readme for documented commands (look for command table)

3. Compare: Find commands that exist as files but aren't in the readme

**For Other Projects:**

1. Check for new source files not mentioned in README
2. Check for new features in recent commits
3. Look for version bumps without changelog updates

#### 0.3 Auto-Determine Target

Based on findings, determine the appropriate action:

| Finding | Action |
|---------|--------|
| New command files undocumented | Target plugin readme, add to command table |
| New source files | Target root README, update project structure |
| No changes detected | Proceed to Phase 1 (full discovery) |

#### 0.4 Report Findings

If undocumented items found:

```
📋 Context Detection

Found undocumented changes:

Commands not in readme:
  + /pro:supabase.local (new)

Target: pro/readme.md
Action: Add new command to Commands table

Proceed with this update?
```

**If the action is clear and specific:**
- Present findings and proposed action
- Get confirmation to proceed
- Skip unnecessary mode selection (use Preserve mode for targeted updates)

**If no specific changes detected:**
- Proceed to Phase 1 (full discovery)
- Follow standard flow with mode selection

---

### Phase 1: Discovery

Analyze the project to understand the current state.

#### 1.1 Locate README Files

Search for README files in the project:

- `README.md`, `readme.md`, `README`, `README.txt` in project root
- README files in subdirectories (for monorepos)

Determine the target:
- If argument specifies a path, use that
- If only root README exists, use that
- If multiple READMEs exist and no argument, ask user which to target

#### 1.2 Detect Project Type

Analyze project metadata:

- **Package managers:** `package.json`, `Cargo.toml`, `go.mod`, `pyproject.toml`, `Gemfile`, `pom.xml`
- **Project category:** CLI tool, library, web application, API, monorepo
- **Tech stack:** Languages, frameworks, key dependencies
- **CI/CD:** `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`
- **Quality tools:** Test frameworks, coverage config, linters

#### 1.3 Analyze Existing README (if updating)

If a README exists, analyze:

- Current section structure
- Existing badges (URLs, types, validity)
- Links present (internal and external)
- Overall quality and completeness
- Areas that could be improved

#### 1.4 Gather Metadata

Collect from project files:

- Repository name and description
- License type
- Version information
- Maintainer/author info
- Contributing guidelines presence
- Changelog existence

**Report findings to user before proceeding.**

---

### Phase 2: Mode Selection

Present the user with a clear choice between modes.

#### For Existing README

```
📄 README Mode Selection

Your README currently has:
• [X] sections
• [Y] badges
• [Z] links

How would you like to proceed?

1. **Beautify** - Full enhancement
   Transform into a polished, modern README with curated badges,
   strong visual hierarchy, and confident language.
   ⚠️ May significantly change the current format.

2. **Preserve Structure** - Light cleanup only
   Keep your current layout. Only fix broken links,
   update outdated info, and make minor clarity improvements.
```

- Require explicit selection (no default for existing READMEs)
- Explain implications clearly

#### For New README (no existing file)

```
📄 Creating New README

No README.md found in this project.

Recommendation: **Beautify mode** for new READMEs.

This will create a polished, professional README with:
• Strong visual hierarchy
• Relevant badges for your project type
• Clear sections for installation, usage, and more

Proceed with Beautify mode?
```

- Recommend Beautify but still require confirmation

---

### Phase 3: Validation

Before making changes, validate the current state.

#### WebFetch Tool Reference

`WebFetch` is the built-in HTTP helper for this command. It performs outbound
requests without writing files.

- **Signature:** `WebFetch(url, {method: "GET", headers?: Record<string,string>, timeoutMs?: number})`
- **Response shape:**
  ```json
  {
    "status": 200,
    "contentType": "image/svg+xml",
    "headers": {"content-length": "1234", "location": "..."},
    "body": "<svg>...</svg>"
  }
  ```
- **Success behavior:** status `200-299` with populated `contentType`. Redirects
  (3xx) include a `location` header—follow those manually if needed. For badge
  checks, require `status` in the 200 range and `contentType` starting with
  `image/`.
- **Error behavior:**
  - Non-2xx statuses → treat as failure and record the HTTP code.
  - Timeouts/network errors → WebFetch throws; catch and mark the badge/link as
    unreachable with the error message.

Example badge validation snippet:

```bash
resp=$(WebFetch "$badge_url")
if [[ ${resp.status} -ge 200 && ${resp.status} -lt 300 && ${resp.contentType} == image/* ]]; then
  echo "Badge OK"
else
  echo "Badge broken (${resp.status})"
fi
```

#### 3.1 Badge Validation

For each badge in the existing README:

1. Extract the badge image URL
2. Use `WebFetch` to check if it returns a valid image
3. Identify:
   - ✅ Working badges
   - ❌ Broken badges (404, error responses)
   - ⚠️ Outdated badges (e.g., old version numbers)

#### 3.2 Link Validation

For all links in the README:

1. **Internal links:** Check if files/anchors exist
2. **External links:** Use `WebFetch` to verify they resolve
3. Categorize:
   - ✅ Working links
   - ❌ Broken links (404)
   - ↪️ Redirected links (may need updating)

#### 3.3 Present Findings

Show the user what was found:

```
🔍 Validation Results

Badges:
• 3 working
• 1 broken: [shields.io badge returning 404]
• 1 outdated: [version badge shows v1.0, current is v2.3]

Links:
• 12 working
• 2 broken:
  - ./docs/api.md (file not found)
  - https://old-docs.example.com (404)

What would you like to do with broken items?
```

**Get user decision for each broken item:**
- 🔧 Fix (provide correct URL)
- 🗑️ Remove
- ⏭️ Ignore

---

### Phase 4: Content Generation

Generate or update content based on selected mode.

#### 4.1 Beautify Mode

**Section Structure** (adapt to project type):

| Section | When to Include | Priority |
|---------|-----------------|----------|
| Title + Tagline | Always | Required |
| Badges | When relevant | High |
| Overview | Always | Required |
| Features | For apps/tools with multiple features | Medium |
| Installation | Always for installable projects | Required |
| Quick Start | When usage isn't obvious | High |
| Usage/Examples | Always | Required |
| Configuration | When configurable | Medium |
| API Reference | For libraries | Depends |
| Contributing | When accepting contributions | Medium |
| License | Always | Required |

**Badge Strategy:**

Propose badges based on project detection:

| Project Has | Suggest Badge |
|-------------|---------------|
| `package.json` | npm version |
| GitHub Actions | CI status |
| LICENSE file | License badge |
| Coverage config | Coverage badge |
| TypeScript | TypeScript badge |
| Published package | Downloads badge |

**Show each proposed badge and require approval:**

```
📛 Badge Recommendations

Based on your project, I recommend these badges:

1. ✅ npm version - [preview image]
   Shows current published version

2. ✅ CI Status - [preview image]
   Shows GitHub Actions build status

3. ❌ Coverage - Not detected
   Add coverage reporting to enable

Add these badges? [Yes to all / Review each / Skip badges]
```

**Content Quality:**

- Tighten language (remove filler, weak phrases)
- Use active voice
- Ensure consistent heading hierarchy
- Standardize code block formatting
- Add visual structure (spacing, horizontal rules where appropriate)
- Remove redundancy and clutter

#### 4.2 Preserve Mode

**Keep existing structure intact:**

- Same sections in same order
- Same heading styles
- Same overall format

**Apply only:**

- Broken link fixes (as approved in Phase 3)
- Outdated version numbers
- Factual corrections
- Minor grammar/clarity improvements
- Badge fixes only if explicitly approved

**Do NOT:**

- Reorder sections
- Change heading styles
- Add new sections
- Rewrite content for style
- Add badges without explicit request

---

### Phase 5: Review & Approval

Present all changes for user approval before applying.

#### 5.1 Diff Preview

Show what will change:

```
📝 Proposed Changes

## Sections
+ Added: Quick Start section
~ Modified: Installation section (updated commands)
- Removed: Outdated "Requirements" section (merged into Installation)

## Badges
+ Added: npm version badge
+ Added: CI status badge
~ Fixed: License badge URL

## Links
~ Fixed: 2 broken links
- Removed: 1 dead link (per your approval)

## Content
~ Tightened language in Overview
~ Standardized code block formatting
```

#### 5.2 Granular Approval

Allow user to accept or reject specific categories:

- [ ] Section changes
- [ ] Badge additions/changes
- [ ] Link fixes
- [ ] Content rewrites

```
Apply these changes?

[Apply All] [Review Each Category] [Cancel]
```

#### 5.3 Final Confirmation

Before writing:

```
Ready to update README.md

Summary:
• 2 sections added
• 3 badges added
• 2 links fixed
• Content polish applied

Proceed? [Yes / No / Show Full Preview]
```

---

### Phase 6: Application & Verification

#### 6.1 Apply Changes

- Write the updated README
- Preserve proper line endings
- Ensure valid markdown formatting

#### 6.2 Post-Application Validation

After writing:

1. Re-validate all links in the new README
2. Confirm no new broken links introduced
3. Verify markdown renders correctly

#### 6.3 Summary Report

```
✅ README Updated Successfully

Changes applied:
• Created polished structure with 8 sections
• Added 3 relevant badges
• Fixed 2 broken links
• Improved content clarity

File: ./README.md

The README now reflects the quality of a well-maintained open source project.
```

---

## Error Handling

| Scenario | Action |
|----------|--------|
| No README and no project context | Ask user for project description before generating |
| Network unavailable for validation | Skip live validation, warn user, proceed with syntax checks only |
| User declines all changes | Exit gracefully with "No changes made" message |
| Validation finds many broken links | Warn user, offer to proceed or abort |
| Write permission denied | Report error clearly, suggest remediation |

---

## Definition of Done

- [ ] User explicitly chose between Beautify and Preserve modes
- [ ] All validation completed (badges and links checked)
- [ ] User approved all changes before application
- [ ] README contains no broken links
- [ ] README is internally consistent
- [ ] README accurately represents the project
- [ ] If Beautify mode: README signals quality and professionalism
- [ ] User confirmed satisfaction with result
