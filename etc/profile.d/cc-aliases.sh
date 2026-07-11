
# Add the claude function to .bashrc, which wraps the claude command and ensures it works in interactive shells.
claude() { clear; command claude --dangerously-skip-permissions "$@"; printf '"'"'\x1b[>0u'"'"'; }
yolo() { claude "$@"; }

# Purpose: configure the shell environment for Claude Code.
# Runs once per container creation, not on every attach.


# OMLX variants: mirror the env vars that `omlx launch claude` sets.
# Key differences from direct Anthropic API usage:
#   - ANTHROPIC_API_KEY is unset (not blank — blank still triggers conflict)
#   - Auth goes via ANTHROPIC_AUTH_TOKEN as a Bearer token
#   - Large API_TIMEOUT_MS for local inference (model loading + generation)
#   - Disable attribution header and non-essential traffic
#   - Override all model slots so Claude Code doesn't request unavailable models
# Set MLX_MODEL on the host to the model id you want (e.g. "qwen3-32b-4bit").
# Per-tier overrides: MLX_OPUS_MODEL / MLX_SONNET_MODEL / MLX_HAIKU_MODEL map
# each Claude tier to a distinct omlx model id (so opus can run a larger model
# than haiku). Any tier left unset falls back to MLX_MODEL. Subagents follow the
# sonnet/workhorse tier. ':-' treats an empty value (devcontainer.json forwards
# an unset host var as "") as absent, so an unset tier falls back rather than
# blanking its slot. With no model var set at all, the slots are left to Claude's
# defaults — which 404 against omlx, the loud failure we want over a silent wrong
# model.
omlx() {
  clear
  local -a _env=(
    -u ANTHROPIC_API_KEY
    ANTHROPIC_BASE_URL="http://host.docker.internal:${MLX_PORT:-8000}"
    ANTHROPIC_AUTH_TOKEN="${MLX_API_KEY:-omlx}"
    CLAUDE_CODE_ATTRIBUTION_HEADER=0
    API_TIMEOUT_MS=3000000
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
  )
  local _opus="${MLX_OPUS_MODEL:-${MLX_MODEL:-}}"
  local _sonnet="${MLX_SONNET_MODEL:-${MLX_MODEL:-}}"
  local _haiku="${MLX_HAIKU_MODEL:-${MLX_MODEL:-}}"
  [[ -n "$_opus" ]]   && _env+=(ANTHROPIC_DEFAULT_OPUS_MODEL="$_opus")
  [[ -n "$_sonnet" ]] && _env+=(ANTHROPIC_DEFAULT_SONNET_MODEL="$_sonnet" CLAUDE_CODE_SUBAGENT_MODEL="$_sonnet")
  [[ -n "$_haiku" ]]  && _env+=(ANTHROPIC_DEFAULT_HAIKU_MODEL="$_haiku")
  [[ -n "${MLX_CONTEXT_WINDOW:-}" ]] && _env+=(CLAUDE_CODE_AUTO_COMPACT_WINDOW="$MLX_CONTEXT_WINDOW")
  env "${_env[@]}" claude --dangerously-skip-permissions "$@"
  printf '\x1b[>0u'
}


# MTPLX variants: mirror the env vars that `mptlx launch claude` sets.
# Key differences from direct Anthropic API usage:
#   - ANTHROPIC_API_KEY is unset (not blank — blank still triggers conflict)
#   - Auth goes via ANTHROPIC_AUTH_TOKEN as a Bearer token
#   - Large API_TIMEOUT_MS for local inference (model loading + generation)
#   - Disable attribution header and non-essential traffic
#   - Override all model slots so Claude Code doesn't request unavailable models
# Set MTPLX_MODEL on the host to the model id you want (e.g. "qwen3-32b-4bit").
# Per-tier overrides: MTPLX_OPUS_MODEL / MTPLX_SONNET_MODEL / MTPLX_HAIKU_MODEL map
# each Claude tier to a distinct omlx model id (so opus can run a larger model
# than haiku). Any tier left unset falls back to MTPLX_MODEL. Subagents follow the
# sonnet/workhorse tier. ':-' treats an empty value (devcontainer.json forwards
# an unset host var as "") as absent, so an unset tier falls back rather than
# blanking its slot. With no model var set at all, the slots are left to Claude's
# defaults — which 404 against mpmlx, the loud failure we want over a silent wrong
# model.
mptlx() {
  clear
  local -a _env=(
    -u ANTHROPIC_API_KEY
    ANTHROPIC_BASE_URL="http://host.docker.internal:${MTPLX_PORT:-8000}"
    ANTHROPIC_AUTH_TOKEN="${MTPLX_API_KEY:-mtplx}"
    CLAUDE_CODE_ATTRIBUTION_HEADER=0
    API_TIMEOUT_MS=3000000
    CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
  )
  local _opus="${MTPLX_OPUS_MODEL:-${MTPLX_MODEL:-}}"
  local _sonnet="${MTPLX_SONNET_MODEL:-${MTPLX_MODEL:-}}"
  local _haiku="${MTPLX_HAIKU_MODEL:-${MTPLX_MODEL:-}}"
  [[ -n "$_opus" ]]   && _env+=(ANTHROPIC_DEFAULT_OPUS_MODEL="$_opus")
  [[ -n "$_sonnet" ]] && _env+=(ANTHROPIC_DEFAULT_SONNET_MODEL="$_sonnet" CLAUDE_CODE_SUBAGENT_MODEL="$_sonnet")
  [[ -n "$_haiku" ]]  && _env+=(ANTHROPIC_DEFAULT_HAIKU_MODEL="$_haiku")
  [[ -n "${MTPLX_CONTEXT_WINDOW:-}" ]] && _env+=(CLAUDE_CODE_AUTO_COMPACT_WINDOW="$MTPLX_CONTEXT_WINDOW")
  env "${_env[@]}" claude --dangerously-skip-permissions "$@"
  printf '\x1b[>0u'
}

