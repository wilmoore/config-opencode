import { execSync } from "node:child_process"
import { mkdir, readFile, writeFile } from "node:fs/promises"
import { join, posix } from "node:path"
import { randomUUID } from "node:crypto"

const HANDOFF_DIR = ".plan/session-handoff"
const SUMMARY_FILENAME = ".plan/session-handoff.md"
const BACKLOG_FILENAME = ".plan/backlog.json"
const INDEX_TEMPLATE = { version: 1, sessions: [] }

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

const toPosix = (value) => value.replace(/\\/g, "/")

export const getPaths = (root) => ({
  root,
  planDir: join(root, ".plan"),
  handoffDir: join(root, HANDOFF_DIR),
  sessionsDir: join(root, HANDOFF_DIR, "sessions"),
  archiveDir: join(root, HANDOFF_DIR, "archive"),
  indexPath: join(root, HANDOFF_DIR, "index.json"),
  summaryPath: join(root, SUMMARY_FILENAME),
  backlogPath: join(root, BACKLOG_FILENAME),
})

export const ensureStructure = async (paths) => {
  await mkdir(paths.planDir, { recursive: true })
  await mkdir(paths.handoffDir, { recursive: true })
  await mkdir(paths.sessionsDir, { recursive: true })
  await mkdir(paths.archiveDir, { recursive: true })
}

const cloneTemplate = () => ({
  version: INDEX_TEMPLATE.version,
  sessions: [],
})

export const loadIndex = async (paths) => {
  try {
    const raw = await readFile(paths.indexPath, "utf8")
    const parsed = JSON.parse(raw)
    return {
      version: INDEX_TEMPLATE.version,
      sessions: Array.isArray(parsed.sessions) ? parsed.sessions : [],
    }
  } catch {
    return cloneTemplate()
  }
}

export const saveIndex = async (paths, index) => {
  const payload = {
    version: INDEX_TEMPLATE.version,
    sessions: Array.isArray(index.sessions) ? index.sessions : [],
  }
  await writeFile(paths.indexPath, `${JSON.stringify(payload, null, 2)}\n`, "utf8")
}

const readBacklogSummary = async (paths) => {
  try {
    const raw = await readFile(paths.backlogPath, "utf8")
    const parsed = JSON.parse(raw)
    const items = Array.isArray(parsed.items) ? parsed.items : []
    const inProgress = items.filter((item) => item?.status === "in-progress")
    if (inProgress.length === 0) return "- In-progress items: none"
    const latest = inProgress[inProgress.length - 1]
    return `- In-progress items: ${inProgress.length} (latest: ${latest?.title ?? "untitled"})`
  } catch {
    return "- In-progress items: unknown (no readable backlog)"
  }
}

export const collectRepoState = async (root, paths) => {
  const now = new Date().toISOString()
  const branch = run("git rev-parse --abbrev-ref HEAD", root) || "unknown"
  const status = run("git status --short", root)
  const workingTree = status === "" ? "clean" : "dirty"
  const recentCommit = run('git log -1 --pretty=format:"%h %s"', root) || "unknown"
  const backlogSummary = await readBacklogSummary(paths)
  return { now, branch, workingTree, recentCommit, backlogSummary }
}

const safeId = (timestamp) => timestamp.replace(/[:.]/g, "-")

export const createSnapshotEntry = ({ metadata, trigger }) => {
  const id = `session-${safeId(metadata.now)}-${randomUUID().slice(0, 8)}`
  const filename = `${id}.md`
  const relativePath = toPosix(posix.join("sessions", filename))
  return applyMetadata({
    id,
    filename,
    relativePath,
    status: "pending",
    createdAt: metadata.now,
    updatedAt: metadata.now,
    trigger,
  }, metadata, trigger)
}

