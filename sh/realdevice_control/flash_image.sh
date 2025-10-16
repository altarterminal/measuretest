#!/bin/bash
set -u

me_flash_image() {
  local ME_IMAGE_FILE=$1

  local me_exit_code
  local me_this_file
  local me_flash_script

  me_this_file=$(realpath "${BASH_SOURCE[0]}")
  me_flash_script="${ME_HARDTOOL_DIR}/autoflash/autoflash.sh"

  if [ ! -f "${ME_IMAGE_FILE}" ] || [ ! -r "${ME_IMAGE_FILE}" ]; then
    echo "ERROR:${me_this_file##*/}: invalid file specified <${ME_IMAGE_FILE}>" 1>&2
    return 1
  fi

  if [ ! -f "${me_flash_script}" ] || [ ! -x "${me_flash_script}" ]; then
    echo "ERROR:${me_this_file##*/}: invalid script specified <${me_flash_script}>" 1>&2
    return 1
  fi

  (
    cd "${ME_HARDTOOL_DIR}"
    "${me_flash_script}" "${ME_IMAGE_FILE}"
  )
  me_exit_code=$?

  if [ "${me_exit_code}" -ne 0 ]; then
    echo "ERROR:${me_this_file##*/}: flash failed <${ME_IMAGE_FILE}>" 1>&2
    return "${me_exit_code}"
  fi
}
