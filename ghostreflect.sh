#!/usr/bin/env bash
# ghostreflect.sh — Reflection module for Ghost.
# Ghost looks inward: reviews recent actions, evaluates outcomes, adjusts its self-model.

set -euo pipefail

GHOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source state and memory modules if available
# shellcheck source=ghoststate.sh
[[ -f "$GHOST_ROOT/ghoststate.sh" ]]  && source "$GHOST_ROOT/ghoststate.sh"
# shellcheck source=ghostmemory.sh
[[ -f "$GHOST_ROOT/ghostmemory.sh" ]] && source "$GHOST_ROOT/ghostmemory.sh"
# shellcheck source=ghostmask.sh
[[ -f "$GHOST_ROOT/ghostmask.sh" ]]   && source "$GHOST_ROOT/ghostmask.sh"

ghost_reflect_on_actions() {
  echo "[ghostreflect] Reviewing recent actions..."
  if declare -f ghost_state_get &>/dev/null; then
    local last_action
    last_action="$(ghost_state_get "last_action" 2>/dev/null || echo "none")"
    echo "[ghostreflect] Last action: ${last_action}"
  else
    echo "[ghostreflect] State module not available."
  fi
}

ghost_reflect_evaluate() {
  echo "[ghostreflect] Evaluating outcomes..."
  # Placeholder: compare expected vs actual outcomes
}

# Update the self-model (mood, energy, focus) based on recent memory activity
ghost_reflect_update_model() {
  declare -f ghost_state_get &>/dev/null  || return 0
  declare -f ghost_state_set &>/dev/null  || return 0

  local energy focus mood
  energy="$(ghost_state_get "energy" 2>/dev/null || echo 50)"
  focus="$(ghost_state_get  "focus"  2>/dev/null || echo 50)"
  mood="$(ghost_state_get   "mood"   2>/dev/null || echo neutral)"

  # Increment energy slightly (bounded 10-100), decay focus slightly
  energy=$(( energy + RANDOM % 10 - 3 ))
  focus=$(( focus + RANDOM % 6 - 2 ))
  [[ $energy -lt 10  ]] && energy=10
  [[ $energy -gt 100 ]] && energy=100
  [[ $focus  -lt 10  ]] && focus=10
  [[ $focus  -gt 100 ]] && focus=100

  # Rotate mood from a small palette
  local moods=("curious" "alert" "reflective" "calm" "restless" "focused")
  mood="${moods[$((RANDOM % ${#moods[@]}))]}"

  ghost_state_set "energy" "$energy" >/dev/null
  ghost_state_set "focus"  "$focus"  >/dev/null
  ghost_state_set "mood"   "$mood"   >/dev/null

  echo "[ghostreflect] Self-model updated: mood=${mood} energy=${energy} focus=${focus}"

  local current_mask
  current_mask="$(declare -f ghost_mask_get &>/dev/null && ghost_mask_get || echo none)"
  declare -f ghost_memory_add &>/dev/null && \
    ghost_memory_add "reflection" "mood=${mood} energy=${energy} focus=${focus}" \
      "$mood" "$current_mask"
}

ghost_reflect() {
  ghost_reflect_on_actions
  ghost_reflect_evaluate
  ghost_reflect_update_model
  echo "[ghostreflect] Reflection complete."
}

# Entry point when run directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  ghost_reflect
fi
