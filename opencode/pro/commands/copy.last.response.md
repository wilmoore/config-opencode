---
description: "Copy the most recent assistant response to the clipboard"
agent: build
---

## Your Task

Copy the most recent assistant response from this conversation (the last agent/model output you produced for the user) to the system clipboard.

Requirements:

- Copy the full response verbatim, preserving Markdown formatting and code fences.
- Do not include tool logs or tool output blocks.
- Use cross-platform clipboard detection.

### Step 1: Identify the payload

Look back through this conversation and extract the most recent assistant response intended for the user. Treat that response body as the payload.

If you cannot find a prior assistant response to copy, tell the user: "Nothing to copy yet." and stop.

### Step 2: Copy to clipboard

Use a single-quoted heredoc to preserve content safely:

```bash
# Use read to preserve trailing newlines (command substitution strips them).
IFS= read -r -d '' payload <<'__OPENCODE_CLIPBOARD_PAYLOAD__' || true
<PASTE THE MOST RECENT ASSISTANT RESPONSE VERBATIM HERE>
__OPENCODE_CLIPBOARD_PAYLOAD__

if command -v pbcopy >/dev/null 2>&1; then
  printf "%s" "$payload" | pbcopy
elif command -v wl-copy >/dev/null 2>&1; then
  printf "%s" "$payload" | wl-copy
elif command -v xclip >/dev/null 2>&1; then
  printf "%s" "$payload" | xclip -selection clipboard
elif command -v clip.exe >/dev/null 2>&1; then
  printf "%s" "$payload" | clip.exe
else
  echo "No clipboard utility found (pbcopy, wl-copy, xclip, clip.exe)." >&2
  exit 1
fi
```

### Step 3: Confirm

Tell the user: "Last response copied to clipboard."
