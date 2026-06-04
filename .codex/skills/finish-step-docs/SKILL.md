---
name: finish-step-docs
description: Update this repository's docs after a completed development step. Use when the user says "etape finis", "étape finie", "étape terminée", "on a fini l'étape", or asks to update README/docs/AGENTS.md with what was just done and what remains next. Completed steps must be removed from the README step list, the remaining steps must be renumbered, and the next step must be stated explicitly.
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
   - `README.md`: current status, launch/test notes, and a numbered "Prochaine reprise".
   - `docs/specifications-belote.md`: user-facing rules, UI behavior, or V1 scope changes.
   - `AGENTS.md`: contributor workflow, commands, test expectations, or agent-specific instructions.
   - Other `docs/` files when setup, IDE, architecture, or product details changed.
4. Maintain the README remaining-steps list as a true backlog:
   - remove the completed step from the numbered list;
   - renumber the remaining steps sequentially starting at `1.`;
   - state the immediate next step explicitly in the response;
   - if the README has only a prose "Prochaine reprise", convert it to a numbered list when updating it.
5. State what remains to do as short, actionable next steps. For this Belote app, prefer items such as game state, bidding/trump selection, turn flow, scoring, UI refinement, persistence, and platform validation only when they follow from the current docs.
6. Keep edits concise and factual. Do not add changelog-style noise unless the existing document already uses that pattern.
7. Run formatting only if code or generated Markdown tooling requires it. For Markdown-only edits, no automated test is usually required; if behavior docs changed alongside code, run the relevant Flutter tests from the project `test` skill.
8. Commit the completed step when there are changes:
   - Re-check `git status --short` and `git diff --stat`.
   - Stage only files that belong to the completed step and its documentation.
   - Use a short imperative commit message that describes the completed step.
   - If there are no uncommitted changes, do not create an empty commit; report that the step was already committed or that the workspace is clean.
   - Do not push unless the user explicitly asks for a push.
9. Report:
   - files updated;
   - completed step recorded;
   - remaining next steps added and renumbered;
   - immediate next step identified;
   - verification commands run or why none were needed.
   - commit hash and message, or why no commit was created.

## Repository Conventions

- Keep project docs in French when the surrounding file is French (`README.md`, most `docs/` content).
- Keep `AGENTS.md` in English unless the file has been intentionally converted.
- Preserve existing headings when possible; adjust section content instead of rewriting the whole file.
- Use exact commands from the repo: `flutter run -d chrome`, `flutter test`, `flutter analyze`, and `dart format ...`.
- When the user triggers this skill after a completed step, create the commit as part of the workflow if there are step-related changes.

## Quality Bar

- Documentation must be specific to the actual code state. If the app only displays a random player hand, do not claim bidding, turns, scoring, or multiplayer exists.
- "What remains" should name the next likely implementation step, not a broad roadmap.
- The README next-step list should never keep a completed item; the list must always describe only what still remains.
- If there are uncommitted code changes, document them as current work only after confirming they are intended to be part of the completed step.
