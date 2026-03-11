---
name: work
description: Run the full Metaphorex pipeline — smelt, assay, mine, prospect — until idle
---

Launch the Pitboss to orchestrate the full content pipeline.

The Pitboss will:

1. Survey GitHub for actionable work (PRs needing smelting/assay, unclaimed issues)
2. Dispatch agents in parallel where possible
3. Post progress summaries after each round
4. Loop until no work remains

**Usage:** `/work`

No arguments needed. The Pitboss finds work by querying GitHub labels.

Invoke the Pitboss agent with no arguments.

After the Pitboss completes, read the usage data from its return value
(`total_tokens`, `tool_uses`, `duration_ms`) and post a stats comment
on the parent import-project issue for the Pitboss's own orchestration
overhead:

```
## stats:pitboss:sonnet tokens_in=<N> tokens_out=<N> ms=<N> usd_in_per_mtok=3.00 usd_out_per_mtok=15.00
```

Use the 85/15 split if only `total_tokens` is available.