export const applyMetadata = (entry, metadata, trigger) => {
  entry.updatedAt = metadata.now
  entry.branch = metadata.branch
  entry.workingTree = metadata.workingTree
  entry.recentCommit = metadata.recentCommit
  entry.backlogSummary = metadata.backlogSummary
  if (typeof trigger !== "undefined") {
    entry.trigger = trigger
  }
  return entry
}

const describeRelativePath = (entry) => toPosix(posix.join(HANDOFF_DIR, entry.relativePath))

const sessionHeader = (entry) => `# Session Handoff Snapshot

ID: ${entry.id}
Status: ${entry.status}
Created: ${entry.createdAt}
Updated: ${entry.updatedAt}
Trigger: ${entry.trigger}

## Current State

- Branch: \`${entry.branch}\`
- Working tree: ${entry.workingTree}
- Last commit: \`${entry.recentCommit}\`
${entry.backlogSummary ?? "- In-progress items: unknown"}

## Next Steps

1. Review the outstanding checklist stored in this file.
2. Once complete, acknowledge the snapshot:
   \`\`\`bash
   node bin/session-handoff.mjs ack ${entry.id}
   \`\`\`
3. If the work is obsolete, dismiss it instead:
   \`\`\`bash
   node bin/session-handoff.mjs dismiss ${entry.id} --reason "why"
   \`\`\`
`

const ensureTrailingNewline = (text) => (text.endsWith("\n") ? text : `${text}\n`)

export const writeSnapshotFile = async (paths, entry) => {
  const absolute = join(paths.handoffDir, entry.relativePath)
  await mkdir(join(paths.handoffDir, "sessions"), { recursive: true })
  await writeFile(absolute, ensureTrailingNewline(sessionHeader(entry)), "utf8")
}

const formatSessionLine = (session, index) => {
  const location = describeRelativePath(session)
  const note = session.status === "dismissed" && session.dismissReason
    ? ` (dismissed: ${session.dismissReason})`
    : session.status === "acknowledged" && session.note
      ? ` (note: ${session.note})`
      : ""
  const suffix = note ? `${note}` : ""
  return `${index}. [${session.status}] ${session.id} — ${session.branch} (${session.workingTree})\n   File: ${location}\n   Updated: ${session.updatedAt}${suffix}`
}

const buildLedger = (sessions, { currentId }) => {
  const now = new Date().toISOString()
  const outstanding = sessions
    .filter((session) => session.status === "pending")
    .sort((a, b) => (a.createdAt || "").localeCompare(b.createdAt || ""))
  const resolved = sessions
    .filter((session) => session.status !== "pending")
    .sort((a, b) => (b.updatedAt || "").localeCompare(a.updatedAt || ""))
    .slice(0, 5)

  const outstandingSection = outstanding.length
    ? outstanding.map((session, index) => formatSessionLine(session, index + 1)).join("\n\n")
    : "- None"

  const recentSection = resolved.length
    ? resolved.map((session, index) => formatSessionLine(session, index + 1)).join("\n\n")
    : "- None"

  return `# Session Handoff Ledger

Updated: ${now}
Current session: ${currentId ?? "n/a"}

## Outstanding Snapshots (${outstanding.length})

${outstandingSection}

## Recent Activity

${recentSection}

## Commands

- \`node bin/session-handoff.mjs list\` — show pending snapshots
- \`node bin/session-handoff.mjs ack <id> [--note "done"]\` — mark complete
- \`node bin/session-handoff.mjs dismiss <id> --reason "why"\` — abandon work
- \`node bin/session-handoff.mjs write --trigger "/pro:session.handoff"\` — capture a fresh snapshot

All snapshots live under \`.plan/session-handoff/sessions/\`. Review each file before acknowledging or dismissing it.`
}

export const writeLedger = async (paths, sessions, { currentId } = {}) => {
  const content = ensureTrailingNewline(buildLedger(Array.isArray(sessions) ? sessions : [], { currentId }))
  await writeFile(paths.summaryPath, content, "utf8")
}

export const describeSessionPath = (session) => describeRelativePath(session)
