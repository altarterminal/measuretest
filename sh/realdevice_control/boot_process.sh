#!/bin/bash
set -u

me_boot_process() {
  local me_exit_code
  local me_this_file

  me_this_file=$(realpath "${BASH_SOURCE[0]}")

  if ! type boot_board >/dev/null 2>&1; then
    echo "ERROR:${me_this_file##*/}: function not defined <boot_board>" 1>&2
    return 1
  fi

  (
    cd "${ME_HARDTOOL_DIR}"
    boot_board
  )
  me_exit_code=$?

  if [ "${me_exit_code}" -ne 0 ]; then
    echo "ERROR:${me_this_file##*/}: boot process failed" 1>&2
    return "${me_exit_code}"
  fi
}
