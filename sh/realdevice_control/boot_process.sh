#!/bin/bash
set -u

me_boot_process() {
  local ME_THIS_FILE=$(realpath "${BASH_SOURCE[0]}")

  local me_exit_code

  if ! type boot_board >/dev/null 2>&1; then
    echo "ERROR:${ME_THIS_FILE##*/}: function not defined <wait_boot>" 1>&2
    return 1
  fi

  (
    cd "${ME_HARDTOOL_DIR}"
    boot_board
  )
  me_exit_code=$?

  if [ "${me_exit_code}" -ne 0 ]; then
    echo "ERROR:${ME_THIS_FILE##*/}: boot process failed" 1>&2
    return "${me_exit_code}"
  fi
}
