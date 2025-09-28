#!/bin/bash
set -u

me_flash_image() {
  local IMAGE_FILE=$1

  local THIS_FILE=${BASH_SOURCE[0]} 
  local FLASH_SCRIPT="${HARDTOOL_DIR}/autoflash.sh"

  local exit_code

  if [ ! -f "${IMAGE_FILE}" ] || [ ! -r "${IMAGE_FILE}" ]; then
    echo "ERROR:${THIS_FILE##*/}: invalid file specified <${IMAGE_FILE}>" 1>&2
    return 1
  fi

  if [ ! -f "${FLASH_SCRIPT}" ] || [ ! -x "${FLASH_SCRIPT}" ]; then
    echo "ERROR:${THIS_FILE##*/}: invalid script specified <${FLASH_SCRIPT}>" 1>&2
    return 1
  fi

  "${FLASH_SCRIPT}" "${IMAGE_FILE}"
  exit_code=$?

  if [ "${exit_code}" -ne 0 ]; then
    echo "ERROR:${THIS_FILE##*/}: flash failed <${IMAGE_FILE}>" 1>&2
    return "${exit_code}"
  fi
}
