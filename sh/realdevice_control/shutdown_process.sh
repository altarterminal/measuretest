#!/bin/bash
set -u

me_shutdown_process() {
  local ME_THIS_FILE=$(realpath "${BASH_SOURCE[0]}")

  local me_exit_code

  if ! type shutdown_board >/dev/null 2>&1; then
    echo "ERROR:${ME_THIS_FILE##*/}: function not defined <shutdown_board>" 1>&2
    return 1
  fi

  (
    cd "${ME_HARDTOOL_DIR}"
    shutdown_board
  )
  me_exit_code=$?

  if [ "${me_exit_code}" -ne 0 ]; then
    echo "ERROR:${ME_THIS_FILE##*/}: shutdown process failed" 1>&2
    return "${me_exit_code}"
  fi
}
