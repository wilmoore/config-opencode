---
description: "Need clarifying questions on the clipboard? Gather the recent prompts and copy them as Markdown"
agent: build
---

## Your Task

Copy the most recent clarifying questions from this conversation to the clipboard.

### Step 1: Identify Questions

Look back through the recent conversation for clarifying questions you presented to the user. This includes:
- Questions shown in `AskUserQuestion` dialogs
- Questions asked in numbered or bulleted lists
- Any prompts seeking user input or clarification

### Step 2: Format and Copy

Format the questions as a Markdown list and copy to the system clipboard with cross-platform detection:

```bash
payload="## Clarifying Questions

- Question 1?
- Question 2?
- Question 3?
..."

if command -v pbcopy >/dev/null 2>&1; then
  printf "%s\n" "$payload" | pbcopy
elif command -v xclip >/dev/null 2>&1; then
  printf "%s\n" "$payload" | xclip -selection clipboard
elif command -v wl-copy >/dev/null 2>&1; then
  printf "%s\n" "$payload" | wl-copy
elif command -v clip.exe >/dev/null 2>&1; then
  printf "%s\n" "$payload" | clip.exe
else
  echo "No clipboard utility found (pbcopy, xclip, wl-copy, clip.exe)." >&2
  exit 1
fi
```

### Step 3: Confirm

Tell the user: "Clarifying questions copied to clipboard."

If no recent clarifying questions are found, inform the user.
