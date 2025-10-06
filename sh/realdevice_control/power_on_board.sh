#!/bin/bash
set -u

me_power_on_board() {
  local ME_THIS_FILE=$(realpath "${BASH_SOURCE[0]}")

  if [ -z "${ARDUINO:-}" ]; then
    echo "ERROR:${ME_THIS_FILE##*/}: variable not defined <ARDUINO>" 1>&2
    return 1
  fi

  printf '%s' '1' >"${ARDUINO}"

  sleep 1
}
