import {
  applyMetadata,
  collectRepoState,
  createSnapshotEntry,
  ensureStructure,
  getPaths,
  loadIndex,
  saveIndex,
  writeLedger,
  writeSnapshotFile,
} from "../lib/session-handoff.mjs"

export const ProSessionHandoff = async ({ worktree, directory }) => {
  const root = worktree || directory
  if (!root) return {}

  const paths = getPaths(root)
  await ensureStructure(paths)
  const index = await loadIndex(paths)
  if (!Array.isArray(index.sessions)) index.sessions = []

  let currentEntry
  let promptShown = false

  const showPrompt = () => {
    if (promptShown) return
    promptShown = true
    const outstanding = index.sessions.filter((session) => session.status === "pending")
    if (outstanding.length === 0) {
      console.info("[session-handoff] No pending session snapshots.")
      return
    }
    const ids = outstanding.map((session) => session.id).join(", ")
    console.info(`[session-handoff] Pending snapshots: ${ids}`)
    console.info("[session-handoff] Review doc/.plan/session-handoff.md or run /pro:session.handoff to handle them.")
  }

  const persist = async () => {
    await saveIndex(paths, index)
    await writeLedger(paths, index.sessions, { currentId: currentEntry?.id ?? null })
  }

  const refreshSnapshot = async (trigger) => {
    if (!root) return
    try {
      const metadata = await collectRepoState(root, paths)
      if (!currentEntry) {
        currentEntry = createSnapshotEntry({ metadata, trigger })
        index.sessions.push(currentEntry)
      } else {
        applyMetadata(currentEntry, metadata, trigger)
      }
      await writeSnapshotFile(paths, currentEntry)
      await persist()
    } catch {
      // best-effort only
    }
  }

  showPrompt()
  await refreshSnapshot("plugin.initialize")

  return {
    "session.created": async () => refreshSnapshot("session.created"),
    "session.updated": async () => refreshSnapshot("session.updated"),
    "session.idle": async () => refreshSnapshot("session.idle"),
  }
}
