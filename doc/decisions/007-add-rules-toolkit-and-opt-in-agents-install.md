# 007. Add /rules Toolkit Commands and Opt-in AGENTS Install

Date: 2026-03-10

## Status

Accepted

## Context

As the repository accumulated more guidance in `AGENTS.md`/`CLAUDE.md`, three
failure modes became common:

1. Important rules were ignored (instruction bloat reduces salience).
2. Policies went stale (no review mechanism).
3. Provenance was unclear ("why is this rule here?").

Separately, the ccplugins port work needs portable, repeatable workflows across
many repositories. A global toolkit install is useful, but rule provenance must
remain understandable within the project where rules are applied.

## Decision

1. Introduce a dedicated `/rules:*` command namespace as the primary interface
   for "rules engineering":

   - `/rules:where` recommend where a rule should live.
   - `/rules:propose` run a planning conversation and output an Apply Pack (no writes).
   - `/rules:apply` apply the latest Apply Pack (writes).
   - `/rules:why` trace provenance and explain why a rule exists.
   - `/rules:stale` find guidance past `ReviewBy:`.

2. Enforce a Plan-first workflow for rule creation:

   - `/rules:propose` MUST not write files.
   - Writes happen only via `/rules:apply`.

3. Prefer placing durable guidance in project-local locations (`doc/rules/*` and
   `doc/decisions/*`) instead of bloating global instruction files.

4. Provide a minimal, constitutional toolkit `AGENTS.md` but make installation
   explicit opt-in via Make targets. It must not be installed by default.

## Consequences

- ✅ Rule changes become explainable and portable: Apply Packs include provenance
  and can be applied into any repository.
- ✅ Staleness becomes visible via `ReviewBy:` scanning.
- ✅ Global instruction bloat is reduced; most content moves to commands/ADRs/docs.
- ⚠️ Requires contributors to learn a new `/rules:*` namespace.
- ⚠️ `/rules:apply` must be conservative about path safety and workspace
  containment.

## Alternatives Considered

1. **Keep expanding `AGENTS.md`/`CLAUDE.md`** – rejected due to salience loss,
   staleness, and unclear provenance.
2. **Central registry in the toolkit repo** – rejected as the source of truth
   because it is not portable to repos that only receive the applied rules.
3. **Wrapper commands under `/pro:rules*`** – rejected to avoid reinforcing
   legacy rule-install methodology.

## Related

- Planning: `doc/.plan/.done/feat-ccplugins-port-roadmap-story/`
