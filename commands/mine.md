---
name: mine
description: Extract mappings from a source using an approved playbook
---

Launch the Miner agent to work through an approved playbook and extract
mapping entries.

**Usage:** `/mine <project-name>`

The project must have an approved playbook at `projects/<project-name>/playbook.md`.
The Miner will:

1. Read the playbook and identify unprocessed sub-issues
2. Extract each mapping following the playbook strategy
3. Open PRs into metaphorex/metaphorex (one per mapping)
4. Post a run summary on the parent issue

Invoke the Miner agent with the project name as context.
