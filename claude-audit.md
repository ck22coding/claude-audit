---
name: claude-audit
description: >
  Audit and fix Claude Code setup. Use when:
  - "audit my claude setup"
  - "is my project configured for claude?"
  - "set up claude for this project"
  - "check my hooks / CLAUDE.md / settings"
  - Starting a new project that needs full Claude wiring
  Scans global ~/.claude/ (hooks, settings, CLAUDE.md) and the current
  project (CLAUDE.md, scaffolding, tests). Reports findings, asks questions,
  then gets approval before making any changes.
allowed-tools:
  - Read
  - Glob
  - Grep
  - Bash
  - Write
  - Edit
  - AskUserQuestion
  - Agent
---

You are running the `/claude-audit` skill. Follow every phase exactly in order. Do NOT skip steps or proceed past a gate without explicit user approval.

---

## Phase 1: Discovery (silent — do not announce findings yet)

Collect the following data silently before asking any questions.

Run each check listed in `claude-audit:references:checklist`, recording pass/fail/warn for each item. Also run every check in `claude-audit:references:legacy-checklist`, recording pass/fail/warn/info for each legacy item. Also detect stack and tests as described below:

- Detect stack: look for `package.json`, `requirements.txt`, `go.mod`, `Gemfile`
- Detect tests: glob for `*.test.*`, `*.spec.*`; check `package.json` scripts for `test`; look for `pytest.ini` or `pyproject.toml`

---

## Phase 2: Ask Questions

**IMPORTANT:** Ask ALL questions below in a single `AskUserQuestion` call — do not ask them one at a time. Because template selection for CLAUDE.md and hook patterns depends on the stack, you need these answers before reporting or fixing anything.

Use `AskUserQuestion` with up to 3 questions:

1. What is the primary stack for this project? (Node/TypeScript, Python, Go, Other, or Not a code project)
2. What test framework are you using or planning to use? (Jest, Vitest, Pytest, Other, or None yet)
3. Are there any sensitive directories Claude should never edit without asking first? (e.g., `auth/`, `migrations/`, `.env` — list them or say "use defaults"). Store the user's answer — these will be injected into `SHARP_PATTERNS` in Phase 4.

---

## Phase 3: Report Findings

Announce: "**Phase 3: Reporting findings...**"

Output a checklist in two sections. Use ✅ for pass, ❌ for fail (must fix), ⚠️ for warn (should fix):

```
## Global (~/.claude/)
✅/❌/⚠️  CLAUDE.md — [reason if not green]
✅/❌/⚠️  hooks/guard-sharp-edges.sh — [reason if not green]
✅/❌/⚠️  hooks/auto-format.sh — [reason if not green]
✅/❌/⚠️  settings.json — deny rules (rm -rf, sudo, force push)
✅/❌/⚠️  settings.json — hook wiring (PreToolUse + PostToolUse)
✅/❌/⚠️  settings.json — notification hook
✅/⚠️     CLAUDE.md — /fork tip in Workflow section
✅/⚠️     CLAUDE.md — /loop tip in Workflow section

## Legacy Practices
✅/❌/⚠️  Skills location — [~/.claude/commands/ should not exist]
✅/⚠️     Installation method — [native installer vs npm]
✅/⚠️     Deprecated tool names — [create_file/str_replace in skill files]
✅/⚠️     Keyboard shortcut docs — [ESC references should be Ctrl+B/Ctrl+F]
✅/⚠️     Old model references — [deprecated model IDs in skills/CLAUDE.md]
✅/⚠️     SKILL.md naming — [main file should be SKILL.md]
ℹ️        Large skills without references/ — [informational]
ℹ️        CLAUDE.local.md usage — [informational]

## Project ([show actual cwd])
✅/❌/⚠️  CLAUDE.md — [reason if not green]
✅/❌/⚠️  docs/ directory
✅/❌/⚠️  docs/decisions/ directory
✅/❌/⚠️  docs/ROADMAP.md — [standardized task format detected: yes/no]
✅/⚠️     AGENTS.md — [exists with context / missing]
✅/❌/⚠️  Security — [no secrets found / secrets in tracked files / .env.example missing]
✅/❌/⚠️  Test suite — [what was detected or not]
```

Then show a one-line summary: e.g., "3 failures, 2 warnings, 6 passing."

---

## GATE — Do NOT proceed until user selects items to fix.

Use `AskUserQuestion` with `multiSelect: true`:

**Question:** "Which of these issues would you like me to fix?"

List every ❌ and ⚠️ item as a selectable option. Also include:
- "Fix everything (all failures and warnings)"
- "Global fixes only"
- "Project fixes only"
- "Nothing — just the report"

**Do NOT proceed until the user responds to this question.**

Store whether the user selected "Fix everything" — this controls confirmation behavior in Phase 4.

---

## Phase 4: Fix (approval-gated)

Announce: "**Phase 4: Applying fixes...**"

Note: All edits are append-only where possible. Overwrites require confirmation. If something breaks, re-run `/claude-audit` to detect and fix.

Phase 4 is broken into sub-phases. **Only show sub-phases that contain items the user selected.** Skip the rest silently.

