#!/bin/bash
set -u

me_serial_run_command() {
  local ME_VM_NAME=$1
  local ME_COMMAND=$2

  local me_exit_code
  local me_this_file

  me_this_file=$(realpath "${BASH_SOURCE[0]}")

  if ! vmserial_run_command >/dev/null 2>&1; then
    echo "ERROR:${me_this_file##*/}: function not defined <vmserial_run_command>" 1>&2
    return 1
  fi

  (
    cd "${ME_HARDTOOL_DIR}"
    vmserial_run_command "${ME_VM_NAME}" "${ME_COMMAND}"
  )
  me_exit_code=$?

  if [ "${me_exit_code}" -ne 0 ]; then
    echo "ERROR:${me_this_file##*/}: serial run command failed <${ME_VM_NAME},${ME_COMMAND}>" 1>&2
    return "${me_exit_code}"
  fi
}
