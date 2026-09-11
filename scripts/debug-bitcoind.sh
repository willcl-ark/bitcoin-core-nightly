#!/usr/bin/env bash
set -eu

# Launch before static initialization and stop only on crashes, not handled throws.
exec "${LLDB:?}" \
  --batch \
  --one-line "settings set auto-confirm true" \
  --one-line run \
  --one-line-on-crash "thread backtrace all" \
  --one-line-on-crash "image list" \
  --one-line-on-crash "quit 1" \
  -- "${GITHUB_WORKSPACE:?}/bitcoin/build/bin/bitcoind" "$@" \
  > "$GITHUB_WORKSPACE/lldb.log" 2>&1
