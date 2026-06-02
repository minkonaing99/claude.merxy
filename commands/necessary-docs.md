Scaffold full project documentation structure. Follow every step precisely.

---

## Step 1 — Scan the project

Read project root before creating anything:

- Detect language + framework (check package.json, composer.json, pyproject.toml, build.gradle, Cargo.toml, go.mod, etc.)
- Note folder structure (src/, app/, routes/, models/, controllers/, etc.)
- Check if `docs/` folder already exists and which doc files are present
- Check if `CLAUDE.md` exists at root
- Check if `.gitignore` exists at root
- Identify project type: API, full-stack web app, CLI, library, etc.

Every doc must reflect actual project — not generic template.

---

## Step 2 — Create or update `.gitignore`

If `.gitignore` does not exist: create it.
If it exists: open it and check if `CLAUDE.md` is already listed.

Either way, ensure these lines are present:

```
# Claude
CLAUDE.md
.claude/
```

Do not duplicate existing entries.

---

## Step 3 — Create `docs/` folder

Create `docs/` in project root if it does not exist.

All documentation files go in `docs/`. README.md is the only doc that stays at root.

---

## Step 4 — Create documentation files

Skip each file if it already exists. Otherwise create with project-aware content using real details from scan. No placeholder lorem ipsum — use actual folder names, detected stack, inferred patterns.

### `docs/PRD.md` — Product Requirements + App Flow

**Product Requirements**
- Problem statement (1-2 sentences — what pain does this solve)
- Goals + success metrics (measurable, e.g. "user can complete X in <30s")
- Target users / personas (infer from project name/type if not explicit)
- Feature list:
  - Core (MVP) — must-have
  - Extended — v2 candidates
  - Out of scope — explicitly excluded
- User stories format: `As a [persona], I want [action], so that [outcome]`
- Constraints: time, budget, platform, compliance
- Open questions / assumptions

**App Flow**
- User journey map: list all entry points (landing, signup, deep link, etc.)
- Core flows (numbered step-by-step): onboarding, main feature, settings, error/empty states
- Navigation structure: tabs, sidebar, breadcrumbs — whatever applies
- Auth gating: which routes require auth, which are public
- State transitions: loading, error, empty, success states per screen
- Edge cases: offline, expired session, permission denied

---

### `docs/TECH.md` — Architecture + Decisions + Security

**Architecture**
- Tech stack with rationale — why each major choice was made
- Folder structure tree (from actual scan — or TBD if new project)
- Request lifecycle / data flow overview
- Technical goals: performance targets, uptime SLA, scale targets
- Non-functional requirements: latency, throughput, availability, security level
- System constraints: environment limits, third-party dependencies, platform restrictions
- Integration points: external APIs, services, webhooks — auth method + data contract
- Scalability plan: horizontal vs vertical, caching strategy, CDN usage
- Deployment target: cloud provider, region, container/serverless/VM
- Observability: logging, metrics, alerting strategy

**Architecture Decision Records**
- ADR format:
  ```
  ## [YYYY-MM-DD] Decision title
  **Status:** Accepted
  **Context:** Why needed
  **Decision:** What was decided
  **Consequences:** Trade-offs and impact
  ```
- One pre-filled ADR based on detected stack

**Security**
- Auth + authorization approach
- Input validation rules
- Secret management (env vars, never hardcoded)
- Known attack surfaces + mitigations
- Dependency audit process

---

### `docs/SCHEMA.md` — Backend Schema + API

**Data Models**
- For each entity: fields, types, constraints, indexes
  ```
  ## EntityName
  | Field | Type | Constraints | Notes |
  |-------|------|-------------|-------|
  ```
- Relationships: ERD-style list (User has many Posts, etc.)
- Enums + constants: list all fixed value sets
- Validation rules per field (required, min/max, regex, unique)
- Soft delete strategy (if used)
- Audit fields standard: created_at, updated_at, deleted_at, created_by
- Auth model: session/JWT/OAuth — token fields, expiry, refresh strategy
- File/media storage: where stored, naming convention, size limits
- Caching layer: what gets cached, TTL, invalidation triggers
- Background jobs: list async tasks, queue name, retry policy
- Migration strategy: naming convention, rollback approach

**API**
- Base URL + versioning strategy
- Auth method (JWT / API key / session — infer or mark TBD)
- Endpoint table: Method, Path, Description, Auth Required
- Request/response example (JSON)
- Error response format
- Rate limiting notes

---

### `docs/DESIGN.md` — UI/UX Design Brief

