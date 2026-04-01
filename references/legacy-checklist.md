# Legacy Practices Checklist

Checks for outdated Claude Code patterns that still work but should be modernized.

---

## High Priority (actively outdated)

### 1. commands/ path
- **Pass:** `~/.claude/commands/` does not exist or is empty
- **Fail:** Skills still in `~/.claude/commands/` instead of `~/.claude/skills/`
- **Detection:** `ls ~/.claude/commands/ 2>/dev/null`
- **Fix:** Move each skill directory to `~/.claude/skills/<name>/`, rename main .md to `SKILL.md`

### 2. npm installation
- **Pass:** `which claude` returns `~/.claude/bin/claude` (native installer)
- **Warn:** `which claude` returns an npm path (e.g., contains `node_modules` or `/usr/local/bin/claude`)
- **Detection:** `which claude`
- **Fix:** Uninstall npm package (`npm uninstall -g @anthropic-ai/claude-code`), install native: `curl -fsSL https://claude.ai/install.sh | sh`

### 3. Deprecated tool references in skills
- **Pass:** No skill files reference `create_file` or `str_replace`
- **Warn:** Skill files use deprecated tool names instead of `Write`/`Edit`
- **Detection:** `Grep -r "create_file\|str_replace" ~/.claude/skills/ --include="*.md"`
- **Fix:** Replace `create_file` → `Write`, `str_replace` → `Edit`

### 4. Old keyboard shortcut docs
- **Pass:** No references to ESC for backgrounding tasks
- **Warn:** CLAUDE.md or skill files mention ESC to background (now Ctrl+B for background, Ctrl+F for foreground)
- **Detection:** `Grep -r "ESC.*background\|Escape.*background" ~/.claude/`
- **Fix:** Update references to Ctrl+B (background) / Ctrl+F (foreground)

### 5. Missing auto-invocation config
- **Pass:** Skills that run automatically have `user-invocable: false` in frontmatter
- **Warn:** Skills designed for auto-triggering don't declare invocability
- **Detection:** Check frontmatter of each SKILL.md for `user-invocable` field
- **Fix:** Add `user-invocable: false` to skills that should auto-trigger (informational only — suggest, don't auto-fix)

---

## Medium Priority (not broken but outdated)

### 6. Old model references
- **Pass:** No references to deprecated model IDs
- **Warn:** Skills or CLAUDE.md reference `opus-4`, `sonnet-4.5`, `sonnet-4`, `haiku-3.5` or similar old model strings
- **Detection:** `Grep -r "opus-4[^.]\\|sonnet-4\\.5\\|sonnet-4[^.]\\|haiku-3" ~/.claude/skills/ ~/.claude/CLAUDE.md`
- **Fix:** Update to current model IDs: `claude-opus-4-6`, `claude-sonnet-4-6`, `claude-haiku-4-5`

### 7. Missing SKILL.md naming
- **Pass:** Every skill's main file is named `SKILL.md`
- **Warn:** Main skill file uses old naming (e.g., `<name>.md` instead of `SKILL.md`)
- **Detection:** For each dir in `~/.claude/skills/`, check if `SKILL.md` exists
- **Fix:** Rename `<name>.md` → `SKILL.md`

---

## Low Priority (informational)

### 8. Large skills without references/ directory
- **Pass:** Skills over 200 lines use a `references/` directory to split content
- **Warn:** SKILL.md exceeds 200 lines with no `references/` directory
- **Detection:** `wc -l` on each SKILL.md, check for `references/` subdirectory
- **Fix:** Suggest splitting into SKILL.md + references/ (informational only)

### 9. CLAUDE.local.md usage
- **Pass:** No `CLAUDE.local.md` files found (ambiguous status in current Claude Code)
- **Warn:** `CLAUDE.local.md` found — may not be loaded by current versions
- **Detection:** `Glob "**/CLAUDE.local.md"`
- **Fix:** Merge contents into `CLAUDE.md` or project-level config (informational only)

---

## Severity Guide

| Severity | Meaning | Action |
|----------|---------|--------|
| ❌ Fail | Actively outdated, may break or cause confusion | Fix recommended |
| ⚠️ Warn | Works but not best practice | Fix when convenient |
| ℹ️ Info | Informational, no action required | Note for awareness |
