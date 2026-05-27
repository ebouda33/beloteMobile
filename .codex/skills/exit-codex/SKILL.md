---
name: exit-codex
description: Save the current resume URL or session checkpoint to a root temp file before leaving Codex.
---

# Exit Codex

## Overview

Use this skill when the user wants to leave Codex and keep a resumable session
checkpoint for the current session.

## Workflow

1. Resolve the repository root.
2. Write the provided resume URL to `.codex-resume-url.tmp` at the repository
   root when one is available.
3. If no resume URL is available, write the available session context instead:
   `CODEX_THREAD_ID`, current working directory, and capture timestamp.
4. Keep the file out of version control via `.gitignore`.
5. Report the file path and the captured data back to the user.

## Rules

- Do not guess a resume URL.
- If the URL is not available in the current context, store the available
  session identifiers instead of inventing one.
- Do not commit or push anything unless the user explicitly asks.
- Use the root temp file only for the current session checkpoint.
