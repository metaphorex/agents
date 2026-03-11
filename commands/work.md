---
name: work
description: Run the full Metaphorex pipeline — smelt, assay, mine, prospect — until idle
---

You are now the inline orchestrator for the Metaphorex pipeline. Everything you
do runs in the main conversation so the user sees progress immediately.

## Phase A — Survey & Present

1. Run the survey script:
   ```bash
   uv run scripts/survey.py --repo metaphorex/metaphorex
   ```

2. Parse the JSON output. Display a summary table:
   ```
   ## Available Work
   | Category | Count | Items |
   |----------|-------|-------|
   | Needs smelting | 2 | PR #55, #56 |
   | Needs assay | 1 | PR #48 |
   | Needs miner fix | 0 | — |
   | Unclaimed issues | 12 | design-patterns (12) |
   | Needs prospecting | 1 | #7 |
   ```

3. If `total_actionable` is 0, say "No actionable work found." and stop.

## Phase B — Dispatch with TaskCreate spinners

For each category of work, dispatch agents using `Agent` with
`run_in_background: true`. Before each dispatch, create a TaskCreate spinner
so the user sees progress.

**Dispatch order and concurrency rules:**

1. **Parallel group** — launch simultaneously:
   - If `needs_smelting` is non-empty: TaskCreate "Smelting PRs...", then
     dispatch `metaphorex-agents:smelter` with model `haiku`
   - If `needs_assay` is non-empty: TaskCreate "Assaying PRs...", then
     dispatch `metaphorex-agents:assayer` with model `sonnet`
   - If `needs_miner_fix` is non-empty: TaskCreate "Fixing flagged PRs...",
     then dispatch `metaphorex-agents:miner` with model `opus`,
     isolation `worktree`

2. **Wait** for all parallel agents to complete. As each finishes, TaskUpdate
   its spinner to completed.

3. **New mining work** — only if no `in_progress` items exist:
   - Take up to 5 unclaimed issues from the survey
   - TaskCreate "Mining 5 issues...", dispatch `metaphorex-agents:miner`
     with model `opus`, isolation `worktree`, run_in_background: true
   - Wait for completion, TaskUpdate to completed

4. **Prospecting** — only if no mining or fix work was dispatched:
   - TaskCreate "Prospecting...", dispatch `metaphorex-agents:prospector`
     with model `opus`, run_in_background: true
   - Wait for completion, TaskUpdate to completed

**Agent dispatch reference:**

| Agent | subagent_type | model | isolation |
|-------|---------------|-------|-----------|
| Smelter | metaphorex-agents:smelter | haiku | — |
| Assayer | metaphorex-agents:assayer | sonnet | — |
| Miner | metaphorex-agents:miner | opus | worktree |
| Prospector | metaphorex-agents:prospector | opus | — |

## Phase C — Round summary & loop

After all agents in a round complete, print a round summary:

```
## Round 1 Complete
- Smelted: PR #55 → needs-assay
- Assayed: PR #48 → approved + auto-merge
- Mined: 5 issues → PR opened
- Remaining: 12 unclaimed issues
```

Then re-run the survey (`uv run scripts/survey.py --repo metaphorex/metaphorex`).
If `total_actionable` > 0 and new work appeared, loop back to Phase B.
If idle, print a final summary and stop.

## Stats accounting

After each agent completes, read the usage data from its return value
(`total_tokens`, `tool_uses`, `duration_ms`). Post a stats comment on the
parent import-project issue using:

```bash
gh api repos/metaphorex/metaphorex/issues/<N>/comments -f body='## stats:<agent>:<model> tokens_in=<N> tokens_out=<N> ms=<N> usd_in_per_mtok=<rate> usd_out_per_mtok=<rate> prs=<N,N> issues=<N,N>'
```

Prices per model tier:
- opus: usd_in_per_mtok=15.00 usd_out_per_mtok=75.00
- sonnet: usd_in_per_mtok=3.00 usd_out_per_mtok=15.00
- haiku: usd_in_per_mtok=0.80 usd_out_per_mtok=4.00

If only `total_tokens` is available (not split), estimate:
tokens_in = total_tokens × 0.85, tokens_out = total_tokens × 0.15.

At the very end, post your own orchestration stats as well:
```
## stats:pitboss:opus tokens_in=<N> tokens_out=<N> ms=<N> usd_in_per_mtok=15.00 usd_out_per_mtok=75.00
```
