# Metaphorex Agents

A [Claude Code](https://claude.com/claude-code) plugin providing three agents
for the Metaphorex content pipeline.

## Agents

| Agent | Role | Trust |
|-------|------|-------|
| **Prospector** | Research sources, build playbooks, create sub-issues | High — writes code |
| **Miner** | Follow playbooks, extract mapping entries, open PRs | Standard — writes content |
| **Assayer** | Review + refine Miner output | Standard — reviews + fixes |

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

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

Plugin code: [MIT](LICENSE). Playbooks: CC BY-SA 4.0.
