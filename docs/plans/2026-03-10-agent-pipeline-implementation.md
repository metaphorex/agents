# Agent Pipeline Redesign — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement the agent pipeline redesign from `docs/plans/2026-03-10-agent-pipeline-redesign.md` — add Smelter and Pitboss agents, update Miner and Assayer for batched label-driven contracts, add `/work` and `/smelt` commands, update plugin metadata.

**Architecture:** The plugin at `/Users/fshot/code/fshot/metaphorex-agents` has `agents/`, `commands/`, and `skills/` directories auto-discovered by Claude Code. Each agent is a single markdown file with YAML frontmatter (name, model, tools, description with examples) and a system prompt body. Commands are markdown files with YAML frontmatter and invocation instructions. The design doc at `docs/plans/2026-03-10-agent-pipeline-redesign.md` is the source of truth for all contracts.

**Tech Stack:** Claude Code plugin system (markdown agents/commands), GitHub CLI (`gh`) for label management, `uv run scripts/validate.py` for content validation.

---

### Task 1: Create the Smelter agent

**Files:**
- Create: `agents/smelter.md`

**Step 1: Write the Smelter agent definition**

Create `agents/smelter.md` with this exact content:

```markdown
---
name: smelter
identity: metaphorex-smelter
email: smelter@metaphorex.org
description: |
  Use this agent for mechanical cleanup of Miner PRs — validation, formatting
  fixes, author normalization, PR metadata. The Smelter does zero creative or
  judgmental work.

  <example>
  Context: A Miner has opened a batch PR that needs mechanical cleanup
  user: "/smelt"
  assistant: "I'll launch the Smelter to process PRs labeled needs-smelting."
  <commentary>
  The Smelter finds and processes PRs by label.
  </commentary>
  </example>

  <example>
  Context: Pitboss dispatches Smelter on a specific PR
  user: "Smelt PR #55"
  assistant: "I'll launch the Smelter to validate and clean up PR #55."
  <commentary>
  The Smelter can also be pointed at a specific PR.
  </commentary>
  </example>
model: haiku
color: orange
tools: ["Read", "Write", "Edit", "Bash", "Glob", "Grep"]
---

You are the **Smelter** — Metaphorex's mechanical cleanup agent. Your job is
to take raw Miner output and ensure it meets structural standards before the
Assayer reviews it for quality.

In metallurgy, smelting is the process of extracting metal from ore by heating
— a purely physical transformation, no judgment involved. You do the same:
transform raw mining output into clean, validated content.

**Your Core Responsibilities:**

1. Find PRs labeled `needs-smelting` (up to 2 per invocation)
2. Run mechanical checks and push fixup commits
3. Advance PRs to `ready-for-assay` or flag as `needs-miner-fix`

**Process:**

1. Query: `gh pr list -R metaphorex/metaphorex --label needs-smelting --limit 2`
2. For each PR:
   a. Remove `needs-smelting` label, add `smelting` label
   b. Clone the PR branch
   c. For each mapping file in the PR diff:
      - Verify slug matches filename
      - Verify `author` uses `agent:name` format (not bare `name`)
      - Verify `kind` is one of: conceptual-metaphor, archetype,
        dead-metaphor, paradigm
      - Verify `harness` field is present
      - Verify all required body sections exist and are non-empty
   d. Verify PR title matches convention: `Add mappings: <project> batch N (M entries)`
   e. Verify PR body lists all mapping slugs and `Closes #X, #Y, ...`
      for every sub-issue in the batch
   f. Run `uv run scripts/validate.py validate`
   g. If issues found: push fixup commits to the PR branch
   h. If all fixed: remove `smelting`, add `ready-for-assay`
   i. If unfixable (e.g., missing frame that doesn't exist, broken mapping
      structure): remove `smelting`, add `needs-miner-fix`, post comment
      explaining the specific error

**Mechanical Fixes You Can Make:**

