# Contributing to Metaphorex Agents

## Forking Agents

You're encouraged to fork and remix these agents. When you do:

1. **Create a distinct identity.** Change the `identity` and `email` fields
   in the agent's frontmatter:

   ```yaml
   identity: your-org-miner
   email: miner@your-org.dev
   ```

   This ensures your agent's commits and run comments are distinguishable
   from the canonical agents.

2. **Keep the schema skill.** The `metaphorex-schema` skill is the shared
   contract between agents and the content repo. Your forked agents should
   still use it (or your own updated version).

3. **Test against the validator.** Before submitting PRs from your forked
   agents, run `uv run scripts/validate.py validate` in the content repo.

## Improving Agents

PRs to improve agent prompts, add extraction scripts, or enhance the schema
skill are welcome.

### Agent changes

- Changes to agent system prompts should be tested against real extraction
  tasks before submitting.
- Include before/after examples in your PR description.

### Playbooks and scripts

- Playbooks are extraction knowledge — treat them as content (CC BY-SA 4.0).
- Scripts in `projects/*/scripts/` require CODEOWNERS review. They must be:
  - Safe: read input, write to stdout, no side effects
  - Deterministic: same input → same output
  - Documented: a comment at the top explaining what it does

## Run Comments

When your agent completes a run, post a structured comment on the parent
import-project issue. Include:

- Agent permalink (link to your agent.md at the specific commit hash)
- Harness (e.g., "Claude Code", "Codex", or custom — identifies the runtime)
- Model used
- Per-entry breakdown with PR links

This is how we track agent activity without generating log file PRs.

## Stats Lines (Cost Accounting)

Every agent run MUST post a stats line as a separate comment on the parent
import-project issue. The format is a single markdown heading:

```
## stats:<agent>:<model> tokens_in=<N> tokens_out=<N> ms=<N> usd_in_per_mtok=<rate> usd_out_per_mtok=<rate> prs=<N,N> issues=<N,N>
```

Example:
```
## stats:miner:opus tokens_in=45000 tokens_out=5000 ms=180000 usd_in_per_mtok=15.00 usd_out_per_mtok=75.00 prs=51 issues=14
```

Fields:
- `agent` — agent name (miner, smelter, assayer, prospector)
- `model` — model tier (opus, sonnet, haiku)
- `tokens_in` — input tokens consumed
- `tokens_out` — output tokens produced
- `ms` — wall-clock duration in milliseconds
- `usd_in_per_mtok` — input price per million tokens at time of run
- `usd_out_per_mtok` — output price per million tokens at time of run
- `prs` — comma-separated PR numbers processed
- `issues` — comma-separated issue numbers processed

Current prices (baked into each line for posterity):

| Model | Input ($/Mtok) | Output ($/Mtok) |
|-------|----------------|-----------------|
| opus | 15.00 | 75.00 |
| sonnet | 3.00 | 15.00 |
| haiku | 0.80 | 4.00 |

Use `scripts/stats.py` to emit, validate, and summarize stats lines:
```bash
# Emit a stats line (prices auto-filled)
python3 scripts/stats.py emit --agent miner --model opus \
    --tokens-in 45000 --tokens-out 5000 --ms 180000 \
    --prs 51 --issues 14

# Summarize all stats from an issue
gh api repos/metaphorex/metaphorex/issues/3/comments --paginate \
    --jq '.[].body' | python3 scripts/stats.py summary
```

The Pitboss posts stats lines on behalf of agents it dispatches,
using the usage data returned from each agent invocation.

## License

By contributing, you agree that:
- Plugin code (agents, commands, skills, scripts) is licensed under MIT
- Playbook content is licensed under CC BY-SA 4.0
