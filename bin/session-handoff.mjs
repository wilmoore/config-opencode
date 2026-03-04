#!/usr/bin/env node

import process from "node:process"
import {
  collectRepoState,
  createSnapshotEntry,
  describeSessionPath,
  ensureStructure,
  getPaths,
  loadIndex,
  saveIndex,
  writeLedger,
  writeSnapshotFile,
} from "../opencode/pro/lib/session-handoff.mjs"

const args = process.argv.slice(2)
const command = args.shift()
const root = process.cwd()
const paths = getPaths(root)

await ensureStructure(paths)
const index = await loadIndex(paths)
if (!Array.isArray(index.sessions)) {
  index.sessions = []
}

const printUsage = () => {
  console.log(`Usage: node bin/session-handoff.mjs <command> [options]

Commands:
  list [--all]               Show pending snapshots (or all with --all)
  write [--trigger text]     Capture a new snapshot for the current repo state
  ack <id> [--note text]     Mark a snapshot as complete
  dismiss <id> --reason text Dismiss a snapshot you no longer need
`)
}

const exitWithError = (message) => {
  console.error(message)
  printUsage()
  process.exit(1)
}

const popFlag = (flag) => {
  const indexOfFlag = args.indexOf(flag)
  if (indexOfFlag === -1) return undefined
  const value = args[indexOfFlag + 1]
  if (!value || value.startsWith("--")) {
    exitWithError(`Flag ${flag} requires a value`)
  }
  args.splice(indexOfFlag, 2)
  return value
}

const persist = async (currentId) => {
  await saveIndex(paths, index)
  await writeLedger(paths, index.sessions, { currentId })
}

const listSnapshots = (showAll = false) => {
  const sessions = showAll
    ? [...index.sessions]
    : index.sessions.filter((session) => session.status === "pending")

  if (sessions.length === 0) {
    console.log(showAll ? "No snapshots recorded." : "No pending snapshots.")
    return
  }

  sessions
    .sort((a, b) => (a.createdAt || "").localeCompare(b.createdAt || ""))
    .forEach((session) => {
      const location = describeSessionPath(session)
      console.log(`- ${session.id} [${session.status}] (${session.branch})`)
      console.log(`  File: ${location}`)
      console.log(`  Updated: ${session.updatedAt}`)
      if (session.status === "acknowledged" && session.note) {
        console.log(`  Note: ${session.note}`)
      }
      if (session.status === "dismissed" && session.dismissReason) {
        console.log(`  Dismissed: ${session.dismissReason}`)
      }
    })
}

const findSession = (id) => {
  const session = index.sessions.find((entry) => entry.id === id)
  if (!session) {
    exitWithError(`Unknown snapshot id: ${id}`)
  }
  return session
}

switch (command) {
  case "list": {
    const showAll = args.includes("--all")
    if (showAll) {
      args.splice(args.indexOf("--all"), 1)
    }
    listSnapshots(showAll)
    break
  }
  case "write": {
    const trigger = popFlag("--trigger") ?? "cli.write"
    if (args.length > 0) {
      exitWithError(`Unexpected args for write: ${args.join(" ")}`)
    }
    const metadata = await collectRepoState(root, paths)
    const entry = createSnapshotEntry({ metadata, trigger })
    index.sessions.push(entry)
    await writeSnapshotFile(paths, entry)
    await persist(entry.id)
    console.log(`Captured snapshot ${entry.id}: ${describeSessionPath(entry)}`)
    break
  }
  case "ack": {
    const id = args.shift()
    if (!id) exitWithError("Provide a snapshot id to acknowledge")
    const note = popFlag("--note")
    if (args.length > 0) {
      exitWithError(`Unexpected args for ack: ${args.join(" ")}`)
    }
    const session = findSession(id)
    const updatedAt = new Date().toISOString()
    session.status = "acknowledged"
    session.updatedAt = updatedAt
    session.acknowledgedAt = updatedAt
    if (note) session.note = note
    delete session.dismissedAt
    delete session.dismissReason
    await writeSnapshotFile(paths, session)
    await persist(id)
    console.log(`Acknowledged snapshot ${id}`)
    break
  }
  case "dismiss": {
    const id = args.shift()
    if (!id) exitWithError("Provide a snapshot id to dismiss")
    const reason = popFlag("--reason")
    if (!reason) exitWithError("Provide --reason when dismissing a snapshot")
    if (args.length > 0) {
      exitWithError(`Unexpected args for dismiss: ${args.join(" ")}`)
    }
    const session = findSession(id)
    const updatedAt = new Date().toISOString()
    session.status = "dismissed"
    session.updatedAt = updatedAt
    session.dismissedAt = updatedAt
    session.dismissReason = reason
    delete session.note
    delete session.acknowledgedAt
    await writeSnapshotFile(paths, session)
    await persist(id)
    console.log(`Dismissed snapshot ${id}`)
    break
  }
  case undefined:
    printUsage()
    process.exit(0)
    break
  default:
    exitWithError(`Unknown command: ${command}`)
}
