#!/usr/bin/env python3
"""Tests for stats.py — parser, emitter, summarizer."""

import subprocess
import sys
from pathlib import Path

import stats

SCRIPT = Path(__file__).parent / "stats.py"

# --- parse_line ---


def test_parse_valid_line():
    line = (
        "## stats:smelter:haiku tokens_in=20000 tokens_out=3022 "
        "ms=111000 usd_in_per_mtok=0.80 usd_out_per_mtok=4.00 "
        "prs=52,53 issues=21,22"
    )
    s = stats.parse_line(line)
    assert s is not None
    assert s.agent == "smelter"
    assert s.model == "haiku"
    assert s.tokens_in == 20000
    assert s.tokens_out == 3022
    assert s.ms == 111000
    assert s.usd_in_per_mtok == 0.80
    assert s.usd_out_per_mtok == 4.00
    assert s.prs == [52, 53]
    assert s.issues == [21, 22]


def test_parse_no_prs_or_issues():
    line = (
        "## stats:prospector:opus tokens_in=50000 tokens_out=8000 "
        "ms=200000 usd_in_per_mtok=15.00 usd_out_per_mtok=75.00"
    )
    s = stats.parse_line(line)
    assert s is not None
    assert s.agent == "prospector"
    assert s.model == "opus"
    assert s.prs == []
    assert s.issues == []


def test_parse_rejects_non_stats():
    assert stats.parse_line("## Miner Run Summary") is None
    assert stats.parse_line("Some random text") is None
    assert stats.parse_line("") is None


def test_parse_rejects_malformed_prefix():
    assert stats.parse_line("## stats:smelter tokens_in=100") is None  # missing model


# --- cost calculation ---


def test_cost_calculation():
    s = stats.StatsLine(
        agent="miner",
        model="opus",
        tokens_in=100_000,
        tokens_out=10_000,
        usd_in_per_mtok=15.00,
        usd_out_per_mtok=75.00,
    )
    # 100k * 15/1M + 10k * 75/1M = 1.50 + 0.75 = 2.25
    assert abs(s.cost_usd - 2.25) < 0.001


def test_cost_zero_tokens():
    s = stats.StatsLine(agent="smelter", model="haiku")
    assert s.cost_usd == 0.0


# --- format_line / roundtrip ---


def test_roundtrip():
    original = (
        "## stats:miner:opus tokens_in=45000 tokens_out=5000 "
        "ms=180000 usd_in_per_mtok=15.00 usd_out_per_mtok=75.00 "
        "prs=51 issues=14"
    )
    parsed = stats.parse_line(original)
    assert parsed is not None
    reformatted = stats.format_line(parsed)
    reparsed = stats.parse_line(reformatted)
    assert reparsed is not None
    assert reparsed.agent == parsed.agent
    assert reparsed.model == parsed.model
    assert reparsed.tokens_in == parsed.tokens_in
    assert reparsed.tokens_out == parsed.tokens_out
    assert reparsed.ms == parsed.ms
    assert reparsed.prs == parsed.prs
    assert reparsed.issues == parsed.issues


def test_format_omits_empty_prs_issues():
    s = stats.StatsLine(
        agent="prospector", model="opus",
        tokens_in=1000, tokens_out=500, ms=5000,
        usd_in_per_mtok=15.00, usd_out_per_mtok=75.00,
    )
    line = stats.format_line(s)
    assert "prs=" not in line
    assert "issues=" not in line


# --- parse_comments (multi-line with noise) ---


def test_parse_comments_mixed():
    text = """## Miner Run Summary

Some description of the run.

## stats:miner:opus tokens_in=45000 tokens_out=5000 ms=180000 usd_in_per_mtok=15.00 usd_out_per_mtok=75.00 prs=51 issues=14

More text here.

## stats:smelter:haiku tokens_in=20000 tokens_out=3000 ms=111000 usd_in_per_mtok=0.80 usd_out_per_mtok=4.00 prs=52,53 issues=21,22
"""
    lines = stats.parse_comments(text)
    assert len(lines) == 2
    assert lines[0].agent == "miner"
    assert lines[1].agent == "smelter"


# --- summarize ---


def test_summarize_empty():
    result = stats.summarize([])
    assert "No stats lines found" in result


def test_summarize_aggregates():
    lines = [
        stats.StatsLine(
            agent="miner", model="opus",
            tokens_in=100_000, tokens_out=10_000, ms=120_000,
            usd_in_per_mtok=15.00, usd_out_per_mtok=75.00,
            prs=[51], issues=[14],
        ),
        stats.StatsLine(
            agent="smelter", model="haiku",
            tokens_in=20_000, tokens_out=3_000, ms=60_000,
            usd_in_per_mtok=0.80, usd_out_per_mtok=4.00,
            prs=[52], issues=[21],
        ),
        stats.StatsLine(
            agent="miner", model="opus",
            tokens_in=80_000, tokens_out=8_000, ms=100_000,
            usd_in_per_mtok=15.00, usd_out_per_mtok=75.00,
            prs=[53], issues=[22],
        ),
    ]
    result = stats.summarize(lines)
    assert "Total runs: 3" in result
    assert "## stats:summary" in result
    assert "miner" in result
    assert "smelter" in result
    # miner total cost: (180k*15 + 18k*75) / 1M = 2.70 + 1.35 = 4.05
    # smelter total cost: (20k*0.80 + 3k*4.00) / 1M = 0.016 + 0.012 = 0.028
    assert "$4.08" in result  # total


# --- CLI emit ---


def test_cli_emit():
    result = subprocess.run(
        [
            sys.executable, str(SCRIPT), "emit",
            "--agent", "smelter", "--model", "haiku",
            "--tokens-in", "20000", "--tokens-out", "3000",
            "--ms", "111000",
            "--prs", "52,53", "--issues", "21,22",
        ],
        capture_output=True, text=True,
    )
    assert result.returncode == 0
    line = result.stdout.strip()
    assert line.startswith("## stats:smelter:haiku")
    assert "tokens_in=20000" in line
    assert "usd_in_per_mtok=0.80" in line
    assert "prs=52,53" in line


def test_cli_validate_good():
    line = (
        "## stats:miner:opus tokens_in=45000 tokens_out=5000 "
        "ms=180000 usd_in_per_mtok=15.00 usd_out_per_mtok=75.00"
    )
    result = subprocess.run(
        [sys.executable, str(SCRIPT), "validate"],
        input=line, capture_output=True, text=True,
    )
    assert result.returncode == 0
    assert "OK" in result.stdout


def test_cli_validate_bad():
    result = subprocess.run(
        [sys.executable, str(SCRIPT), "validate"],
        input="not a stats line", capture_output=True, text=True,
    )
    assert result.returncode == 1
    assert "FAIL" in result.stderr


if __name__ == "__main__":
    # Simple test runner — no pytest dependency needed
    passed = 0
    failed = 0
    for name, func in sorted(globals().items()):
        if name.startswith("test_") and callable(func):
            try:
                func()
                print(f"  PASS  {name}")
                passed += 1
            except Exception as e:
                print(f"  FAIL  {name}: {e}")
                failed += 1
    print(f"\n{passed} passed, {failed} failed")
    sys.exit(1 if failed else 0)
