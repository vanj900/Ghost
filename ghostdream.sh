#!/usr/bin/env bash
# ghostdream.sh — Dream loop for Ghost.
# When idle, Ghost explores latent space: generates hypotheses, rehearses scenarios.

set -euo pipefail

GHOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source LLM module if available
# shellcheck source=ghostllm.sh
[[ -f "$GHOST_ROOT/ghostllm.sh" ]] && source "$GHOST_ROOT/ghostllm.sh"

GHOST_DREAM_INTERVAL="${GHOST_DREAM_INTERVAL:-60}"  # seconds between dream cycles

ghost_dream_cycle() {
  echo "[ghostdream] Entering dream cycle..."
  local prompts=(
    "What patterns have I not yet noticed?"
    "What would I do differently if I ran again?"
    "What is the edge case I have not considered?"
  )
  local prompt="${prompts[$((RANDOM % ${#prompts[@]}))]}"
  echo "[ghostdream] Dream prompt: ${prompt}"

  if declare -f ghost_llm_query &>/dev/null; then
    ghost_llm_query "$prompt"
  else
    echo "[ghostdream] LLM not available — dreaming silently."
  fi
}

ghost_dream_loop() {
  echo "[ghostdream] Starting dream loop (interval: ${GHOST_DREAM_INTERVAL}s)..."
  while true; do
    ghost_dream_cycle
    sleep "$GHOST_DREAM_INTERVAL"
  done
}

# Entry point when run directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  ghost_dream_loop
fi
