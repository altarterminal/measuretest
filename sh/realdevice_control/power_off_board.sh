#!/bin/bash
set -u

me_power_on_board() {
  local me_this_file

  me_this_file=$(realpath "${BASH_SOURCE[0]}")

  if [ -z "${ARDUINO:-}" ]; then
    echo "ERROR:${me_this_file##*/}: variable not defined <ARDUINO>" 1>&2
    return 1
  fi

  printf '%s' '2' >"${ARDUINO}"

  sleep 1
}
