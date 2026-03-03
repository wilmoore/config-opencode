---
description: "PR needs attention? Diagnose blockers, address every review comment, and fully resolve the thread list"
agent: build
---

Resolve every outstanding review thread on the current pull request. Nitpicks, suggestions, warnings, and blockers all receive equal weight.

## Workflow

### Phase 1: Discovery and Planning
1. **Get the PR number and metadata.**
   ```bash
   gh pr view --json number,title,url
   ```
2. **List ALL unresolved review threads and capture context.**
   ```bash
   owner="$(gh repo view --json owner -q .owner.login)"
   repo="$(gh repo view --json name -q .name)"
   number="$(gh pr view --json number -q .number)"
   cursor=""

   while :; do
     if [[ -z "$cursor" ]]; then
       cursor_flag=()
     else
       cursor_flag=(-F cursor="$cursor")
     fi

     page=$(gh api graphql \
       -f owner="$owner" \
       -f name="$repo" \
       -F number="$number" \
       "${cursor_flag[@]}" \
       -f query='query($owner: String!, $name: String!, $number: Int!, $cursor: String) {
         repository(owner: $owner, name: $name) {
           pullRequest(number: $number) {
             reviewThreads(first: 100, after: $cursor) {
               pageInfo {
                 hasNextPage
                 endCursor
               }
               nodes {
                 id
                 isResolved
                 comments(first: 1) {
                   nodes {
                     path
                     line
                     body
                   }
                 }
               }
             }
           }
         }
       }')

    echo "$page" | jq -r '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | "\(.id) \(.comments.nodes[0].path):\(.comments.nodes[0].line)"'

     has_next=$(echo "$page" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage')
     cursor=$(echo "$page" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor // ""')
     [[ "$has_next" == "true" && -n "$cursor" ]] || break
   done
   ```
3. **Create TodoWrite tracking entries for every unresolved thread.**
   ```bash
   TodoWrite "Fix review comment at src/components/Header.tsx:42 - align props" --status pending --priority high
   ```
   Keep the task list synchronized as you make progress.

### Phase 2: Fix Each Issue
For each unresolved comment:
1. Read the current code at that location.
2. Implement the suggested fix or improvement.
3. Verify the fix is correct.
4. Mark the TodoWrite item as completed.
5. Track which threads have been addressed.

### Phase 3: Quality Checks
- Run all quality checks (lint, type-check, tests, build).
- Fix any issues found.
- Commit all changes with a clear message listing what was fixed.

### Phase 4: Reply to All Comments
For each thread that was addressed, post a detailed reply explaining exactly what changed. Reference commit hashes or files when possible.

### Phase 5: Mark All Threads as Resolved
Resolve every review thread using the GraphQL mutation so GitHub reflects the status:
```bash
gh api graphql -F threadId="THE_THREAD_ID" -f query='mutation($threadId: ID!) {
  resolveReviewThread(input: {threadId: $threadId}) {
    thread {
      id
      isResolved
    }
  }
}'
```
Repeat for each thread ID captured during discovery.

### Phase 6: Final Verification
Verify **all** threads are resolved before exiting:
```bash
owner="$(gh repo view --json owner -q .owner.login)"
repo="$(gh repo view --json name -q .name)"
number="$(gh pr view --json number -q .number)"
cursor=""
printed=false

while :; do
  if [[ -z "$cursor" ]]; then
    cursor_flag=()
  else
    cursor_flag=(-F cursor="$cursor")
  fi

  page=$(gh api graphql \
    -f owner="$owner" \
    -f name="$repo" \
    -F number="$number" \
    "${cursor_flag[@]}" \
    -f query='query($owner: String!, $name: String!, $number: Int!, $cursor: String) {
      repository(owner: $owner, name: $name) {
        pullRequest(number: $number) {
          reviewThreads(first: 100, after: $cursor) {
            pageInfo {
              hasNextPage
              endCursor
            }
            nodes {
              id
              isResolved
            }
          }
        }
      }
    }')

  batch=$(echo "$page" | jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)]')
  if [[ "$batch" != "[]" ]]; then
    printed=true
    echo "$batch"
  fi

  has_next=$(echo "$page" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.hasNextPage')
  cursor=$(echo "$page" | jq -r '.data.repository.pullRequest.reviewThreads.pageInfo.endCursor // ""')
  [[ "$has_next" == "true" && -n "$cursor" ]] || break
done

if [[ "$printed" == false ]]; then
  echo "[]"
fi
```
If the script prints anything other than `[]`, you are **not** done—go back and resolve those threads.

Critical Requirements:

- ✅ Use TodoWrite to track all comments and mark them completed as you go.
- ✅ Do not skip ANY comment—address all of them.
- ✅ Reply to ALL comment threads with detailed explanations of fixes.
- ✅ Resolve ALL threads programmatically using the GraphQL mutation.
- ✅ Verify completion by confirming the verification query returns empty output.
- ✅ Do not stop until verification confirms ZERO unresolved threads.

Notes:

- Do not make judgment calls about which comments to address—address ALL of them.
- If a comment suggests an improvement, implement it.
- If it points out a potential issue, fix it.
- If it recommends a change, make it.
- If a comment was already addressed in a previous commit, verify the fix and still reply to the thread explaining it was already fixed.

Start by listing all unresolved comments with their file paths and line numbers using TodoWrite, then work through them one by one until the verification query returns empty output.
