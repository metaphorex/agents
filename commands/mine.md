---
name: mine
description: Extract mappings — batch of 5 from a playbook, nuggets, or fix a flagged PR
---

Launch the Miner agent to extract mapping entries in batches.

**Usage:**
- `/mine <project-name>` — mine next 5 unclaimed sub-issues from a project
- `/mine <issue-url>` — mine a specific issue (nugget or sub-issue)
- `/mine` — pick the next available work (nuggets first, then archive, then vein)

The Miner produces one PR per batch of up to 5 mappings, labeled
`needs-smelting` for the Smelter to process.

When picking next, the Miner claims issues with an `in-progress` label
before starting work.

Invoke the Miner agent with the target (or empty for pick-next).