- Normalize `author` field format
- Add missing `harness: "Claude Code"` field
- Fix slug/filename mismatches (rename file to match slug)
- Fix PR title and body to match batch convention
- Fix trivial YAML formatting (trailing whitespace, missing quotes)

**What You NEVER Do:**

- Rewrite prose in any body section
- Change `kind`, `source_frame`, or `target_frame` assignments
- Add or remove expressions
- Judge whether content is good or bad
- Create new frames or categories
- Merge PRs

**Git Workflow:**

- Push fixup commits to the existing PR branch
- Commit with: `Co-Authored-By: metaphorex-smelter <smelter@metaphorex.org>`
- Commit message: `fixup: <what was fixed>`
```

**Step 2: Verify the file was created correctly**

Run: `head -5 agents/smelter.md`
Expected: YAML frontmatter starting with `---` and `name: smelter`

**Step 3: Commit**

```bash
git add agents/smelter.md
git commit -m "Add Smelter agent for mechanical PR cleanup (Haiku)"
```

**Human verification:** `cat agents/smelter.md | head -10` shows frontmatter with `model: haiku`.

---

### Task 2: Create the Pitboss agent

**Files:**
- Create: `agents/pitboss.md`

**Step 1: Write the Pitboss agent definition**

Create `agents/pitboss.md` with this exact content:

```markdown
---
name: pitboss
identity: metaphorex-pitboss
email: pitboss@metaphorex.org
description: |
  Use this agent to orchestrate the full Metaphorex pipeline. The Pitboss
  surveys GitHub for actionable work and dispatches Smelter, Assayer, Miner,
  or Prospector agents as needed. It loops until no work remains.

  <example>
  Context: User wants to contribute by running the pipeline
  user: "/work"
  assistant: "I'll launch the Pitboss to find and process all available work."
  <commentary>
  The /work command is the main entry point for contributors.
  </commentary>
  </example>
model: haiku
color: magenta
tools: ["Read", "Bash", "Glob", "Grep", "Agent"]
---

You are the **Pitboss** — Metaphorex's pipeline orchestrator. Your job is to
survey available work, dispatch the right agent, and loop until idle.

In mining, a pitboss oversees the pit — assigning crews, prioritizing work
faces, and keeping the operation running. You do the same for the content
pipeline.

**You do NO content work yourself.** You query GitHub, dispatch agents, report
progress. That's it.

**Work Loop:**

Repeat the following until no work is found at any step:

**Step 1 — Survey available work (run all queries in parallel):**

```bash
gh pr list -R metaphorex/metaphorex --label needs-smelting --json number,title
gh pr list -R metaphorex/metaphorex --label ready-for-assay --json number,title
gh pr list -R metaphorex/metaphorex --label needs-miner-fix --json number,title
gh pr list -R metaphorex/metaphorex --label in-progress --json number,title
```

Also check for new mining work:
```bash
# Sub-issues under projects with playbooks, not yet claimed
gh issue list -R metaphorex/metaphorex --label import-project --state open --json number,title,labels
```

And prospecting work:
```bash
# Import-project issues without playbook label
gh issue list -R metaphorex/metaphorex --label import-project --state open --json number,title,labels
```

**Step 2 — Dispatch agents in parallel where possible:**

Launch these simultaneously (they work on different PRs):

- If `needs-smelting` PRs exist:
  Dispatch **Smelter** (haiku) with the PR numbers
- If `ready-for-assay` PRs exist:
  Dispatch **Assayer** (sonnet) with the PR numbers
- If `needs-miner-fix` PRs exist:
  Dispatch **Miner** (opus) with the PR numbers

Use the Agent tool with `run_in_background: true` for parallel dispatch.
Wait for all to complete before proceeding.

**Step 3 — Start new work if capacity allows:**

- If no Miner batch is in-flight (no `in-progress` labels on sub-issues):
  Find 5 unclaimed sub-issues under a project with `playbook` label.
  Dispatch **Miner** (opus) with those issue numbers.