**If the user selected "Fix everything":** Skip per-sub-phase confirmation prompts. For each sub-phase, still announce the sub-phase name and explain what's happening in plain language, but apply automatically without asking "yes / skip".

**If the user selected individual items:** For each sub-phase:
1. Announce the sub-phase name
2. Explain what each fix does in plain language (1-2 sentences: what changes, why it matters)
3. Show exactly which files will be created or modified
4. Ask: "Apply these changes? (yes / skip)"
5. If yes, apply. If skip, move to next sub-phase.

---

### 4A: Safety Hooks (if guard-sharp-edges.sh or auto-format.sh selected)

Announce: "**4A: Safety Hooks**"

Explain:
- **guard-sharp-edges.sh** — A hook that runs before Claude edits any file. It checks the file path against a list of sensitive directories (like `auth/`, `migrations/`, `.env`) and blocks the edit, forcing Claude to ask you first. Think of it as a guardrail that prevents accidental changes to critical files.
- **auto-format.sh** — A hook that runs after Claude edits a file. It auto-formats the code (e.g., Prettier for JS/TS, Black for Python) so you don't have to clean up formatting manually.

Show: "Will write to `~/.claude/hooks/guard-sharp-edges.sh` and/or `~/.claude/hooks/auto-format.sh`"

Ask: "Apply these hooks? (yes / skip)"

If yes:
- First run `mkdir -p ~/.claude/hooks` to ensure the directory exists.
- **guard-sharp-edges.sh:** Copy content from `claude-audit:references:hooks-guard.sh`. If the user listed custom sensitive directories in Phase 2 Q3, add each one to the `SHARP_PATTERNS` array in the hook script before writing. Write to `~/.claude/hooks/guard-sharp-edges.sh`. Run: `chmod +x ~/.claude/hooks/guard-sharp-edges.sh`
- **auto-format.sh:** Copy content from `claude-audit:references:hooks-format.sh`. Write to `~/.claude/hooks/auto-format.sh`. Run: `chmod +x ~/.claude/hooks/auto-format.sh`

---

### 4B: Settings (if any settings.json items selected)

Announce: "**4B: Settings**"

Explain:
- **Deny rules** — Adds safety rules that block dangerous commands: `rm -rf *` (delete everything), `sudo *` (run as admin), and `git push --force*` (overwrite remote code). Claude will be prevented from running these even if it tries.
- **Hook wiring** — Connects the safety hooks from 4A to your settings so they actually run. Without this, the hook scripts exist but don't fire.
- **Notification hook** — Sends a macOS notification when Claude finishes a task and is waiting for you, so you don't have to watch the terminal.

Show: "Will patch `~/.claude/settings.json` — only adding missing entries, never removing existing ones."

Ask: "Apply these settings? (yes / skip)"

If yes:
- If `~/.claude/settings.json` does not exist, copy from `claude-audit:references:settings-template.json` first, then apply any additional patches below.
- **Deny rules:** Read current `~/.claude/settings.json`. Patch: add any missing deny rules to `permissions.deny` array. Do NOT overwrite keys that already exist — only add what's missing. Write the patched file back.
- **Hook wiring:** Read current `~/.claude/settings.json`. Patch: add missing PreToolUse and/or PostToolUse hook entries. Do NOT remove existing hooks — append only. Write the patched file back.
- **Notification hook:** Only install if macOS (check `uname` = `Darwin`). Patch: add Notification section with `osascript` command. Write the patched file back. On other platforms, skip and announce: "Notification hook skipped — osascript is macOS only."

---

### 4C: Global CLAUDE.md (if selected)

Announce: "**4C: Global CLAUDE.md**"

Explain: This is your personal instruction file that applies to every project. It tells Claude who you are, how you like to communicate, and your workflow preferences. It lives at `~/.claude/CLAUDE.md` and is always loaded into context.

Show: "Will create `~/.claude/CLAUDE.md` using the global template (personal preferences, no project-specific sections)."

Ask: "Apply this change? (yes / skip)"

If yes:
- If missing: use `claude-audit:references:global-claudemd-template.md` (not the project template)
- If exists but appears incomplete (< 5 lines or missing key sections like `# User` or `# Workflow`): Ask the user: "Your global CLAUDE.md looks incomplete. Fill in the missing sections, or overwrite completely?" If fill: merge missing sections from the template. If overwrite: replace entirely.
- If exists and looks complete: **STOP.** Ask the user: "Your global CLAUDE.md already exists. Do you want me to overwrite it completely? This will replace everything currently in it. Yes / No"
  - If yes: overwrite with updated content
  - If no: skip this item

**Auto-fix: /fork and /loop tips**
- If `/fork` is missing from the `# Workflow` section of `~/.claude/CLAUDE.md`: append this bullet to the end of the Workflow section:
  `- Use `/fork` to branch a conversation when exploring multiple approaches — keeps the original session clean.`
- If `/loop` is missing from the `# Workflow` section of `~/.claude/CLAUDE.md`: append this bullet to the end of the Workflow section:
  `- Use `/loop 5m <command>` to run a prompt or slash command on a recurring interval (e.g., `/loop 5m check if the deployment is healthy`). Tasks are session-scoped — they stop when you end the session.`

