import test from "node:test"
import assert from "node:assert/strict"

import { applyPlanSafety, stripJsonc } from "../bin/enable-plan-safety.mjs"

test("stripJsonc: removes line and block comments", () => {
  const input = `{
    // comment
    "default_agent": "build", /* block */
    "agent": {
      "build": { "permission": { "edit": "allow" } },
    },
  }`

  const parsed = JSON.parse(stripJsonc(input))
  assert.equal(parsed.default_agent, "build")
  assert.equal(parsed.agent.build.permission.edit, "allow")
})

test("applyPlanSafety: sets default_agent and build permissions", () => {
  const { updated, changes } = applyPlanSafety({
    default_agent: "build",
    agent: { build: { permission: { edit: "allow", bash: "allow" } } },
  })

  assert.ok(changes.length > 0)
  assert.equal(updated.default_agent, "plan")
  assert.equal(updated.agent.build.permission.edit, "ask")
  assert.equal(updated.agent.build.permission.bash, "ask")
})

test("applyPlanSafety: preserves bash object rules but ensures '*' is ask", () => {
  const { updated } = applyPlanSafety({
    agent: {
      build: {
        permission: {
          bash: { "git status *": "allow" },
        },
      },
    },
  })

  assert.equal(updated.agent.build.permission.bash["*"], "ask")
  assert.equal(updated.agent.build.permission.bash["git status *"], "allow")
})
