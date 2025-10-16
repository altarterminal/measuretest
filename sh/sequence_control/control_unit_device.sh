#!/bin/bash
set -u

#####################################################################
# help
#####################################################################

print_usage_and_exit() {
  cat <<USAGE 1>&2
Usage   : ${0##*/} <device name>
Options :

Execute evaluation of a device.
USAGE
  exit 1
}

#####################################################################
# parameter
#####################################################################

opr=''

i=1
for arg in ${1+"$@"}; do
  case "${arg}" in
    -h|--help|--version) print_usage_and_exit ;;
    *)
      if [ $i -eq $# ] && [ -z "${opr}" ]; then
        opr="${arg}"
      else
        echo "ERROR:${0##*/}: invalid args" 1>&2
        exit 1
      fi
      ;;
  esac

  i=$((i + 1))
done

if [ -z "${opr}" ]; then
  echo "ERROR:${0##*/}: device name must be specified" 1>&2
  exit 1
fi

ME_DEVICE_NAME="${opr}"

#####################################################################
# common setting
#####################################################################

ME_THIS_DIR=$(dirname "$(realpath "$0")")
ME_SETTING_FILE="${ME_THIS_DIR}/../enable_setting.sh"

if [ ! -f "${ME_SETTING_FILE}" ]; then
  echo "ERROR:${0##*/}: setting file not found <${ME_SETTING_FILE}>" 1>&2
  exit 1
fi

. "${ME_SETTING_FILE}"

#####################################################################
# setting
#####################################################################

ME_SCRIPT_DIR=$(dirname "${ME_THIS_DIR}")
ME_TOP_DIR=$(dirname "${ME_SCRIPT_DIR}")

ME_THIS_DATE=$(date '+%Y%m%d_%H%M%S')

ME_DEVICE_DIR="${ME_TOP_DIR}/device/${ME_DEVICE_NAME}"
ME_DEVICE_PARAM_FILE="${ME_DEVICE_DIR}/params.json"

ME_DEVICE_LOG_DIR="${ME_ABS_LOG_DIR}/${ME_DEVICE_NAME}"
ME_EVAL_LOG_DIR="${ME_DEVICE_LOG_DIR}/${ME_THIS_DATE}"

ME_DB_CONTROL_DIR="${ME_SCRIPT_DIR}/database_control"
ME_GET_IMAGE_INFO_SCRIPT="${ME_DB_CONTROL_DIR}/get_image_info.sh"

ME_TEMP_PARAM_NAME="${TMPDIR:-/tmp}/${0##*/}_${ME_THIS_DATE}_param_XXXXXX"
ME_PERIPHERAL_NAME="${TMPDIR:-/tmp}/${0##*/}_${ME_THIS_DATE}_perif_XXXXXX"

me_exit_proc=':'

trap '${me_exit_proc}' EXIT

#####################################################################
# check parameter
#####################################################################

if [ -z "${ME_ABS_LOG_DIR:-}" ]; then
  echo "ERROR:${0##*/}: variable not set <ME_ABS_LOG_DIR>" 1>&2
  exit 1
fi

if [ ! -d "${ME_ABS_LOG_DIR}" ] || [ ! -w "${ME_ABS_LOG_DIR}" ]; then
  echo "ERROR:${0##*/}: invalid path specified <${ME_ABS_LOG_DIR}>" 1>&2
  exit 1
fi

if [ -z "${ME_ABS_IMAGE_DIR:-}" ]; then
  echo "ERROR:${0##*/}: variable not set <ME_ABS_IMAGE_DIR>" 1>&2
  exit 1
fi

if [ ! -d "${ME_ABS_IMAGE_DIR}" ] || [ ! -r "${ME_ABS_IMAGE_DIR}" ]; then
  echo "ERROR:${0##*/}: invalid path specified <${ME_ABS_IMAGE_DIR}>" 1>&2
  exit 1
fi

#####################################################################
# check device's files
#####################################################################

if [ ! -d "${ME_DEVICE_DIR}" ]; then
  echo "ERROR:${0##*/}: device's dir not found <${ME_ME_DIR}>" 1>&2
  exit 1
fi

if [ ! -f "${ME_DEVICE_PARAM_FILE}" ]; then
  echo "ERROR:${0##*/}: device's param file not found <${ME_DEVICE_PARAM_FILE}>" 1>&2
  exit 1
fi

me_param_num=$(jq '. | length' "${ME_DEVICE_PARAM_FILE}")

if ! printf '%s\n' "${me_param_num}" | grep -Eq '^[0-9]+$'; then
  echo "ERROR:${0##*/}: invalid parameters <${ME_DEVICE_PARAM_FILE}>" 1>&2
  exit 1
fi

#####################################################################
# import definition
#####################################################################

. "${ME_THIS_DIR}/import_definition.sh" "${ME_DEVICE_NAME}"
me_exit_code=$?

if [ "${me_exit_code}" -ne 0 ]; then
  echo "ERROR:${0##*/}: import definition failed" 1>&2
  exit "${me_exit_code}"
fi

#####################################################################
# check interface implmentation
#####################################################################

me_check_interface_implement
me_exit_code=$?

if [ "${me_exit_code}" -ne 0 ]; then
  echo "ERROR:${0##*/}: check interface failed" 1>&2
  exit "${me_exit_code}"
fi

#####################################################################
# check image path
#####################################################################

if [ -n "${ME_CUSTOM_IMAGE_MD5SUM:-}" ]; then
  me_image_md5sum="${ME_CUSTOM_IMAGE_MD5SUM}"
else
  me_image_md5sum="${ME_DEFAULT_IMAGE_MD5SUM}"
fi

if ! printf '%s\n' "${me_image_md5sum}" | grep -Eq '^[0-9a-f]{32}$'; then
  echo "ERROR:${0##*/}: invalid image md5sum <${me_image_md5sum}>" 1>&2
  exit 1
fi

me_image_info=$("${ME_GET_IMAGE_INFO_SCRIPT}" "${me_image_md5sum}")
me_exit_code=$?

if [ "${me_exit_code}" -ne 0 ]; then
  echo "ERROR:${0##*/}: get image info failed <${me_image_md5sum}>" 1>&2
  exit "${me_exit_code}"
fi

me_image_relative_path=$(
  printf '%s\n' "${me_image_info}" | jq -r '.image_relative_path'
)

me_image_file="${ME_ABS_IMAGE_DIR}/${me_image_relative_path}"

if [ ! -f "${me_image_file}" ] || [ ! -r "${me_image_file}" ]; then
  echo "ERROR:${0##*/}: invalid image path <${me_image_file}>" 1>&2
  exit 1
fi

me_actual_md5sum=$(md5sum "${me_image_file}" | awk '{ print $1; }')

if [ "${me_image_md5sum}" != "${me_actual_md5sum}" ]; then
  echo "ERROR:${0##*/}: image md5sum not match" 1>&2
  exit 1
fi

#####################################################################
# flash image
#####################################################################

me_flash_image "${me_image_file}"
me_exit_code=$?

if [ "${me_exit_code}" -ne 0 ]; then
  echo "ERROR:${0##*/}: flash image failed <${me_image_file}>" 1>&2
  exit "${me_exit_code}"
fi

#####################################################################
# confirm boot
#####################################################################

me_boot_process
me_exit_code=$?

if [ "${me_exit_code}" -ne 0 ]; then
  echo "ERROR:${0##*/}: boot process failed <${me_image_file}>" 1>&2
  exit "${me_exit_code}"
fi

me_exit_proc="${me_exit_proc}; me_shutdown_process"

#####################################################################
# prepare
#####################################################################

if ! mkdir -p "${ME_EVAL_LOG_DIR}"; then
  echo "ERROR:${0##*/}: cannot make log directory <${ME_EVAL_LOG_DIR}>" 1>&2
  exit 1
fi

cp "${ME_DEVICE_PARAM_FILE}" "${ME_DEVICE_LOG_DIR}"

#####################################################################
# move to working dirctory
#####################################################################

if ! cd "${ME_DEVICE_DIR}"; then
  echo "ERROR:${0##*/}: change directory failed <${ME_DEVICE_DIR}>" 1>&2
  exit 1
fi

#####################################################################
# get peripheral condition
#####################################################################

ME_PERIPHERAL_FILE=$(mktemp "${ME_PERIPHERAL_NAME}")

me_exit_proc="${me_exit_proc}; [ -e ${ME_PERIPHERAL_FILE} ] && rm ${ME_PERIPHERAL_FILE}"

me_get_peripheral_condition >"${ME_PERIPHERAL_FILE}"
me_exit_code=$?

if [ "${me_exit_code}" -ne 0 ]; then
  echo "ERROR:${0##*/}: get peripheral condition failed" 1>&2
  exit "${me_exit_code}"
fi

#####################################################################
# setup
#####################################################################

# instead of pure me_setup_all
me_stable_setup_all
me_exit_code=$?

if [ "${me_exit_code}" -ne 0 ]; then
  echo "ERROR:${0##*/}: setup failed <${ME_DEVICE_DIR}>" 1>&2
  exit 1
fi

me_exit_proc="${me_exit_proc}; me_cleanup_all"

#####################################################################
# set cleanup process
#####################################################################

ME_TEMP_PARAM_FILE=$(mktemp "${ME_TEMP_PARAM_NAME}")

me_exit_proc="${me_exit_proc}; [ -e ${ME_TEMP_PARAM_FILE} ] && rm ${ME_TEMP_PARAM_FILE}"

#####################################################################
# determine behavior for repeated error
#####################################################################

if [ -z "${ME_BEHAVIOR_AFTER_REPEATED_ERROR:-}" ]; then
  ME_IS_CONTINUE_EVAL='no'
elif [ "${ME_BEHAVIOR_AFTER_REPEATED_ERROR}" = '0' ]; then
  ME_IS_CONTINUE_EVAL='no'
else
  ME_IS_CONTINUE_EVAL='yes'
fi

#####################################################################
# variables in control part during execution
#####################################################################

me_t_device_name="${ME_DEVICE_NAME}"
me_t_device_param_file="${ME_DEVICE_PARAM_FILE}"

me_t_eval_log_dir="${ME_EVAL_LOG_DIR}"
me_t_param_num="${me_param_num}"

me_t_temp_param_file="${ME_TEMP_PARAM_FILE}"
me_t_peripheral_file="${ME_PERIPHERAL_FILE}"
me_t_image_md5sum="${me_image_md5sum}"

me_t_is_continue_eval="${ME_IS_CONTINUE_EVAL}"

me_t_exit_code=''
me_t_i=''

me_t_exit_proc="${me_exit_proc}"

trap '${me_t_exit_proc}' EXIT

#####################################################################
# cleanup definition
#####################################################################

unset ME_DEVICE_NAME
unset ME_DEFAULT_IMAGE_MD5SUM
unset ME_ABS_LOG_DIR
unset ME_ABS_IMAGE_DIR
unset ME_THIS_DIR
unset ME_SETTING_FILE

unset ME_SCRIPT_DIR
unset ME_TOP_DIR
unset ME_THIS_DATE

unset ME_DEVICE_DIR
unset ME_DEVICE_PARAM_FILE

unset ME_DEVICE_LOG_DIR
unset ME_EVAL_LOG_DIR
unset ME_DB_CONTROL_DIR
unset ME_GET_IMAGE_INFO_SCRIPT

unset ME_TEMP_PARAM_NAME
unset ME_TEMP_PARAM_FILE
unset ME_PERIPHERAL_NAME
unset ME_PERIPHERAL_FILE

unset ME_IS_CONTINUE_EVAL

unset me_exit_code
unset me_image_info
unset me_image_file
unset me_image_md5sum
unset me_actual_md5sum
unset me_image_relative_path
unset me_param_num
unset me_exit_proc

#####################################################################
# execute evaluation
#####################################################################

for me_t_i in $(seq 1 "${me_t_param_num}"); do
  jq ".[$((me_t_i - 1))]" "${me_t_device_param_file}" >"${me_t_temp_param_file}"

  me_control_unit_evaluation \
    "${me_t_device_name}" \
    "${me_t_eval_log_dir}" "${me_t_temp_param_file}" \
    "${me_t_peripheral_file}" "${me_t_image_md5sum}" \
    "${me_t_i}"
  me_t_exit_code=$?

  case "${me_t_exit_code}" in
    0)
      printf 'INFO:%s: %s <%s,%d>' \
        "${0##*/}" \
        "the evaluation succeeded" \
        "${me_t_device_name}" "${me_t_i}" 1>&2
      ;;
    "${ME_CONTROL_ERROR}")
      printf 'ERROR:%s: %s <%s,%d>' \
        "${0##*/}" \
        "the evaluation failed but proceed to the next evaluation" \
        "${me_t_device_name}" "${me_t_i}" 1>&2
      ;;
    "${ME_CONTROL_REPEAT_ERROR}")
      printf 'ERROR:%s: %s <%s,%d>' \
        "${0##*/}" \
        "the evaluation repeatedly failed" \
        "${me_t_device_name}" "${me_t_i}" 1>&2

      if [ "${me_t_is_continue_eval}" = 'yes' ]; then
        printf 'INFO:%s: %s' \
          "${0##*/}" \
          "the behavior setting is <continue> so procceed to the next evaluation" \
          1>&2
      else
        printf 'INFO:%s: %s' \
          "${0##*/}" \
          "the behavior setting is <NOT continue> so exit" \
          1>&2

        exit "${me_t_exit_code}"
      fi
      ;;
    *)
      printf 'FATAL:%s: %s <%s,%d>' \
        "${0##*/}" \
        "unknown error (${me_t_exit_code}) returned" \
        "${me_t_device_name}" "${me_t_i}"\
        1>&2
      exit "${me_t_exit_code}"
      ;;
  esac
done
