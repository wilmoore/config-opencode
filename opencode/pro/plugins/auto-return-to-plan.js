export function shouldAutoReturnToPlan(event) {
  if (!event || event.type !== "message.updated") return false
  const info = event.properties?.info
  if (!info || info.role !== "user") return false
  return info.agent === "build"
}

export const ProAutoReturnToPlan = async ({ client }) => {
  const seen = new Set()
  const fifo = []
  const MAX_SEEN = 200

  const markSeen = (id) => {
    if (!id || seen.has(id)) return false
    seen.add(id)
    fifo.push(id)
    if (fifo.length > MAX_SEEN) {
      const oldest = fifo.shift()
      if (oldest) seen.delete(oldest)
    }
    return true
  }

  const switchToPlan = async () => {
    if (!client?.tui?.executeCommand) return
    await client.tui.executeCommand({ body: { command: "agent.cycle" } })
    if (client?.tui?.showToast && process.env.OPENCODE_AUTO_RETURN_TO_PLAN_TOAST !== "0") {
      await client.tui.showToast({
        body: {
          message: "Auto-switched back to Plan (safety rail)",
          variant: "info",
          duration: 2500,
        },
      })
    }
  }

  return {
    "message.updated": async ({ event }) => {
      if (!shouldAutoReturnToPlan(event)) return
      const messageId = event.properties?.info?.id
      if (!markSeen(messageId)) return

      try {
        await switchToPlan()
      } catch {
        // Best-effort: TUI may not be available (e.g. `opencode run`).
      }
    },
  }
}
