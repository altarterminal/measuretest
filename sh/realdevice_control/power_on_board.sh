#!/bin/bash
set -u

me_power_on_board() {
  local THIS_FILE=${BASH_SOURCE[0]}

  if [ -z "${ARDUINO:-}" ]; then
    echo "ERROR:${THIS_FILE##*/}: variable ARDUINO not set" 1>&2
    return 1
  fi

  printf '%s' '1' >"${ARDUINO}"

  sleep 1
}
