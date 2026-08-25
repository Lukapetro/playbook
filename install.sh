#!/usr/bin/env bash
#
# install.sh — install the playbook protocol on the project in the current
# directory. One command; the only thing left for a human is the bindings
# block in AGENTS.md.
#
# Usage: bash /path/to/playbook/install.sh      (from the project's root)
#
# Idempotent: existing itaca.yml, docs/agents/*, AGENTS.md blocks and labels
# are left alone; the copy-in files (ci/, the workflow) are refreshed.
# Requires: git, gh (authenticated), and the mattpocock-skills plugin
# installed in Claude Code (INSTALL.md §A).

set -euo pipefail

playbook="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project="$(pwd)"
today="$(date +%F)"
todo=()

say()  { printf '%s\n' "$1"; }
done_() { printf '  ✓ %s\n' "$1"; }
skip() { printf '  · %s\n' "$1"; }
fail() { printf 'install: %s\n' "$1" >&2; exit 1; }

[ -d .git ] || fail "run this from the root of a git repository"
[ "$playbook" != "$project" ] || fail "run this from the project, not from the playbook"
command -v gh >/dev/null || fail "gh is required"

say "playbook → $project"

# 1. Copy-in checks and workflow (always refreshed: copies drift, this is the
#    update mechanism).
mkdir -p ci .github/workflows
cp "$playbook/ci/check-handoff.sh" "$playbook/ci/check-itaca.sh" ci/
cp "$playbook/ci/protocol.yml" .github/workflows/protocol.yml
chmod +x ci/check-handoff.sh ci/check-itaca.sh
done_ "ci/check-handoff.sh, ci/check-itaca.sh, .github/workflows/protocol.yml"

# 2. Labels on the GitHub repository.
if gh repo view >/dev/null 2>&1; then
  gh label create ready-for-agent      --color 0E8A16 --description "Ticket the frontier may dispatch" --force >/dev/null
  gh label create retro:spec-failure   --color B60205 --description "Ticket was wrong or underspecified" --force >/dev/null
  gh label create retro:mismatch       --color D93F0B --description "Handoff contradicted by diff or gates" --force >/dev/null
  gh label create retro:post-merge-fix --color FBCA04 --description "Repairs a merged PR; body names which" --force >/dev/null
  done_ "labels: ready-for-agent, retro:spec-failure, retro:mismatch, retro:post-merge-fix"
else
  skip "labels: no GitHub remote reachable through gh"
  todo+=("create the four labels once the repository is on GitHub: see INSTALL.md")
fi

# 3. Tracker and domain docs, from the installed mattpocock-skills plugin.
#    Same files /setup-matt-pocock-skills writes with the answers this
#    protocol fixes: GitHub, default triage labels, single context.
seed="$(ls -d "$HOME"/.claude/plugins/cache/claude-plugins-official/mattpocock-skills/*/skills/engineering/setup-matt-pocock-skills 2>/dev/null | sort -V | tail -1 || true)"
if [ -n "$seed" ] && [ -f "$seed/issue-tracker-github.md" ]; then
  mkdir -p docs/agents
  for pair in "issue-tracker-github.md:issue-tracker.md" "domain.md:domain.md" "triage-labels.md:triage-labels.md"; do
    src="${pair%%:*}"; dst="${pair##*:}"
    if [ -f "docs/agents/$dst" ]; then skip "docs/agents/$dst exists, kept"; else cp "$seed/$src" "docs/agents/$dst"; done_ "docs/agents/$dst"; fi
  done
else
  skip "docs/agents/: mattpocock-skills plugin not found under ~/.claude/plugins"
  todo+=("install the plugin (claude plugins install mattpocock-skills) and re-run, or run /setup-matt-pocock-skills")
fi

# 4. AGENTS.md: the skills block and the bindings block, each once.
if [ ! -f AGENTS.md ]; then
  printf '# %s\n\n' "$(basename "$project")" > AGENTS.md
  done_ "AGENTS.md created"
fi
if [ ! -f CLAUDE.md ]; then
  printf '@AGENTS.md\n' > CLAUDE.md
  done_ "CLAUDE.md → @AGENTS.md"
fi
if grep -q '^## Agent skills' AGENTS.md; then
  skip "AGENTS.md: '## Agent skills' block exists, kept"
else
  cat >> AGENTS.md <<'BLOCK'

## Agent skills

### Issue tracker

Issues, specs and tickets are GitHub Issues of this repository, through `gh`. See `docs/agents/issue-tracker.md`.

### Triage labels

The five canonical roles map to labels of the same name. See `docs/agents/triage-labels.md`.

### Domain docs

Single context: `CONTEXT.md` at the root, decisions in `docs/adr/`. See `docs/agents/domain.md`.
BLOCK
  done_ "AGENTS.md: '## Agent skills' block"
fi
if grep -q '^## Agent protocol bindings' AGENTS.md; then
  skip "AGENTS.md: '## Agent protocol bindings' block exists, kept"
else
  printf '\n' >> AGENTS.md
  # Everything below the "---" separator of the template is the block.
  awk 'found { print } /^---$/ { found = 1 }' "$playbook/templates/agents-bindings.md" >> AGENTS.md
  done_ "AGENTS.md: '## Agent protocol bindings' block appended"
  todo+=("fill the REQUIRED fields of the bindings block in AGENTS.md: gates, reviewer chain, standing rules, language conventions, merger; delete the OPTIONAL ones that do not apply")
fi

# 5. State file.
if [ -f itaca.yml ]; then
  skip "itaca.yml exists, kept"
else
  cat > itaca.yml <<STATE
version: 2
state:
  goal: Install the agent protocol
  doing: []
  blockers: []
  next_safe_action: Fill in the bindings block in AGENTS.md, then open the first shaping session
  assumptions: []
updated: $today
STATE
  done_ "itaca.yml"
fi
if bash ci/check-itaca.sh itaca.yml >/dev/null 2>&1; then
  done_ "ci/check-itaca.sh itaca.yml: OK"
else
  skip "ci/check-itaca.sh itaca.yml: FAILS"
  bash ci/check-itaca.sh itaca.yml 2>&1 | sed 's/^/      /' || true
  todo+=("bring itaca.yml within the caps (SPEC-V2.md §3 for the migration)")
fi

say ""
if [ "${#todo[@]}" -eq 0 ]; then
  say "Done. Commit as one change: git add -A && git commit -m 'chore: install agent protocol (playbook)'"
else
  say "Left for you:"
  for t in "${todo[@]}"; do printf '  - %s\n' "$t"; done
  say "Then commit as one change: git add -A && git commit -m 'chore: install agent protocol (playbook)'"
fi
