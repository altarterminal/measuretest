#!/bin/bash

#####################################################################
# parameter
#####################################################################

ME_DEVICE_NAME=$1

#####################################################################
# setting
#####################################################################

ME_THIS_FILE=$(realpath "${BASH_SOURCE[0]}")
ME_THIS_DIR=$(dirname "${ME_THIS_FILE}")
ME_SCRIPT_DIR=$(dirname "${ME_THIS_DIR}")
ME_TOP_DIR=$(dirname "${ME_SCRIPT_DIR}")

ME_REALDEVICE_CONTROL_DIR=${ME_SCRIPT_DIR}/realdevice_control

# this is defined in advance
# ME_DEVICE_DIR="${ME_TOP_DIR}/device/${ME_DEVICE_NAME}"
ME_DEVICE_SETTING_FILE="${ME_DEVICE_DIR}/enable_setting.sh"

#####################################################################
# import device script
#####################################################################

if [ ! -d "${ME_DEVICE_DIR}" ] || [ ! -x "${ME_DEVICE_DIR}" ]; then
  echo "ERROR:${ME_THIS_FILE##*/}: invalid device dir <${ME_DEVICE_DIR}>" 1>&2
  return 1
fi

if [ ! -f "${ME_DEVICE_SETTING_FILE}" ] || [ ! -r "${ME_DEVICE_SETTING_FILE}" ]; then
  echo "ERROR:${ME_THIS_FILE##*/}: invalid setting file <${ME_DEVICE_SETTING_FILE}>" 1>&2
  return 1
fi

. "${ME_DEVICE_SETTING_FILE}"

#####################################################################
# import error
#####################################################################

. "${ME_THIS_DIR}/define_error.sh"

#####################################################################
# import sequence control 
#####################################################################

. "${ME_THIS_DIR}/control_unit_evaluation.sh"
. "${ME_THIS_DIR}/check_interface_implement.sh"
. "${ME_THIS_DIR}/get_peripheral_condition.sh"
. "${ME_THIS_DIR}/sequence_control_wrapper.sh"

#####################################################################
# import database control
#####################################################################

. "${ME_THIS_DIR}/database_control_wrapper.sh"

#####################################################################
# import realdevice control
#####################################################################

. "${ME_HARDTOOL_DIR}/controller/logging.sh"

. "${ME_REALDEVICE_CONTROL_DIR}/flash_image.sh"
. "${ME_REALDEVICE_CONTROL_DIR}/power_on_board.sh"
. "${ME_REALDEVICE_CONTROL_DIR}/power_off_board.sh"
. "${ME_REALDEVICE_CONTROL_DIR}/boot_process.sh"
. "${ME_REALDEVICE_CONTROL_DIR}/serial.sh"
. "${ME_REALDEVICE_CONTROL_DIR}/adb.sh"

#####################################################################
# cleanup
#####################################################################

unset ME_DEVICE_NAME
unset ME_THIS_FILE
unset ME_THIS_DIR
unset ME_SCRIPT_DIR
unset ME_TOP_DIR
unset ME_REALDEVICE_CONTROL_DIR
# this is defined in advance
# unset ME_DEVICE_DIR
unset ME_DEVICE_SETTING_FILE
