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
