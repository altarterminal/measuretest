#!/bin/bash
set -u

me_serial_run_command() {
  local THIS_FILE=${BASH_SOURCE[0]}
  local VM_NAME=$1
  local COMMAND=$2

  local exit_code

  if ! vmserial_run_command >/dev/null 2>&1; then
    echo "ERROR:${THIS_FILE##*/}: function not defined <vmserial_run_command>" 1>&2
    return 1
  fi

  vmserial_run_command "${VM_NAME}" "${COMMAND}"
  exit_code=$?

  if [ "${exit_code}" -ne 0 ]; then
    echo "ERROR:${THIS_FILE##*/}: serial run command failed <${VM_NAME},${COMMAND}>" 1>&2
    return "${exit_code}"
  fi
}
