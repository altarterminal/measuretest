#!/bin/bash
set -u

me_boot_process() {
  local THIS_FILE=${BASH_SOURCE[0]}  

  local exit_code

  if ! type wait_boot >/dev/null 2>&1; then
    echo "ERROR:${THIS_FILE##*/}: function not defined <wait_boot>" 1>&2
    return 1
  fi

  wait_boot
  exit_code=$?

  if [ "${exit_code}" -ne 0 ]; then
    echo "ERROR:${THIS_FILE##*/}: boot process failed" 1>&2
    return "${exit_code}"
  fi
}
