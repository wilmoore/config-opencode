import fs from 'node:fs'
import path from 'node:path'

const CANONICAL_PLAN_ROOT = 'doc/.plan'
const LEGACY_PLAN_ROOT = '.plan'

function resolveReadPath(...segments) {
  const canonicalPath = path.join(CANONICAL_PLAN_ROOT, ...segments)
  if (fs.existsSync(canonicalPath)) {
    return { path: canonicalPath, isLegacy: false }
  }

  const legacyPath = path.join(LEGACY_PLAN_ROOT, ...segments)
  if (fs.existsSync(legacyPath)) {
    return { path: legacyPath, isLegacy: true }
  }

  return null
}

function resolveWritePath(...segments) {
  return path.join(CANONICAL_PLAN_ROOT, ...segments)
}

function ensurePlanDir() {
  if (!fs.existsSync(CANONICAL_PLAN_ROOT)) {
    fs.mkdirSync(CANONICAL_PLAN_ROOT, { recursive: true })
  }
}

export const planRoot = {
  CANONICAL_PLAN_ROOT,
  LEGACY_PLAN_ROOT,

  read(...segments) {
    const resolved = resolveReadPath(...segments)
    if (!resolved) {
      return null
    }
    const content = fs.readFileSync(resolved.path, 'utf-8')
    return { content, isLegacy: resolved.isLegacy, path: resolved.path }
  },

  readJson(...segments) {
    const resolved = resolveReadPath(...segments)
    if (!resolved) {
      return null
    }
    const content = fs.readFileSync(resolved.path, 'utf-8')
    return { data: JSON.parse(content), isLegacy: resolved.isLegacy, path: resolved.path }
  },

  write(...segments) {
    ensurePlanDir()
    return resolveWritePath(...segments)
  },

  writeJson(...segments) {
    ensurePlanDir()
    const filePath = resolveWritePath(...segments)
    fs.writeFileSync(filePath, JSON.stringify(segments[segments.length - 1], null, 2))
    return filePath
  },

  exists(...segments) {
    return resolveReadPath(...segments) !== null
  },

  isLegacy(pathOrSegments) {
    if (typeof pathOrSegments === 'string') {
      return pathOrSegments.startsWith(LEGACY_PLAN_ROOT)
    }
    const resolved = resolveReadPath(...pathOrSegments)
    return resolved ? resolved.isLegacy : false
  },

  getBacklogPath() {
    return resolveWritePath('backlog.json')
  },

  getSessionHandoffDir() {
    return resolveWritePath('session-handoff')
  },

  getAdrIndexPath() {
    return resolveWritePath('adr-index.json')
  }
}