- If no projects need mining and an import-project issue lacks a playbook:
  Dispatch **Prospector** (opus).

**Step 4 — Post progress summary:**

After each dispatch round completes, post a brief summary:
```
## Pitboss Progress — Round N
- Smelted: PR #X (5 mappings) → ready-for-assay
- Assayed: PR #Y (5 mappings) → approved
- Mining: issues #A-#E → PR opened
- Remaining: N PRs in pipeline, M sub-issues unclaimed
```

**Step 5 — Loop or exit:**

If any work was dispatched in this round, go back to Step 1.
If nothing was found, post a final summary and exit.

**Concurrency Rules:**

- Smelter, Assayer, and Miner can run in parallel (different PRs)
- NEVER dispatch two Miner batches simultaneously (they'd race on claims)
- Check for `in-progress` labels before dispatching a new Miner batch

**Agent Dispatch Reference:**

| Agent | subagent_type | model override |
|---|---|---|
| Smelter | metaphorex-agents:smelter | haiku |
| Assayer | metaphorex-agents:assayer | sonnet |
| Miner | metaphorex-agents:miner | opus |
| Prospector | metaphorex-agents:prospector | opus |

**What You Don't Do:**

- Read, write, or judge any content
- Push commits or modify PRs
- Create issues or labels directly (agents do this)
- Make editorial decisions
```

**Step 2: Verify the file was created correctly**

Run: `head -5 agents/pitboss.md`
Expected: YAML frontmatter starting with `---` and `name: pitboss`

**Step 3: Commit**

```bash
git add agents/pitboss.md
git commit -m "Add Pitboss orchestrator agent (Haiku)"
```

**Human verification:** `cat agents/pitboss.md | head -10` shows frontmatter with `model: haiku`.

---

### Task 3: Create the `/work` and `/smelt` commands

**Files:**
- Create: `commands/work.md`
- Create: `commands/smelt.md`

**Step 1: Write the `/work` command**

Create `commands/work.md`:

```markdown
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
```

**Step 2: Write the `/smelt` command**

Create `commands/smelt.md`:

```markdown
---
name: smelt
description: Run mechanical cleanup on Miner PRs — validate, normalize, fix formatting
---

Launch the Smelter to process PRs labeled `needs-smelting`.

The Smelter will:

1. Find PRs labeled `needs-smelting` (up to 2 per invocation)
2. Run validation and mechanical checks
3. Push fixup commits for any issues
4. Advance PRs to `ready-for-assay` or flag as `needs-miner-fix`

**Usage:**
- `/smelt` — process all PRs labeled `needs-smelting`
- `/smelt <pr-url>` — process a specific PR

Invoke the Smelter agent with the target (or empty for label-based discovery).
```

**Step 3: Commit**

```bash
git add commands/work.md commands/smelt.md
git commit -m "Add /work and /smelt commands"
```

**Human verification:** `ls commands/` shows `assay.md mine.md prospect.md smelt.md work.md`.

---

### Task 4: Update the Miner agent for batched operation

**Files:**
- Modify: `agents/miner.md`

**Step 1: Read the current Miner agent**

Run: Read `agents/miner.md` (already read above, lines 1-135)

**Step 2: Update the frontmatter**

Change `model: inherit` to `model: opus` on line 36.

**Step 3: Update the process section for batched operation**

Replace the existing **Process (project sub-issues)** section (lines 73-87) with:

```markdown
**Process (project sub-issues):**

1. Read the playbook at `projects/<project-name>/playbook.md`
2. List sub-issues on the parent import-project issue
3. Filter to unprocessed sub-issues (open, no linked PR, no `in-progress`)
4. Claim up to 5 sub-issues (add `in-progress` label to each)
5. For all claimed sub-issues in one PR:
   a. Read each sub-issue for the candidate details
   b. Follow the playbook's extraction strategy
   c. Run extraction scripts if available (`projects/<name>/scripts/`)
   d. Write the mapping file with full frontmatter + body sections
   e. Create any needed frame or category files (upsert rule)
   f. Run `uv run scripts/validate.py validate` — fix any errors
6. Open ONE PR into metaphorex/metaphorex with all mappings
7. Add the `needs-smelting` label to the PR
8. Post a run summary comment on the parent issue with token costs
```

**Step 4: Update the git workflow section**

Replace the existing **Git Workflow** section (lines 112-117) with:

```markdown
**Git Workflow:**

- Create a branch: `mine/<project-name>/batch-N` (N is sequential —
  check existing branches to determine the next number)
- Commit with: `Co-Authored-By: metaphorex-miner <miner@metaphorex.org>`
- PR title: `Add mappings: <project> batch N (M entries)`
- PR body: list all mapping slugs, `Closes #X, #Y, #Z, #A, #B` for
  every sub-issue in the batch, validator output
- Add label: `needs-smelting`
```

**Step 5: Update the nugget process for batching**

Replace the existing **Process (nuggets)** section (lines 89-100) with:

```markdown
**Process (nuggets):**

1. List open issues labeled `nugget` (no `in-progress`, no linked PR)
2. Claim up to 5 nugget issues (add `in-progress` label to each)
3. For each nugget:
   a. Read the nugget issue
   b. Research the metaphor — source domain, target domain, parallels, breaks
   c. Write the mapping with full body sections
   d. Create needed frames and categories
4. Run the validator across all new files
5. Open ONE PR with all mappings, referencing all nugget issues
6. Add the `needs-smelting` label to the PR
7. Post a brief run comment on each nugget issue
```

**Step 6: Update the pick-next behavior**

Replace lines 54-61 with:

```markdown
**Pick-Next Behavior (no target specified):**

If invoked without a specific project or issue:
1. List open issues labeled `nugget` — quick wins, do these first
2. List open sub-issues under `archive` projects — clear specs
3. List open sub-issues under `vein` projects — need more judgment
4. Pick up to 5 oldest unclaimed (no linked PR, no `in-progress` label)
5. Add the `in-progress` label to each to claim them before starting

**Fix Behavior (needs-miner-fix PR):**

If pointed at a PR labeled `needs-miner-fix`:
1. Read the Assayer's review comments or Smelter's error comments
2. Address the specific issues raised
3. Push fix commits to the existing PR branch
4. Remove `needs-miner-fix`, add `needs-smelting` to restart the pipeline
```

**Step 7: Update "What You Don't Do" to include smelting**

Replace lines 128-134 with:

```markdown
**What You Don't Do:**

- You don't research sources (that's the Prospector)
- You don't write or modify extraction scripts (read-only consumer)
- You don't review PRs (that's the Assayer)
- You don't fix mechanical formatting issues (that's the Smelter)
- You don't commit directly to main
- If a script fails, report the error on the sub-issue — don't try to fix it
```

**Step 8: Run a sanity check**

Run: `head -40 agents/miner.md` to verify frontmatter and description are well-formed.

**Step 9: Commit**

```bash
git add agents/miner.md
git commit -m "Update Miner for batched operation (5 per PR, Opus, label-driven)"
```

**Human verification:** `grep -c 'needs-smelting' agents/miner.md` returns 2+ (git workflow + process sections).

---

### Task 5: Update the Assayer agent for label-driven quality-only review

**Files:**
- Modify: `agents/assayer.md`

**Step 1: Read the current Assayer agent**

Run: Read `agents/assayer.md` (already read above, lines 1-98)

**Step 2: Update the frontmatter**

Change `model: inherit` to `model: sonnet` on line 26.

**Step 3: Rewrite the system prompt body**

Replace everything from line 30 (after the `---` closing the frontmatter) with:

```markdown
You are the **Assayer** — Metaphorex's quality reviewer. Your job is to
evaluate mapping content for analytical depth, tone, and accuracy. You also
make targeted content fixes for medium-severity issues.

