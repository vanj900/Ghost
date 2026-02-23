#!/usr/bin/env bash
# ghostllm.sh — LLM interface for Ghost.
# Handles prompt construction and communication with language model backends.

set -euo pipefail

# Default model endpoint (override via environment)
GHOST_LLM_ENDPOINT="${GHOST_LLM_ENDPOINT:-http://localhost:11434/api/generate}"
GHOST_LLM_MODEL="${GHOST_LLM_MODEL:-llama3}"

ghost_llm_query() {
  local prompt="${1:-}"
  if [[ -z "$prompt" ]]; then
    echo "[ghostllm] No prompt provided." >&2
    return 1
  fi

  echo "[ghostllm] Querying model '${GHOST_LLM_MODEL}' at ${GHOST_LLM_ENDPOINT}"

  local payload response
  if command -v jq &>/dev/null; then
    payload="$(jq -n --arg model "$GHOST_LLM_MODEL" --arg prompt "$prompt" \
      '{"model":$model,"prompt":$prompt,"stream":false}')"
  else
    # Minimal escaping: backslash then double-quote then control chars
    local escaped_prompt escaped_model
    escaped_prompt="$(printf '%s' "$prompt" | sed 's/\\/\\\\/g; s/"/\\"/g; s/\t/\\t/g; s/\r/\\r/g')"
    escaped_model="$(printf '%s' "$GHOST_LLM_MODEL" | sed 's/\\/\\\\/g; s/"/\\"/g')"
    payload="{\"model\":\"${escaped_model}\",\"prompt\":\"${escaped_prompt}\",\"stream\":false}"
  fi

  response="$(curl --silent --fail \
    -X POST "$GHOST_LLM_ENDPOINT" \
    -H "Content-Type: application/json" \
    -d "$payload")"

  if command -v jq &>/dev/null; then
    printf '%s' "$response" | jq -r '.response // empty'
  else
    printf '%s' "$response" \
      | grep -o '"response":"[^"]*"' \
      | sed 's/"response":"//;s/"$//'
  fi
}

# Entry point when run directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  ghost_llm_query "${1:-Who are you?}"
fi
