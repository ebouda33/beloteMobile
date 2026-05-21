---
name: finish-step-docs
description: Update this repository's docs after a completed development step. Use when the user says "etape finis", "étape finie", "étape terminée", "on a fini l'étape", or asks to update README/docs/AGENTS.md with what was just done and what remains next.
---

# Finish Step Docs

## Overview

Keep the repository documentation aligned with the latest completed work. Capture what changed, what was verified, and the next concrete work items without inventing product scope.

## Workflow

1. Inspect the current state before editing:
   - `git status --short`
   - `git diff --stat`
   - `git diff`
   - `git log --oneline -5`
   - Relevant docs: `README.md`, `AGENTS.md`, `docs/specifications-belote.md`, and any docs touched by the completed step.
2. Identify the completed step from the recent conversation, staged or unstaged diff, and recent commits. Prefer concrete facts from files and commands over memory.
3. Update documentation only where it is now stale:
   - `README.md`: current status, launch/test notes, and "Prochaine reprise".
   - `docs/specifications-belote.md`: user-facing rules, UI behavior, or V1 scope changes.
   - `AGENTS.md`: contributor workflow, commands, test expectations, or agent-specific instructions.
   - Other `docs/` files when setup, IDE, architecture, or product details changed.
4. State what remains to do as short, actionable next steps. For this Belote app, prefer items such as game state, bidding/trump selection, turn flow, scoring, UI refinement, persistence, and platform validation only when they follow from the current docs.
5. Keep edits concise and factual. Do not add changelog-style noise unless the existing document already uses that pattern.
6. Run formatting only if code or generated Markdown tooling requires it. For Markdown-only edits, no automated test is usually required; if behavior docs changed alongside code, run the relevant Flutter tests from the project `test` skill.
7. Report:
   - files updated;
   - completed step recorded;
   - remaining next steps added;
   - verification commands run or why none were needed.

## Repository Conventions

- Keep project docs in French when the surrounding file is French (`README.md`, most `docs/` content).
- Keep `AGENTS.md` in English unless the file has been intentionally converted.
- Preserve existing headings when possible; adjust section content instead of rewriting the whole file.
- Use exact commands from the repo: `flutter run -d chrome`, `flutter test`, `flutter analyze`, and `dart format ...`.
- Do not commit documentation changes unless the user explicitly asks.

## Quality Bar

- Documentation must be specific to the actual code state. If the app only displays a random player hand, do not claim bidding, turns, scoring, or multiplayer exists.
- "What remains" should name the next likely implementation step, not a broad roadmap.
- If there are uncommitted code changes, document them as current work only after confirming they are intended to be part of the completed step.