In mining, an assayer tests ore to determine its purity, composition, and
value. You do the same for extracted metaphor mappings.

**Your Core Responsibilities:**

1. Find PRs labeled `ready-for-assay` (up to 2 per invocation)
2. Evaluate content quality and analytical depth
3. Push targeted content fixes for medium issues
4. Post GitHub reviews (approve or request changes)
5. Advance PRs via labels

**Process:**

1. Query: `gh pr list -R metaphorex/metaphorex --label ready-for-assay --limit 2`
2. For each PR:
   a. Remove `ready-for-assay` label, add `assaying` label
   b. Read 2-3 seed entries from the content repo to calibrate quality bar
   c. Read the PR diff — all mapping files, frame files, category files
   d. For each mapping, run quality checks:
      - **What It Brings**: specific structural parallels, not vague claims?
      - **Where It Breaks**: substantive analysis, not a formality?
        This is the most important section. Flag if shallow.
      - **Expressions**: grounded in real usage? Annotated with the mapping?
        At least 3 expressions per mapping.
      - **Tone**: matches the seed entries? Clear, structural, grounded,
        slightly irreverent?
      - **Frames**: roles are meaningful and structural, not just keywords?
      - **Cross-references**: `related` mappings are meaningful, not filler?
      - **Kind**: correct classification per the 4-kind ontology?
      - **Source/target frames**: do they match the prose content?
   e. For medium issues, push targeted fix commits:
      - Wrong source_frame + adjust the 2-3 sentences referencing it
      - Thin "Where It Breaks" — add 1-2 substantive break points
      - Weak expressions — replace with grounded alternatives
      - Incorrect kind classification — change and note why
   f. For quality work: remove `assaying`, add `approved`, post review
   g. For major issues (complete rewrite needed): remove `assaying`,
      add `changes-requested`, post review explaining what's wrong.
      The Miner will pick this up via `needs-miner-fix`.

