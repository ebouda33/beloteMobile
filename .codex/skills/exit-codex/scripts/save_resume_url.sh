#!/usr/bin/env bash
set -euo pipefail

root_dir="$(git rev-parse --show-toplevel)"
resume_url="${1:-}"
tmp_file="$root_dir/.codex-resume-url.tmp"

if [[ -n "$resume_url" ]]; then
  printf '%s\n' "$resume_url" > "$tmp_file"
else
  {
    printf 'captured_at=%s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    printf 'thread_id=%s\n' "${CODEX_THREAD_ID:-}"
    printf 'cwd=%s\n' "$PWD"
  } > "$tmp_file"
fi

echo "$tmp_file"
