#!/bin/bash
set -u

#####################################################################
# parameter
#####################################################################

ME_IMP_THIS_FILE=$(realpath "${BASH_SOURCE[0]}")

ME_IMP_DEVICE_NAME=$1

if [ -z "${ME_IMP_DEVICE_NAME}" ]; then
  echo "ERROR:${ME_IMP_THIS_FILE##*/}: device name must be specified" 1>&2
  return 1
fi

#####################################################################
# setting
#####################################################################

ME_IMP_THIS_DIR=$(dirname "${ME_IMP_THIS_FILE}")
ME_IMP_SCRIPT_DIR=$(dirname "${ME_IMP_THIS_DIR}")
ME_IMP_TOP_DIR=$(dirname "${ME_IMP_SCRIPT_DIR}")

ME_IMP_DEVICE_DIR="${ME_IMP_TOP_DIR}/device/${ME_IMP_DEVICE_NAME}"
ME_IMP_DEVICE_SETTING_FILE="${ME_IMP_DEVICE_DIR}/enable_setting.sh"

#####################################################################
# import device script
#####################################################################

if [ ! -d "${ME_IMP_DEVICE_DIR}" ] || [ ! -x "${ME_IMP_DEVICE_DIR}" ]; then
  echo "ERROR:${ME_IMP_THIS_FILE##*/}: invalid device dir <${ME_IMP_DEVICE_DIR}>" 1>&2
  return 1
fi

if [ ! -f "${ME_IMP_DEVICE_SETTING_FILE}" ] || [ ! -r "${ME_IMP_DEVICE_SETTING_FILE}" ]; then
  echo "ERROR:${ME_IMP_THIS_FILE##*/}: invalid setting file <${ME_IMP_DEVICE_SETTING_FILE}>" 1>&2
  return 1
fi

. "${ME_IMP_DEVICE_SETTING_FILE}"
me_imp_exit_code=$?

if [ "${me_imp_exit_code}" -ne 0 ]; then
  echo "ERROR:${ME_IMP_THIS_FILE##*/}: invalid setting file <${ME_IMP_DEVICE_SETTING_FILE}>" 1>&2
  return "${me_imp_exit_code}"
fi

#####################################################################
# import exit code
#####################################################################

. "${ME_IMP_THIS_DIR}/define_exit_code.sh"

#####################################################################
# import sequence control 
#####################################################################

. "${ME_IMP_THIS_DIR}/sequence_control_wrapper.sh"

me_import_sequence_control
me_imp_exit_code=$?

if [ "${me_imp_exit_code}" -ne 0 ]; then
  echo "ERROR:${ME_IMP_THIS_FILE##*/}: import sequence control failed" 1>&2
  return "${me_imp_exit_code}"
fi

#####################################################################
# import database control
#####################################################################

. "${ME_IMP_THIS_DIR}/database_control_wrapper.sh"

#####################################################################
# import realdevice control
#####################################################################

. "${ME_IMP_THIS_DIR}/realdevice_control_wrapper.sh"

me_import_realdevice_control
me_imp_exit_code=$?

if [ "${me_imp_exit_code}" -ne 0 ]; then
  echo "ERROR:${ME_IMP_THIS_FILE##*/}: import realdevice control failed" 1>&2
  return "${me_imp_exit_code}"
fi

#####################################################################
# cleanup
#####################################################################

unset ME_IMP_DEVICE_NAME
unset ME_IMP_THIS_FILE
unset ME_IMP_THIS_DIR
unset ME_IMP_SCRIPT_DIR
unset ME_IMP_TOP_DIR
unset ME_IMP_DEVICE_DIR
unset ME_IMP_DEVICE_SETTING_FILE

unset me_imp_exit_code
