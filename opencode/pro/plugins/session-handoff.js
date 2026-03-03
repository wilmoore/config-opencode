import { execSync } from "node:child_process"
import { mkdir, readFile, writeFile } from "node:fs/promises"
import { join } from "node:path"

const HANDOFF_RELATIVE_PATH = ".plan/session-handoff.md"
const BACKLOG_RELATIVE_PATH = ".plan/backlog.json"
const WRITE_INTERVAL_MS = 10000

const run = (command, cwd) => {
  try {
    return execSync(command, {
      cwd,
      encoding: "utf8",
      stdio: ["ignore", "pipe", "ignore"],
    }).trim()
  } catch {
    return ""
  }
}

const readBacklogSummary = async (root) => {
  try {
    const raw = await readFile(join(root, BACKLOG_RELATIVE_PATH), "utf8")
    const parsed = JSON.parse(raw)
    const items = Array.isArray(parsed.items) ? parsed.items : []
    const inProgress = items.filter((item) => item.status === "in-progress")
    if (inProgress.length === 0) return "- In-progress items: none"
    const latest = inProgress[inProgress.length - 1]
    return `- In-progress items: ${inProgress.length} (latest: ${latest.title ?? "untitled"})`
  } catch {
    return "- In-progress items: unknown (no readable backlog)"
  }
}

const buildContent = async ({ root, trigger }) => {
  const now = new Date().toISOString()
  const branch = run("git rev-parse --abbrev-ref HEAD", root) || "unknown"
  const shortStatus = run("git status --short", root)
  const workingTree = shortStatus === "" ? "clean" : "dirty"
  const recentCommit = run('git log -1 --pretty=format:"%h %s"', root) || "unknown"
  const backlogSummary = await readBacklogSummary(root)

  return `# Session Handoff

Updated: ${now}
Trigger: ${trigger}

## Current State

- Branch: \`${branch}\`
- Working tree: ${workingTree}
- Last commit: \`${recentCommit}\`
${backlogSummary}

## Resume Checklist

1. Open this repository in OpenCode.
2. Run \`make status\` to verify command links.
3. Type \`/pro:\` to confirm command availability.
4. Continue from active backlog item(s) in \`.plan/backlog.json\`.
`
}

export const ProSessionHandoff = async ({ worktree, directory }) => {
  const root = worktree || directory
  let lastWriteAt = 0

  const writeSnapshot = async (trigger) => {
    if (!root) return
    const now = Date.now()
    if (now - lastWriteAt < WRITE_INTERVAL_MS) return

    try {
      await mkdir(join(root, ".plan"), { recursive: true })
      const content = await buildContent({ root, trigger })
      await writeFile(join(root, HANDOFF_RELATIVE_PATH), content, "utf8")
      lastWriteAt = now
    } catch {
      // Best-effort only. Never fail session execution.
    }
  }

  await writeSnapshot("plugin.initialize")

  return {
    "session.created": async () => writeSnapshot("session.created"),
    "session.updated": async () => writeSnapshot("session.updated"),
    "session.idle": async () => writeSnapshot("session.idle"),
  }
}