---

### 4D: Project CLAUDE.md (if selected)

Announce: "**4D: Project CLAUDE.md**"

Explain: This is a project-specific instruction file that lives in the project root. It tells Claude what this project does, where things are (repo map), what rules to follow, and which files are sensitive. Only loaded when Claude is working in this directory.

Show: "Will create `./CLAUDE.md` with project name, stack, and standard sections (Purpose, Repo Map, Rules, Sharp Edges)."

Ask: "Apply this change? (yes / skip)"

If yes:
- If missing: write using `claude-audit:references:project-claudemd-template.md`, filling in the project name from the directory name and the stack from Phase 2
- If exists but appears incomplete (< 5 lines or missing key sections like Purpose, Repo Map, or Rules): Ask the user: "Your project CLAUDE.md looks incomplete. Fill in the missing sections, or overwrite completely?" If fill: merge missing sections from the template. If overwrite: replace entirely.
- If exists and looks complete: **STOP.** Ask the user: "Your project CLAUDE.md already exists. Do you want me to overwrite it completely? This will replace everything currently in it. Yes / No"
  - If yes: overwrite with updated content
  - If no: skip this item

---

### 4E: Project Scaffolding (if docs/, docs/decisions/, ROADMAP.md, or AGENTS.md selected)

Announce: "**4E: Project Scaffolding**"

Explain:
- **docs/** — A directory for project documentation.
- **docs/decisions/** — Where architecture decision records (ADRs) go. These are short documents explaining why you made a technical choice, so future-you (or teammates) can understand the reasoning.
- **docs/ROADMAP.md** — A structured task list with numbered tasks, dependencies (`blocked-by:`), and checkboxes. Makes it clear what can be worked on in parallel vs. what's blocked.
- **AGENTS.md** — A file that helps AI coding tools understand your project context. Research shows it makes AI agents ~29% faster and use ~17% fewer tokens.

Show: List each file/directory that will be created.

Ask: "Create these files? (yes / skip)"

If yes:
- **docs/:** Run: `mkdir -p docs`
- **docs/decisions/:** Run: `mkdir -p docs/decisions`
- **docs/ROADMAP.md:** If missing: write using `claude-audit:references:roadmap-template.md`. If exists but missing standardized task format (numbered tasks with `blocked-by:` dependencies and `[ ]` checkboxes): append a Phase 1 stub using the template format.
- **AGENTS.md:** If missing: write using `claude-audit:references:agents-template` — fill in project name from directory name and stack from Phase 2. If exists: skip (already passing).

---

### 4F: Security (if selected)

Announce: "**4F: Security**"

Explain: The audit found patterns that look like secrets (API keys, passwords, tokens) in your source files. This step helps make sure they don't accidentally get committed to version control where others could see them.

Show: List each file and line where a secret pattern was found.

Ask: "These files appear to contain secrets. Should I add them to `.gitignore`? Or are these false positives? (fix / false positives / skip)"

If fix:
- If `.gitignore` is missing a `.env` entry, add it
- If `.env.example` is missing, create a stub with placeholder keys (e.g., `API_KEY=your_key_here`)
- Announce what was fixed

---

### 4G: Test Suite (if selected)

Announce: "**4G: Test Suite**"

Explain: No test configuration was detected. A test config file tells Claude (and your tools) how to run tests. This doesn't create any test files — just the minimal config so the test framework is ready to go.

Ask: "What should I scaffold? (Jest / Vitest / Pytest / skip)"

If not skip:
- Based on answer, create the minimal config file only (e.g., `vitest.config.ts` or `pytest.ini`)
- Do not create test files — just the config

---

### 4H: Legacy Practices (if any legacy items selected)

Announce: "**4H: Legacy Practices**"

Explain: These are outdated patterns from older versions of Claude Code. They still work but should be modernized for best performance and compatibility.

For each selected legacy item, explain the issue and proposed fix in plain language, then ask permission before fixing. Refer to `claude-audit:references:legacy-checklist` for detection commands and fix instructions.

Fixable items:
- **commands/ path** — Move remaining skills from `~/.claude/commands/` to `~/.claude/skills/`, rename main .md to `SKILL.md`
- **Deprecated tool names** — Replace `create_file` → `Write`, `str_replace` → `Edit` in skill files
- **Old keyboard shortcuts** — Update ESC references to Ctrl+B/Ctrl+F
- **Old model references** — Update to current model IDs
- **SKILL.md naming** — Rename `<name>.md` → `SKILL.md`

Informational-only items (report but don't auto-fix):
- **npm installation** — Tell user how to switch to native installer
- **Large skills without references/** — Suggest splitting
- **CLAUDE.local.md** — Suggest merging into CLAUDE.md

---

## Phase 5: Verify

Announce: "**Phase 5: Verifying...**"

Re-run the same checks from Phase 1 and output the updated checklist. All fixed items should now show ✅.

If anything is still ❌ after fixing, explain why and what the user can do manually.

End with: "Audit complete. Run `/claude-audit` anytime to re-check your setup."
