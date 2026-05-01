# 012. Treat Deterministic Agent Switching as an Upstream Dependency

Date: 2026-05-01

## Status

Accepted

## Context

While auditing follow-up hardening work for the plan safety rail, we re-validated that OpenCode currently exposes `agent.cycle` but not a deterministic agent set-by-name API (for example `tui.agent.set`) or an equivalent current-agent primitive suitable for direct targeting.

The current safety behavior is deterministic only for the default two-primary-agent setup.

## Decision

Keep current behavior and track deterministic switching as blocked on upstream API support.

- Do not add speculative local workarounds for multi-agent deterministic switching yet.
- Preserve and document backlog follow-up tied to the upstream capability.

## Consequences

Positive:

- Avoids fragile hacks that could break when OpenCode internals change.
- Keeps the roadmap explicit about upstream dependency boundaries.

Negative:

- Users with customized multi-agent primary setups may still see non-deterministic return-to-plan behavior.
- A future migration step is required once upstream support exists.

## Alternatives Considered

- Implement custom local state tracking to infer and set the next target agent: rejected as brittle without official APIs.
- Defer documenting the limitation: rejected because it hides a known constraint and slows future remediation.

## Related

- Planning: `doc/.plan/.done/feat-port-pro-audit-quality-product/`
