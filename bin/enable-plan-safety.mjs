#!/usr/bin/env node

import fs from "node:fs"
import os from "node:os"
import path from "node:path"
import process from "node:process"
import { pathToFileURL } from "node:url"

const OPENCODE_DIR = process.env.OPENCODE_DIR || path.join(os.homedir(), ".config", "opencode")
const OPENCODE_CONFIG_PATH = path.join(OPENCODE_DIR, "opencode.json")

const DRY_RUN = process.env.ENABLE_PLAN_SAFETY_DRY_RUN === "1"

export function stripJsonc(input) {
  if (typeof input !== "string") return ""
  let out = ""
  let i = 0
  let inString = false
  let escaped = false

  while (i < input.length) {
    const ch = input[i]
    const next = input[i + 1]

    if (inString) {
      out += ch
      if (escaped) {
        escaped = false
      } else if (ch === "\\") {
        escaped = true
      } else if (ch === '"') {
        inString = false
      }
      i += 1
      continue
    }

    if (ch === '"') {
      inString = true
      out += ch
      i += 1
      continue
    }

    // line comment
    if (ch === "/" && next === "/") {
      i += 2
      while (i < input.length && input[i] !== "\n") i += 1
      continue
    }

    // block comment
    if (ch === "/" && next === "*") {
      i += 2
      while (i < input.length) {
        if (input[i] === "*" && input[i + 1] === "/") {
          i += 2
          break
        }
        i += 1
      }
      continue
    }

    out += ch
    i += 1
  }

  // Remove trailing commas outside of strings (safe enough post comment-strip).
  // eslint-disable-next-line no-useless-escape
  return out.replace(/,\s*([}\]])/g, "$1")
}

export function applyPlanSafety(config) {
  const updated = config && typeof config === "object" ? JSON.parse(JSON.stringify(config)) : {}
  const changes = []

  if (updated.default_agent !== "plan") {
    updated.default_agent = "plan"
    changes.push("set default_agent=plan")
  }

  if (!updated.agent || typeof updated.agent !== "object") updated.agent = {}
  if (!updated.agent.build || typeof updated.agent.build !== "object") updated.agent.build = {}
  if (!updated.agent.build.permission || typeof updated.agent.build.permission !== "object") {
    updated.agent.build.permission = {}
  }

  if (updated.agent.build.permission.edit !== "ask") {
    updated.agent.build.permission.edit = "ask"
    changes.push("set agent.build.permission.edit=ask")
  }

  const bashPermission = updated.agent.build.permission.bash
  if (bashPermission === undefined) {
    updated.agent.build.permission.bash = "ask"
    changes.push("set agent.build.permission.bash=ask")
  } else if (typeof bashPermission === "string") {
    if (bashPermission !== "ask") {
      updated.agent.build.permission.bash = "ask"
      changes.push("set agent.build.permission.bash=ask")
    }
  } else if (bashPermission && typeof bashPermission === "object") {
    if (bashPermission["*"] !== "ask") {
      const { "*": _ignored, ...rest } = bashPermission
      updated.agent.build.permission.bash = { "*": "ask", ...rest }
      changes.push("set agent.build.permission.bash['*']=ask")
    }
  }

  return { updated, changes }
}

function readConfigFile() {
  if (!fs.existsSync(OPENCODE_CONFIG_PATH)) {
    return { raw: null, config: {} }
  }
  const raw = fs.readFileSync(OPENCODE_CONFIG_PATH, "utf-8")
  const parsed = JSON.parse(stripJsonc(raw))
  return { raw, config: parsed }
}

function ensureDir() {
  if (!fs.existsSync(OPENCODE_DIR)) {
    fs.mkdirSync(OPENCODE_DIR, { recursive: true })
  }
}

function writeBackup(raw) {
  if (raw == null) return null
  const stamp = new Date().toISOString().replace(/[:.]/g, "-")
  const backupPath = path.join(OPENCODE_DIR, `opencode.json.bak.${stamp}`)
  fs.writeFileSync(backupPath, raw)
  return backupPath
}

function writeConfig(config) {
  const next = JSON.stringify(config, null, 2) + "\n"
  fs.writeFileSync(OPENCODE_CONFIG_PATH, next)
}

function printResult({ changes, backupPath }) {
  if (changes.length === 0) {
    console.log("Plan safety already enabled; no changes needed.")
    return
  }
  console.log("Enabled Plan safety rails:")
  for (const change of changes) {
    console.log(`- ${change}`)
  }
  if (backupPath) {
    console.log(`Backup written: ${backupPath}`)
  }
  console.log(`Config updated: ${OPENCODE_CONFIG_PATH}`)
}

async function main() {
  ensureDir()

  let state
  try {
    state = readConfigFile()
  } catch (error) {
    console.error(`Failed to parse ${OPENCODE_CONFIG_PATH} as JSON/JSONC.`)
    console.error("Tip: remove invalid JSONC syntax or run with a clean JSON file.")
    console.error(String(error instanceof Error ? error.message : error))
    process.exit(1)
  }

  if (DRY_RUN) {
    console.log("Dry-run: would enable Plan safety rails:")
    const { changes } = applyPlanSafety(state.config)
    for (const change of changes) {
      console.log(`- ${change}`)
    }
    console.log(`Dry-run note: backup would be written under ${OPENCODE_DIR}`)
    console.log(`Dry-run note: config file would be written to ${OPENCODE_CONFIG_PATH}`)
    process.exit(0)
  }

  const { updated, changes } = applyPlanSafety(state.config)

  if (changes.length === 0) {
    printResult({ changes, backupPath: null })
    process.exit(0)
  }

  const backupPath = state.raw ? writeBackup(state.raw) : null

  // Backup already written above; now write the updated config.
  writeConfig(updated)
  printResult({ changes, backupPath })
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  main()
}
