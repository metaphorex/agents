---
name: prospect
description: Research a source and build an extraction playbook for Metaphorex
---

Launch the Prospector agent to research the import source identified by the
given GitHub issue URL and produce:

1. An extraction playbook (`projects/<name>/playbook.md`)
2. Extraction scripts if applicable (`projects/<name>/scripts/`)
3. Sub-issues on the parent issue (one per mapping candidate)
4. A PR into this repo with all artifacts

**Usage:** `/prospect <issue-url>`

The issue should be an `import-project` labeled issue in metaphorex/metaphorex.

Invoke the Prospector agent with the issue URL as context.
