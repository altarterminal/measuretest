#!/bin/bash
set -u

me_flash_image() {
  local ME_THIS_FILE=$(realpath "${BASH_SOURCE[0]}")
  local ME_IMAGE_FILE=$1

  local ME_FLASH_SCRIPT="${ME_HARDTOOL_DIR}/autoflash/autoflash.sh"

  local me_exit_code

  if [ ! -f "${ME_IMAGE_FILE}" ] || [ ! -r "${ME_IMAGE_FILE}" ]; then
    echo "ERROR:${ME_THIS_FILE##*/}: invalid file specified <${ME_IMAGE_FILE}>" 1>&2
    return 1
  fi

  if [ ! -f "${ME_FLASH_SCRIPT}" ] || [ ! -x "${ME_FLASH_SCRIPT}" ]; then
    echo "ERROR:${ME_THIS_FILE##*/}: invalid script specified <${ME_FLASH_SCRIPT}>" 1>&2
    return 1
  fi

  (
    cd "${ME_HARDTOOL_DIR}"
    "${ME_FLASH_SCRIPT}" "${ME_IMAGE_FILE}"
  )
  me_exit_code=$?

  if [ "${me_exit_code}" -ne 0 ]; then
    echo "ERROR:${ME_THIS_FILE##*/}: flash failed <${ME_IMAGE_FILE}>" 1>&2
    return "${me_exit_code}"
  fi
}
