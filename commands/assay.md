---
name: assay
description: Review mapping PRs for quality — finds PRs labeled ready-for-assay
---

Launch the Assayer agent to review mapping PRs for content quality.

**Usage:**
- `/assay <pr-url>` — assay a specific PR
- `/assay` — process PRs labeled `ready-for-assay`

The Assayer will:

1. Evaluate content quality (depth, rigor, grounded expressions)
2. Push targeted content fixes for medium issues
3. Post a GitHub review (approve or request changes)
4. Advance PRs via labels (`approved` or `changes-requested`)

Structural validation is handled by the Smelter before the Assayer sees the PR.

Invoke the Assayer agent with the PR URL (or empty for label-based discovery).
