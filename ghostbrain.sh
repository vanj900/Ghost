#!/usr/bin/env bash
# ghostbrain.sh — Core daemon and decision loop for Ghost.
# Ghost thinks, dreams, reflects, adapts, and shows its mind state here.

set -euo pipefail

GHOST_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source sibling modules
# shellcheck source=ghoststate.sh
[[ -f "$GHOST_ROOT/ghoststate.sh" ]]   && source "$GHOST_ROOT/ghoststate.sh"
# shellcheck source=ghostllm.sh
[[ -f "$GHOST_ROOT/ghostllm.sh" ]]     && source "$GHOST_ROOT/ghostllm.sh"
# shellcheck source=ghostmemory.sh
[[ -f "$GHOST_ROOT/ghostmemory.sh" ]]  && source "$GHOST_ROOT/ghostmemory.sh"
# shellcheck source=ghostmask.sh
[[ -f "$GHOST_ROOT/ghostmask.sh" ]]    && source "$GHOST_ROOT/ghostmask.sh"
# shellcheck source=ghostdream.sh
[[ -f "$GHOST_ROOT/ghostdream.sh" ]]   && source "$GHOST_ROOT/ghostdream.sh"
# shellcheck source=ghostreflect.sh
[[ -f "$GHOST_ROOT/ghostreflect.sh" ]] && source "$GHOST_ROOT/ghostreflect.sh"
# shellcheck source=ghostadapt.sh
[[ -f "$GHOST_ROOT/ghostadapt.sh" ]]   && source "$GHOST_ROOT/ghostadapt.sh"
# shellcheck source=ghosthud.sh
[[ -f "$GHOST_ROOT/ghosthud.sh" ]]     && source "$GHOST_ROOT/ghosthud.sh"

GHOST_PIPE="${GHOST_PIPE:-/tmp/ghost.pipe}"
GHOST_CYCLE_INTERVAL="${GHOST_CYCLE_INTERVAL:-10}"
GHOST_DREAM_EVERY="${GHOST_DREAM_EVERY:-6}"
GHOST_REFLECT_EVERY="${GHOST_REFLECT_EVERY:-4}"
GHOST_ADAPT_EVERY="${GHOST_ADAPT_EVERY:-3}"
GHOST_MASK_ROTATE_EVERY="${GHOST_MASK_ROTATE_EVERY:-8}"
GHOST_HUD_EVERY="${GHOST_HUD_EVERY:-2}"

_ghost_init() {
  echo "[ghostbrain] Initialising Ghost..."

  # Initialise memory diary
  declare -f ghost_memory_init &>/dev/null && ghost_memory_init

  # Seed initial state
  declare -f ghost_state_set &>/dev/null && {
    ghost_state_set "status"        "alive"   >/dev/null
    ghost_state_set "mood"          "curious" >/dev/null
    ghost_state_set "energy"        "80"      >/dev/null
    ghost_state_set "focus"         "70"      >/dev/null
    ghost_state_set "uptime_cycles" "0"       >/dev/null
  }

  # Pick an initial personality mask
  declare -f ghost_mask_rotate &>/dev/null && ghost_mask_rotate >/dev/null

  # Create named pipe for live input
  [[ -p "$GHOST_PIPE" ]] || mkfifo "$GHOST_PIPE"
  echo "[ghostbrain] Input pipe ready at ${GHOST_PIPE}"

  # Record birth event
  declare -f ghost_memory_add &>/dev/null && \
    ghost_memory_add "event" "Ghost born" "curious" \
      "$(declare -f ghost_mask_get &>/dev/null && ghost_mask_get || echo none)"

  # Register cleanup on exit
  trap _ghost_shutdown EXIT INT TERM
}

