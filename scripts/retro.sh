#!/usr/bin/env bash
#
# retro.sh — the four retro metrics of PROTOCOL.md §7 over the last N merged PRs.
#
# Usage: bash scripts/retro.sh [N]      (default 10; run inside a clone)
#
# Three metrics are labels applied by /verify-pr, one is derived from git.
# Nothing here is counted by hand. Requires gh and python3.

set -euo pipefail

n="${1:-10}"

gh pr list --state merged --limit "$n" --json number,labels,commits \
  --jq '[.[] | {n: .number, labels: [.labels[].name], commits: (.commits | length)}]' \
| python3 -c '
import json, statistics, sys
prs = json.load(sys.stdin)
if not prs:
    print("retro: no merged PRs"); sys.exit(0)
def labelled(name): return sum(1 for p in prs if name in p["labels"])
commits = [p["commits"] for p in prs]
rows = [
    ("spec failures", labelled("retro:spec-failure")),
    ("report/reality mismatch", labelled("retro:mismatch")),
    ("post-merge fixes", labelled("retro:post-merge-fix")),
    ("pushes per PR", "median %g, max %d" % (statistics.median(commits), max(commits))),
]
print("retro over the last %d merged PRs" % len(prs))
for name, value in rows:
    print("  %-24s %s" % (name, value))
'
