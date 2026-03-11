# Metaphorex Agents

A [Claude Code](https://claude.com/claude-code) plugin providing three agents
for the Metaphorex content pipeline.

## Agents

| Agent | Role | Model |
|-------|------|-------|
| **Pitboss** | Orchestrate pipeline, dispatch agents, post stats | Sonnet |
| **Prospector** | Research sources, build playbooks, create sub-issues | Opus |
| **Miner** | Follow playbooks, extract mapping entries, open PRs | Opus |
| **Smelter** | Mechanical validation and cleanup of Miner PRs | Haiku |
| **Assayer** | Review + refine Miner output, approve or bounce | Sonnet |

## Quick Start

Install as a Claude Code plugin, then:

```bash
# Research a new source
/prospect https://github.com/metaphorex/metaphorex/issues/1

# Extract mappings from an approved playbook
/mine lakoff-metaphors-we-live-by

# Review a mapping PR
/assay https://github.com/metaphorex/metaphorex/pull/12
```

## Pipeline

```
Import project issue (human creates)
  → /prospect — Prospector builds playbook + sub-issues
  → Human reviews playbook PR (CODEOWNERS gate on scripts)
  → /mine — Miner extracts mappings, opens content PRs
  → /assay — Assayer reviews each PR
  → Human spot-checks, merges
```

## Agent Identity

Each agent identifies itself via `Co-Authored-By` in git commits:

```
Co-Authored-By: metaphorex-miner <miner@metaphorex.org>
```

Agents run under the contributor's own GitHub auth. No GitHub App setup
required.

## Project Structure

```
projects/
  <project-name>/
    playbook.md          # Extraction strategy (Prospector output)
    scripts/             # Parsing scripts (Prospector output, human-reviewed)
```

Playbooks accumulate extraction knowledge. Scripts provide deterministic
parsing. Both are created by the Prospector and reviewed before the Miner
uses them.

## Cost Accounting

Every agent run posts a stats line as a GitHub issue comment on the parent
import-project issue. Format:

```
## stats:<agent>:<model> tokens_in=N tokens_out=N ms=N usd_in_per_mtok=N usd_out_per_mtok=N prs=N,N issues=N,N
```

Summarize costs for a project:
```bash
gh api repos/metaphorex/metaphorex/issues/3/comments --paginate \
    --jq '.[].body' | python3 scripts/stats.py summary
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for the full spec.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Plugin code: [MIT](LICENSE). Playbooks: CC BY-SA 4.0.
