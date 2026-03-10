# claude-audit

A Claude Code skill that audits and fixes your Claude Code setup — globally and per-project.

Run `/claude-audit` and it will:

1. **Scan** your `~/.claude/` config (hooks, settings, CLAUDE.md) and your current project (CLAUDE.md, docs, tests, security)
2. **Report** a pass/fail/warn checklist
3. **Ask** what to fix
4. **Fix** only what you approve — safety hooks, deny rules, CLAUDE.md templates, project scaffolding, and more
5. **Verify** everything passes after fixes

## Install

Copy the skill into your Claude Code commands directory:

```bash
# Clone the repo
git clone https://github.com/ck22coding/claude-audit.git

# Copy into your Claude Code commands
cp claude-audit/claude-audit.md ~/.claude/commands/
mkdir -p ~/.claude/commands/claude-audit/references
cp claude-audit/references/* ~/.claude/commands/claude-audit/references/
```

Then run `/claude-audit` in any Claude Code session.

## What it checks

| Scope | Item |
|-------|------|
| Global | `~/.claude/CLAUDE.md` |
| Global | `hooks/guard-sharp-edges.sh` (blocks edits to sensitive files) |
| Global | `hooks/auto-format.sh` (auto-formats after edits) |
| Global | `settings.json` deny rules (`rm -rf`, `sudo`, force push) |
| Global | `settings.json` hook wiring |
| Global | `settings.json` notification hook (macOS) |
| Project | `CLAUDE.md` (purpose, repo map, rules) |
| Project | `docs/` and `docs/decisions/` directories |
| Project | `docs/ROADMAP.md` (standardized task format) |
| Project | `AGENTS.md` |
| Project | Security — secret patterns in source files |
| Project | Test suite configuration |

## What it fixes

- Writes safety hooks that block edits to sensitive directories and auto-format code
- Adds deny rules to prevent dangerous commands
- Wires hooks into `settings.json`
- Scaffolds `CLAUDE.md` (global and project) from templates
- Creates `docs/`, `docs/decisions/`, `ROADMAP.md`, `AGENTS.md`
- Flags exposed secrets and fixes `.gitignore`
- Scaffolds test framework config (Jest, Vitest, Pytest)

All fixes are opt-in. Nothing changes without your approval.

## License

MIT
