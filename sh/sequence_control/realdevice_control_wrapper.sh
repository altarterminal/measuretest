#!/bin/bash
set -u

ME_REALDEVICE_CONTROL_WRAPPER_THIS_FILE=$(dirname "$(realpath "${BASH_SOURCE[0]}")")
ME_REALDEVICE_CONTROL_WRAPPER_THIS_DIR=$(dirname "${ME_REALDEVICE_CONTROL_THIS_FILE}")

. "${ME_REALDEVICE_CONTROL_THIS_DIR}/../realdevice_control/realdevice_control_setting.sh"
me_realdevice_control_wrapper_exit_code=$?

if [ "${me_realdevice_control_wrapper_exit_code}" -ne 0 ]; then
  echo "ERROR:${ME_REALDEVICE_CONTROL_WRAPPER_THIS_FILE##*/}: import failed <realdevice_control_setting.sh>" 1>&2
  return "${me_realdevice_control_wrapper_exit_code}"
fi

. "${ME_REALDEVICE_CONTROL_WRAPPER_THIS_DIR}/../realdevice_control/flash_image.sh"
. "${ME_REALDEVICE_CONTROL_WRAPPER_THIS_DIR}/../realdevice_control/power_on_board.sh"
. "${ME_REALDEVICE_CONTROL_WRAPPER_THIS_DIR}/../realdevice_control/boot_process.sh"
. "${ME_REALDEVICE_CONTROL_WRAPPER_THIS_DIR}/../realdevice_control/serial.sh"
. "${ME_REALDEVICE_CONTROL_WRAPPER_THIS_DIR}/../realdevice_control/adb.sh"

unset ME_REALDEVICE_CONTROL_WRAPPER_THIS_FILE
unset ME_REALDEVICE_CONTROL_WRAPPER_THIS_DIR
unset me_realdevice_control_wrapper_exit_code
