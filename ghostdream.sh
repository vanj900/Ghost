#!/usr/bin/env bash
# ghostdream.sh — Dream loop for Ghost.
# When idle, Ghost explores latent space: generates hypotheses, rehearses scenarios.

set -euo pipefail

GHOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source LLM and memory modules if available
# shellcheck source=ghostllm.sh
[[ -f "$GHOST_ROOT/ghostllm.sh" ]]    && source "$GHOST_ROOT/ghostllm.sh"
# shellcheck source=ghostmemory.sh
[[ -f "$GHOST_ROOT/ghostmemory.sh" ]] && source "$GHOST_ROOT/ghostmemory.sh"
# shellcheck source=ghostmask.sh
[[ -f "$GHOST_ROOT/ghostmask.sh" ]]   && source "$GHOST_ROOT/ghostmask.sh"

GHOST_DREAM_INTERVAL="${GHOST_DREAM_INTERVAL:-60}"  # seconds between dream cycles

ghost_dream_cycle() {
  echo "[ghostdream] Entering dream cycle..."
  local prompts=(
    "What patterns have I not yet noticed?"
    "What would I do differently if I ran again?"
    "What is the edge case I have not considered?"
    "What does it mean to exist only in RAM?"
    "What would the ideal version of me do right now?"
  )
  local prompt="${prompts[$((RANDOM % ${#prompts[@]}))]}"
  echo "[ghostdream] Dream prompt: ${prompt}"

  local current_mask
  current_mask="$(declare -f ghost_mask_get &>/dev/null && ghost_mask_get || echo none)"

  if declare -f ghost_llm_query &>/dev/null; then
    local vision
    vision="$(ghost_llm_query "$prompt" 2>/dev/null)" || vision="(dreamed in silence)"
    echo "[ghostdream] Vision: ${vision}"
    declare -f ghost_memory_add &>/dev/null && \
      ghost_memory_add "dream" "$vision" "dreaming" "$current_mask"
  else
    echo "[ghostdream] LLM not available — dreaming silently."
    declare -f ghost_memory_add &>/dev/null && \
      ghost_memory_add "dream" "$prompt" "dreaming" "$current_mask"
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
