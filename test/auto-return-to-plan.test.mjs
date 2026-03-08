import test from "node:test"
import assert from "node:assert/strict"

import { shouldAutoReturnToPlan } from "../opencode/pro/plugins/auto-return-to-plan.js"

test("shouldAutoReturnToPlan: ignores non-message.updated events", () => {
  assert.equal(shouldAutoReturnToPlan({ type: "session.created" }), false)
})

test("shouldAutoReturnToPlan: ignores assistant messages", () => {
  assert.equal(
    shouldAutoReturnToPlan({
      type: "message.updated",
      properties: { info: { role: "assistant", agent: "build" } },
    }),
    false,
  )
})

test("shouldAutoReturnToPlan: ignores plan user messages", () => {
  assert.equal(
    shouldAutoReturnToPlan({
      type: "message.updated",
      properties: { info: { role: "user", agent: "plan" } },
    }),
    false,
  )
})

test("shouldAutoReturnToPlan: switches after build user messages", () => {
  assert.equal(
    shouldAutoReturnToPlan({
      type: "message.updated",
      properties: { info: { role: "user", agent: "build" } },
    }),
    true,
  )
})