- Design goals: 3-5 adjectives that describe the desired feel (e.g. "fast, minimal, trustworthy")
- Target devices + breakpoints (mobile-first? desktop-primary? both?)
- Color system: primary, secondary, accent, neutral, semantic (success/warning/error/info)
- Typography: heading font, body font, scale (sizes for h1-h6 + body + caption)
- Spacing system: base unit, scale steps
- Component inventory: list reusable UI components needed (Button, Card, Modal, Form, Table, etc.)
- Interaction patterns: hover states, transitions, loading skeletons, toast notifications
- Accessibility requirements: WCAG level (AA minimum), keyboard nav, screen reader support
- Icon set in use (or TBD)
- Dark mode: required / optional / not planned
- Design reference links (Figma, screenshots) — leave as TBD if none yet

---

### `docs/PLAN.md` — Implementation Plan + Tasks

**Implementation Plan**
- Project phases: Phase 1 (foundation), Phase 2 (core features), Phase 3 (polish/launch)
- Each phase contains:
  - Goal (one sentence)
  - Tasks (numbered, ordered by dependency)
  - Deliverables (what's done/shippable at phase end)
  - Estimated effort (days or story points — leave TBD if unknown)
- Milestone table:
  ```
  | Milestone | Description | Target Date | Status |
  |-----------|-------------|-------------|--------|
  ```
- Dependencies map: which tasks block others
- Risks + mitigations: top 3-5 risks with likelihood, impact, mitigation
- Done criteria: explicit definition of "done" for each phase

**Current Tasks**
- Three sections: `## In Progress`, `## Backlog`, `## Done`
- Task format: `- [ ] Description — owner, due date`
- Note: "Keep updated. Claude reads this before starting work."
- Current status pointer: which phase/task is active now

---

### `docs/SETUP.md` — Setup + Testing + Changelog

**Setup**
- Prerequisites (Node/Python/etc. version — infer from project)
- Install steps: clone → deps → env → database → run
- Env vars section — scan for `process.env`, `os.environ`, `getenv` — list all keys with descriptions
- How to run locally
- Common errors + fixes

**Testing**
- Test framework + runner
- Coverage target: 80%+
- Test types required: unit, integration, E2E
- TDD workflow: RED -> GREEN -> REFACTOR
- How to run tests
- How to write new tests
- Mocking strategy

**Changelog**
- Current version: `0.1.0`
- Format: [Keep a Changelog](https://keepachangelog.com)
- Sections: `### Added`, `### Changed`, `### Fixed`, `### Removed`
- One initial entry dated today

---

## Step 5 — Create or update `CLAUDE.md`

If `CLAUDE.md` does not exist at root: create it.
If it exists: skip (do not overwrite).

```markdown
# Project Instructions for Claude

## Goal

Build and maintain this project with clean architecture, scalable structure, clear logic.

## Stack

<!-- Fill in: language / framework / database -->

## Rules

- Ref /docs for details. Keep this file short.
- Simple, modular, readable code.
- Immutability: return new copies, never mutate.
- Fns < 50 lines. Files 200-400 lines (800 max).
- Validate all input at system boundaries.
- No hardcoded secrets — env vars only.
- 80%+ test coverage. TDD always.

## Docs

| Topic              | File             |
| ------------------ | ---------------- |
| Product + App Flow | docs/PRD.md      |
| Tech + ADRs + Sec  | docs/TECH.md     |
| Schema + API       | docs/SCHEMA.md   |
| UI/UX Design       | docs/DESIGN.md   |
| Plan + Tasks       | docs/PLAN.md     |
| Setup + Test + Log | docs/SETUP.md    |

## Workflow

Before coding: check relevant doc.
After coding: update PLAN.md tasks + SETUP.md changelog.
Undocumented? Add to /docs, not here.

## Behavior

- Senior engineer mindset.
- Explain only when necessary.
- Correctness > cleverness.
- Tests before implementation (TDD).
- Review code after writing.
```

---

## Step 6 — Print summary

```
/necessary-docs complete

Created:
  + .gitignore (CLAUDE.md added)
  + docs/PRD.md      (Product Requirements + App Flow)
  + docs/TECH.md     (Architecture + ADRs + Security)
  + docs/SCHEMA.md   (Backend Schema + API)
  + docs/DESIGN.md   (UI/UX Design Brief)
  + docs/PLAN.md     (Implementation Plan + Tasks)
  + docs/SETUP.md    (Setup + Testing + Changelog)
  + CLAUDE.md

Skipped (already existed):
  - [list each skipped file]

Stack: [language] / [framework] / [database or "unknown"]

Next:
  1. Fill problem statement + goals in docs/PRD.md
  2. Define phases + milestones in docs/PLAN.md
  3. Fill Stack in CLAUDE.md
  4. Record first ADR in docs/TECH.md
  5. Fill color system + components in docs/DESIGN.md
```
