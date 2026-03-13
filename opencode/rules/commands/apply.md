---
description: "Apply the latest Apply Pack produced by /rules:propose"
agent: build
---

## Context

Apply Pack changes are written only when leaving plan mode. This command performs the actual file writes.

Input: $ARGUMENTS

## Your Task

1. Identify the latest Apply Pack in the conversation (between `BEGIN APPLY PACK` and `END APPLY PACK`).
   - If $ARGUMENTS contains an Apply Pack, use it.
   - Otherwise, use the most recent one you produced.

2. Before writing:
   - Read `git config --get user.name` and `git config --get user.email`.
   - If email matches `*@users.noreply.github.com` or `*@noreply.github.com`, warn the user and ask for an override author identity for this apply.
   - Do not change git config automatically.

3. Apply the pack:
   - Validate every path before any write:
     - must be relative (no leading `/` or drive letters)
     - must not contain `..` segments
     - must resolve inside the workspace/project root after normalization
     - must be symlink-safe: resolve via `realpath` when available and reject any path that escapes the workspace/project root via symlinks
     - reject the pack if any path fails these rules
   - Create directories as needed.
   - Add files with the exact contents.
   - Update files exactly as instructed.

4. Verification:
   - Show which files were added/updated.
   - Run any requested checks listed in the pack (if present).

5. Confirm completion.
