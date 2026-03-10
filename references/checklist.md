# Claude Audit Checklist

## Global Scope (~/.claude/)

### CLAUDE.md
- **Pass:** File exists at `~/.claude/CLAUDE.md`, contains at least a `# User` or `# Workflow` section
- **Fail:** File missing entirely
- **Warn:** File exists but is empty or under 5 lines
- **Detection:** `Read ~/.claude/CLAUDE.md`

### hooks/guard-sharp-edges.sh
- **Pass:** File exists at `~/.claude/hooks/guard-sharp-edges.sh`, is executable, contains `SHARP_PATTERNS` and `exit 2`
- **Fail:** File missing
- **Warn:** File exists but is not executable (`chmod +x` needed)
- **Detection:** `ls -la ~/.claude/hooks/guard-sharp-edges.sh`

### hooks/auto-format.sh
- **Pass:** File exists at `~/.claude/hooks/auto-format.sh`, is executable, handles at least `js|ts|py` extensions
- **Fail:** File missing
- **Warn:** File exists but is not executable
- **Detection:** `ls -la ~/.claude/hooks/auto-format.sh`

### settings.json — deny rules
- **Pass:** `settings.json` contains deny entries for `rm -rf *`, `sudo *`, and `git push --force*`
- **Fail:** `settings.json` missing entirely
- **Warn:** File exists but missing one or more deny rules
- **Detection:** `Read ~/.claude/settings.json`, check `permissions.deny` array

### settings.json — hook wiring
- **Pass:** `settings.json` wires `guard-sharp-edges.sh` in `PreToolUse` and `auto-format.sh` in `PostToolUse`
- **Fail:** No hooks section in settings.json
- **Warn:** Hooks section exists but one or both scripts not wired
- **Detection:** Check `hooks.PreToolUse` and `hooks.PostToolUse` in settings.json

### settings.json — notification hook
- **Pass:** `settings.json` has a `Notification` hook (any command)
- **Warn:** Missing — nice to have, not critical
- **Detection:** Check `hooks.Notification` in settings.json

### Workflow — session forking
- **Pass:** `~/.claude/CLAUDE.md` mentions `/fork` or `--fork-session` in the Workflow section
- **Warn:** Missing — add this to your Workflow section:
  ```
  - Use `/fork` to branch a conversation when exploring multiple approaches (e.g., "try option A" vs "try option B"). From CLI: `claude --continue --fork-session`. Original session stays intact.
  ```
- **Detection:** `Grep "fork" ~/.claude/CLAUDE.md`
- **Auto-fix:** If warn, append the tip to the `# Workflow` section of `~/.claude/CLAUDE.md`

### Workflow — scheduled tasks with /loop
- **Pass:** `~/.claude/CLAUDE.md` mentions `/loop` in the Workflow section
- **Warn:** Missing — add this to your Workflow section:
  ```
  - Use `/loop <interval> <prompt>` for recurring checks while Claude Code is open:
    /loop 5m check if the deployment is healthy
    /loop 15m scan error logs and flag anything new
    /loop 30m check if CI passed on main
    Note: tasks are session-scoped (lost when you exit). Use for monitoring, not persistence.
  ```
- **Detection:** `Grep "loop" ~/.claude/CLAUDE.md`
- **Auto-fix:** If warn, append the tip to the `# Workflow` section of `~/.claude/CLAUDE.md`

---

## Project Scope (current working directory)

### CLAUDE.md
- **Pass:** File exists, contains Purpose, Repo Map, and Rules sections, is under 30 lines
- **Fail:** File missing
- **Warn:** File exists but missing one or more required sections, or exceeds 30 lines
- **Detection:** `Read ./CLAUDE.md`

### docs/ directory
- **Pass:** `docs/` directory exists
- **Fail:** Missing
- **Detection:** `ls docs/` or Glob

### docs/decisions/ directory
- **Pass:** `docs/decisions/` exists (for ADRs)
- **Fail:** Missing
- **Warn:** Exists but empty (no ADR files yet — acceptable for new projects)
- **Detection:** `ls docs/decisions/`

### docs/ROADMAP.md
- **Pass:** File exists, contains at least one phase with `blocked-by:` task format
- **Fail:** Missing
- **Warn:** Exists but does not use the standardized task format (numbered tasks like `1.1`, `blocked-by:` dependency lines, `[ ]` checkboxes)
- **Detection:** `Read docs/ROADMAP.md`, `Grep blocked-by`

### AGENTS.md
- **Pass:** `AGENTS.md` exists in project root with project context (~29% faster, ~17% fewer tokens per ETH Zurich research)
- **Warn:** Missing — recommended for any project using multiple AI coding tools
- **Detection:** `Read ./AGENTS.md`

### Security — secret patterns
- **Pass:** No exposed API keys, secrets, or credentials in source files; `.env` in `.gitignore`; no hardcoded auth tokens
- **Fail:** Secrets found in tracked files
- **Warn:** `.env.example` missing, or no `.gitignore` entry for secrets
- **Detection:** `Grep` for common secret patterns (API_KEY, SECRET, password, token) in source files; check `.gitignore` for `.env`

### Test suite
- **Pass:** `package.json` with a `test` script, or `pytest.ini`/`pyproject.toml` with pytest config, or `*.test.*`/`*.spec.*` files found
- **Fail:** No test configuration detected
- **Warn:** Config detected but no actual test files found
- **Detection:** Glob for `*.test.*`, `*.spec.*`, check `package.json` scripts, look for `pytest.ini`

---

## Scoring

Count items by status:
- ✅ = Pass
- ❌ = Fail (must fix)
- ⚠️ = Warn (should fix)

**Health rating:**
- All green = Fully configured
- 1-2 warnings = Mostly ready
- Any failures = Needs setup
