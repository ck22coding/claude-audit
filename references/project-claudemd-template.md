# [Project Name]
**Purpose:** [1-sentence description of what this project does and who it's for]

## Repo Map
- `src/` — [main source code]
- `docs/` — decisions (ADRs) and roadmap
- `tests/` — [test files]

## Rules
- Planning-first. Never build without explicit go-ahead.
- Save all decisions to `docs/decisions/` as ADRs (e.g. `ADR-0001-auth-approach.md`).
- Prefer simple, minimal solutions. Don't over-engineer.
- Run tests after every change when a test suite exists.
- Never say "done" unless the action actually happened. Every status claim must include proof — a file path, command output, URL, or process ID.
- When sessions degrade (~40+ min), use Shift+Tab plan mode to capture context, then restart fresh.

## Sharp Edges
- [List directories or files Claude should treat as sensitive]
- Example: `auth/` — authentication flows, confirm before editing
- Example: `migrations/` — database migrations, check for existing guards first