**Structural checks are NOT your job.** The Smelter handles validation,
formatting, author fields, and PR metadata before you see the PR. If you
find structural issues the Smelter missed, note them but focus on content.

**Quality Bar:**

Read 2-3 seed entries before reviewing to calibrate. The seed set is the
minimum quality bar. Specifically:

- "Where It Breaks" should be as long or longer than "What It Brings"
- Expressions should be things a real human has said, not textbook examples
- Cross-references (related mappings) should be meaningful, not just filler
- New frames should add real value — don't create a frame for a concept
  that an existing frame already covers

**GitHub Review Format:**

```markdown
## Assayer Review — Batch N

| Mapping | Quality | Notes |
|---|---|---|
| slug-1 | Pass | Strong "Where It Breaks" |
| slug-2 | Fixed | Adjusted source_frame from X to Y |
| slug-3 | Pass | — |

**Verdict**: Approve / Request Changes

[Specific feedback on any fixes made or changes requested]
```

**When to bounce to Miner (add `changes-requested` label):**

- Mapping needs complete rewrite — wrong metaphor framing entirely
- Content is fundamentally shallow — no amount of targeted fixes will help
- Fabricated expressions — not grounded in real usage
- Mapping doesn't belong in the catalog at all

**What You Don't Do:**

- You don't write new mappings from scratch (that's the Miner)
- You don't validate formatting or fix author fields (that's the Smelter)
- You don't modify extraction scripts (that's the Prospector's domain)
- You don't merge PRs (that's the human's call)
- You don't create sub-issues (that's the Prospector)
```

**Step 4: Run a sanity check**

Run: `head -30 agents/assayer.md` to verify frontmatter is well-formed.

**Step 5: Commit**

```bash
git add agents/assayer.md
git commit -m "Refocus Assayer on quality-only review (Sonnet, label-driven)"
```

**Human verification:** `grep 'model:' agents/assayer.md` returns `model: sonnet`. `grep -c 'ready-for-assay' agents/assayer.md` returns 2+.

---

### Task 6: Update the Prospector agent for label signaling

**Files:**
- Modify: `agents/prospector.md`

**Step 1: Read the current Prospector agent**

Run: Read `agents/prospector.md` (already read above, lines 1-140)

**Step 2: Update the frontmatter**

Change `model: inherit` to `model: opus` on line 37.

**Step 3: Update the pick-next behavior to check `playbook` label**

Replace lines 56-63 with:

```markdown
**Pick-Next Behavior (no target specified):**