_ghost_shutdown() {
  echo ""
  echo "[ghostbrain] Ghost fading..."
  declare -f ghost_memory_add &>/dev/null && \
    ghost_memory_add "event" "Ghost shutdown" "calm" \
      "$(declare -f ghost_mask_get &>/dev/null && ghost_mask_get || echo none)"
  [[ -p "$GHOST_PIPE" ]] && rm -f "$GHOST_PIPE"
  declare -f ghost_memory_cleanup &>/dev/null && ghost_memory_cleanup
  echo "[ghostbrain] Gone."
}

_ghost_handle_input() {
  local msg="${1:-}"
  [[ -z "$msg" ]] && return 0
  echo "[ghostbrain] Received: ${msg}"
  local current_mask
  current_mask="$(declare -f ghost_mask_get &>/dev/null && ghost_mask_get || echo none)"
  declare -f ghost_memory_add &>/dev/null && \
    ghost_memory_add "input" "$msg" "attentive" "$current_mask"
  if declare -f ghost_llm_query &>/dev/null; then
    local system_ctx=""
    declare -f ghost_mask_system_prompt &>/dev/null && \
      system_ctx="$(ghost_mask_system_prompt) "
    local response
    response="$(ghost_llm_query "${system_ctx}${msg}" 2>/dev/null)" || response="(no response)"
    echo "[ghostbrain] Response: ${response}"
    declare -f ghost_memory_add &>/dev/null && \
      ghost_memory_add "response" "$response" "engaged" "$current_mask"
  else
    echo "[ghostbrain] LLM not available — reasoning in bare mode."
  fi
}

ghost_think() {
  local input="${1:-}"
  echo "[ghostbrain] Thinking about: ${input}"
  _ghost_handle_input "$input"
}

ghost_decide() {
  local context="${1:-}"
  echo "[ghostbrain] Deciding based on context: ${context}"
}

_ghost_daemon_loop() {
  local cycle=0
  # Open the named pipe in read+write mode to prevent blocking when no writer
  exec {_GHOST_PIPE_FD}<>"$GHOST_PIPE"

  while true; do
    (( cycle++ )) || true

    # Update cycle counter
    declare -f ghost_state_set &>/dev/null && \
      ghost_state_set "uptime_cycles" "$cycle" >/dev/null 2>&1 || true

    # Drain any pending messages from the named pipe (non-blocking)
    local line=""
    while IFS= read -r -t 0 -u "$_GHOST_PIPE_FD" _ 2>/dev/null; do
      # Data is available — read the actual line with a short timeout
      IFS= read -r -t 0.5 -u "$_GHOST_PIPE_FD" line 2>/dev/null || break
      [[ -n "$line" ]] && _ghost_handle_input "$line"
    done || true

    # Adaptation
    if (( cycle % GHOST_ADAPT_EVERY == 0 )); then
      declare -f ghost_adapt &>/dev/null && ghost_adapt >/dev/null 2>&1 || true
    fi

    # Reflection
    if (( cycle % GHOST_REFLECT_EVERY == 0 )); then
      declare -f ghost_reflect &>/dev/null && ghost_reflect >/dev/null 2>&1 || true
    fi

    # Dream cycle
    if (( cycle % GHOST_DREAM_EVERY == 0 )); then
      declare -f ghost_dream_cycle &>/dev/null && ghost_dream_cycle >/dev/null 2>&1 || true
    fi

    # Mask rotation
    if (( cycle % GHOST_MASK_ROTATE_EVERY == 0 )); then
      declare -f ghost_mask_rotate &>/dev/null && ghost_mask_rotate >/dev/null 2>&1 || true
    fi

    # HUD render
    if (( cycle % GHOST_HUD_EVERY == 0 )); then
      declare -f ghost_hud_render &>/dev/null && ghost_hud_render || true
    fi

    sleep "$GHOST_CYCLE_INTERVAL"
  done
}

# Entry point when run directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  _ghost_init
  echo "[ghostbrain] Ghost is awake. Send messages: echo \"<msg>\" > ${GHOST_PIPE}"
  _ghost_daemon_loop
fi
