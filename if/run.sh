#!/bin/bash
set -u

#####################################################################
# setting
#####################################################################

THIS_DIR=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
SCRIPT_DIR="${THIS_DIR}/../sh/sequence_control"
SCRIPT_FILE="${SCRIPT_DIR}/control_unit_device.sh"

if [ ! -f "${SCRIPT_FILE}" ] || [ ! -x "${SCRIPT_FILE}" ]; then
  echo "ERROR:${0##*/}: invalid script specified <${SCRIPT_FILE}>" 1>&2
  exit 1
fi

#####################################################################
# call
#####################################################################

"${SCRIPT_FILE}" "$@"