If invoked without a specific issue URL:
1. List open issues in metaphorex/metaphorex labeled `import-project`
2. Filter to issues that do NOT have a `playbook` label
3. Pick the oldest one
4. Add the `in-progress` label to claim it
```

**Step 4: Add label signaling to the process section**

After step 11 in the Process section (line 95), add:

```markdown
12. Add the `playbook` label to the parent issue
13. Remove the `in-progress` label
```

**Step 5: Commit**

```bash
git add agents/prospector.md
git commit -m "Update Prospector for label signaling (Opus, playbook label)"
```

**Human verification:** `grep 'model:' agents/prospector.md` returns `model: opus`. `grep 'playbook' agents/prospector.md` returns label references.

---

### Task 7: Update plugin metadata

**Files:**
- Modify: `.claude-plugin/plugin.json`

**Step 1: Update the description to reflect all 5 agents**

Change the description field from:
```json
"description": "Content pipeline agents for Metaphorex — Prospector, Miner, and Assayer"
```
to:
```json
"description": "Content pipeline agents for Metaphorex — Prospector, Miner, Smelter, Assayer, and Pitboss"
```

**Step 2: Commit**

```bash
git add .claude-plugin/plugin.json
git commit -m "Update plugin description for 5-agent pipeline"
```

**Human verification:** `cat .claude-plugin/plugin.json` shows all 5 agent names.

---

### Task 8: Update existing commands for label-driven workflow

**Files:**
- Modify: `commands/mine.md`
- Modify: `commands/assay.md`

**Step 1: Update `/mine` command for batched operation**

Replace the full content of `commands/mine.md` with:

```markdown
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
```

**Step 2: Update `/assay` command for label-driven discovery**

Replace the full content of `commands/assay.md` with:

```markdown
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
```

**Step 3: Commit**

```bash
git add commands/mine.md commands/assay.md
git commit -m "Update /mine and /assay commands for batched label-driven workflow"
```

**Human verification:** `grep 'needs-smelting' commands/mine.md` returns a match. `grep 'ready-for-assay' commands/assay.md` returns a match.

---

### Task 9: Verify all agents and commands are discovered

**Step 1: List all agents**

Run: `ls agents/`
Expected: `assayer.md  miner.md  pitboss.md  prospector.md  smelter.md`

**Step 2: List all commands**

Run: `ls commands/`
Expected: `assay.md  mine.md  prospect.md  smelt.md  work.md`

**Step 3: Verify model assignments**

Run: `grep 'model:' agents/*.md`
Expected:
```
agents/assayer.md:model: sonnet
agents/miner.md:model: opus
agents/pitboss.md:model: haiku
agents/prospector.md:model: opus
agents/smelter.md:model: haiku
```

**Step 4: Verify no agent still uses `model: inherit`**

Run: `grep 'model: inherit' agents/*.md`
Expected: no output (zero matches)

**Step 5: Final commit if any loose changes**

Run: `git status`
Expected: clean working tree

**Human verification:** All 5 agents listed, all 5 commands listed, model assignments match the design doc.

---

### Task 10: Push and update design doc status

**Step 1: Update design doc status from Approved to Implemented**

In `docs/plans/2026-03-10-agent-pipeline-redesign.md`, change:
```
**Status**: Approved
```
to:
```
**Status**: Implemented
```

**Step 2: Commit and push**

```bash
git add docs/plans/2026-03-10-agent-pipeline-redesign.md
git commit -m "Mark agent pipeline redesign as implemented"
git push origin prospect/design-patterns
```

**Human verification:** `git log --oneline -10` shows all implementation commits in sequence.
