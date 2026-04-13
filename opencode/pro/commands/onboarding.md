# /pro:onboarding

## Purpose

Port the ccplugins onboarding command into OpenCode, providing a guided workflow for new users that aligns with OpenCode's conventions.

## Plan

1.  **Source:** The original ccplugins onboarding command specification is assumed to be similar to other ported commands, focusing on guiding users through initial setup and discovery of OpenCode features.
2.  **OpenCode Conventions:** New commands should be self-contained Markdown files under `opencode/pro/commands/`. They should leverage toolkit-native features like `/rules:*` and avoid reliance on external documentation or legacy namespaces.
3.  **Workflow:**
    *   Introduce OpenCode's core concepts and value proposition.
    *   Guide users through setting up their environment (e.g., config files, shell integrations).
    *   Provide entrypoints to key commands like `/pro:backlog`, `/pro:spec`, and `/rules:where`.
    *   Explain the role of the `doc/.plan/` directory for project artifacts.
    *   Emphasize safety rails and the Plan/Build modes.

## Implementation Notes

-   Refer to `doc/.plan/backlog.json` for the canonical list of OpenCode features and their status.
-   Ensure all commands mentioned are correctly namespaced (e.g., `/pro:*`).
-   Avoid referencing `CLAUDE.md` or any legacy documentation. Use `/rules:*` commands for guidance on rules and conventions.
