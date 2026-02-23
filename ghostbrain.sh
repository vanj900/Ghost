#!/usr/bin/env bash
# ghostbrain.sh — Core reasoning and decision loop for Ghost.
# Ghost thinks here. Everything else is downstream of this.

set -euo pipefail

GHOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source sibling modules if available
# shellcheck source=ghoststate.sh
[[ -f "$GHOST_ROOT/ghoststate.sh" ]] && source "$GHOST_ROOT/ghoststate.sh"
# shellcheck source=ghostllm.sh
[[ -f "$GHOST_ROOT/ghostllm.sh" ]] && source "$GHOST_ROOT/ghostllm.sh"

ghost_think() {
  local input="${1:-}"
  echo "[ghostbrain] Thinking about: ${input}"
  # Route to LLM for language-based reasoning
  if declare -f ghost_llm_query &>/dev/null; then
    ghost_llm_query "$input"
  else
    echo "[ghostbrain] LLM module not loaded — reasoning in bare mode."
  fi
}

ghost_decide() {
  local context="${1:-}"
  echo "[ghostbrain] Deciding based on context: ${context}"
}

# Entry point when run directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  ghost_think "${1:-hello}"
fi
