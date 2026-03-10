# Agent Pipeline Redesign

**Date**: 2026-03-10
**Status**: Implemented
**Context**: After running the first batch of 10 design-pattern extractions,
we observed that agent responsibilities were blurred, model costs were
uniform (all Opus), and the post-review fix workflow was undefined.

## Problem

1. The Assayer mixed quality judgment with mechanical fixes
2. No agent was responsible for addressing Assayer feedback
3. All agents ran on Opus regardless of cognitive demand
4. No orchestrator existed -- every step required manual invocation
5. Miners produced one PR per mapping, making review inefficient

## Design Principles

- **One cognitive tier per agent.** Each agent operates at a single level
  of reasoning demand, matched to the cheapest model that can do the work.
- **Label-driven contracts.** Every agent finds work by querying GitHub
  labels and signals completion by changing labels. No implicit handoffs.
- **Batch by default.** Miners produce 5 mappings per PR. Smelters and
  Assayers process up to 2 batch PRs (10 mappings) per invocation.
- **Finish before starting.** The orchestrator prioritizes completing
  in-flight work (cheap) over starting new work (expensive).

## Pipeline

```
Prospector  -->  Miner  -->  Smelter  -->  Assayer
  (Opus)        (Opus)      (Haiku)      (Sonnet)
```

The Pitboss orchestrator (Haiku) drives the loop.

## Agent Contracts

### Pitboss (Haiku) -- orchestrator

**Invoked by**: `/work` command

**Purpose**: Survey GitHub for actionable work, dispatch the right agent,
loop until nothing remains. Purely a scheduler -- does no content work.

**Work loop**:

```
loop:
  1. Survey all work (one gh query burst):
     - PRs labeled needs-smelting
     - PRs labeled ready-for-assay
     - PRs labeled needs-miner-fix
     - Unclaimed sub-issues under projects with playbook label
     - Import-project issues without playbook label

  2. Dispatch in parallel where possible:
     - Smelter on needs-smelting PRs         (Haiku)
     - Assayer on ready-for-assay PRs        (Sonnet)
     - Miner on needs-miner-fix PRs          (Opus)

     These never conflict -- different PRs, different labels.

  3. If no in-flight Miner batch:
     - Dispatch Miner on next 5 unclaimed sub-issues  (Opus)

  4. If no projects need mining and no playbook exists:
     - Dispatch Prospector                    (Opus)

  5. Wait for all dispatched agents to complete

  6. Post progress summary

  7. If work remains: loop. If idle: exit.
```

**Concurrency rules**:
- Smelter, Assayer, and Miner can run in parallel on different PRs
- Never two Miner batches simultaneously (they'd race on claiming sub-issues)
- User can Ctrl+C at any time

### Prospector (Opus) -- unchanged

| | |
|---|---|
| **Finds work** | Open issues labeled `import-project`, no `playbook` label |
| **Claims work** | Adds `in-progress` label |
| **Outputs** | Playbook file + PR to agents repo, sub-issues on content repo, run summary comment |
| **Signals done** | Adds `playbook` label to parent issue, removes `in-progress` |

### Miner (Opus) -- batched, narrowed to creative extraction

| | |
|---|---|
| **Finds work** | 5 oldest unclaimed sub-issues (no `in-progress`, no linked PR) under a project with `playbook` label. Or up to 5 `nugget` issues. Or a PR labeled `needs-miner-fix`. |
| **Claims work** | Adds `in-progress` label to all claimed sub-issues |
| **Outputs** | 1 PR with all mappings + frames + categories. Branch: `mine/<project>/batch-N`. Body lists `Closes #X, #Y, #Z...` |
| **Labels PR** | `needs-smelting` |
| **Signals done** | Run summary comment on parent issue |

### Smelter (Haiku) -- new, purely mechanical

| | |
|---|---|
| **Finds work** | Open PRs labeled `needs-smelting` (up to 2 PRs per invocation) |
| **Claims work** | Removes `needs-smelting`, adds `smelting` |
| **Does** | Validate schema, normalize author format (`agent:name`), check slug/filename match, verify PR title/body lists all mappings and sub-issues, run `validate.py`, push fixup commits |
| **Does NOT** | Judge quality, rewrite prose, change kind/frame assignments |
| **Outputs** | Fixup commits (if needed), removes `smelting`, adds `ready-for-assay` |
| **If unfixable** | Adds `needs-miner-fix` instead of `ready-for-assay`, comments with the specific error |

### Assayer (Sonnet) -- refocused on quality judgment

| | |
|---|---|
| **Finds work** | Open PRs labeled `ready-for-assay` (up to 2 PRs per invocation) |
| **Claims work** | Removes `ready-for-assay`, adds `assaying` |
| **Does** | Read seed entries for calibration, evaluate analytical depth/tone/grounding per mapping, push targeted rewrites for medium issues (wrong frame + prose fix, thin sections, weak expressions) |
| **Outputs** | GitHub review comment. Removes `assaying`, then either: adds `approved` label, OR adds `changes-requested` + comment for Miner re-extraction |
| **Bounces to Miner** | Only when a mapping needs complete rewrite -- wrong metaphor framing, fundamentally shallow, fabricated content |

## Label Flow

```
PR created by Miner
  --> needs-smelting
  --> smelting         (Smelter claims)
  --> ready-for-assay  (Smelter done)
  --> assaying         (Assayer claims)
  --> approved         (Assayer approves)
      OR
  --> changes-requested --> needs-miner-fix --> (Miner fixes, back to needs-smelting)
```

## Model Assignments

| Agent | Model | Rationale |
|---|---|---|
| Pitboss | Haiku | Glorified scheduler. Queries labels, dispatches agents. |
| Prospector | Opus | Research, source evaluation, candidate selection, playbook design |
| Miner | Opus | Creative writing, metaphor analysis, "Where It Breaks" depth |
| Smelter | Haiku | Zero judgment -- validate, normalize, fix formatting |
| Assayer | Sonnet | Analytical reading, quality comparison to seed bar, targeted rewrites |

## Batch Sizing

All agents target ~60k-token context windows.

| Agent | Batch | Token budget | Reasoning |
|---|---|---|---|
| Miner | 5 mappings / PR | ~10k fixed + ~5.5k per mapping = ~37.5k | Leaves headroom for complex mappings and new frames |
| Smelter | 2 PRs (10 mappings) | ~3k fixed + ~4k per mapping = ~43k | Mechanical, predictable size |
| Assayer | 2 PRs (10 mappings) | ~8k fixed + ~5k per mapping = ~58k | Needs room for targeted rewrites |

## Batch PR Convention

- Branch: `mine/<project>/batch-N` (N is sequential)
- PR title: `Add mappings: <project> batch N (5 entries)`
- PR body: lists all mapping slugs, `Closes #X, #Y, #Z, #A, #B`
- All 5 sub-issues close on merge

## What This Replaces

- Miner no longer creates 1 PR per mapping
- Assayer no longer pushes mechanical fixup commits (Smelter does)
- Assayer can now push targeted content rewrites (previously only flagged)
- No agent previously handled Assayer feedback -- now Miner picks up
  `needs-miner-fix` PRs, and Assayer handles medium-depth fixes itself
- All agents were Opus -- now tiered by cognitive demand
