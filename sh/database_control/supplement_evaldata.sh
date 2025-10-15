#!/bin/bash
set -u

#####################################################################
# help
#####################################################################

print_usage_and_exit() {
  cat <<USAGE 1>&2
Usage   : ${0##*/} -l<log path> -p<peripheral file> -m<image md5sum> <src dir> <dst dir>
Options : 

Supplement the raw evaldata in <src dir> and store in <dst dir>.

-l: Specify the dir to put evaluation log in.
-p: Specify the file path in which the peripheral conditions are.
-m: Specify the image md5sum.
USAGE
  exit 1
}

#####################################################################
# parameter
#####################################################################

opr_s=''
opr_d=''

opt_l=''
opt_p=''
opt_m=''

i=1
for arg in ${1+"$@"}; do
  case "${arg}" in
    -h|--help|--version) print_usage_and_exit ;;
    -l*)                 opt_l="${arg#-l}"    ;;
    -p*)                 opt_p="${arg#-p}"    ;;
    -m*)                 opt_m="${arg#-m}"    ;;
    *)
      if   [ $((i+1)) -eq $# ] && [ -z "${opr_s}" ]; then
        opr_s="${arg}"
      elif [ $((i+0)) -eq $# ] && [ -z "${opr_d}" ]; then
        opr_d="${arg}"
      else
        echo "ERROR:${0##*/}: invalid args" 1>&2
        exit 1
      fi
      ;;
  esac

  i=$((i + 1))
done

if [ -z "${opr_s}" ]; then
  echo "ERROR:${0##*/}: src directory must be specified" 1>&2
  exit 1
fi

if [ -z "${opr_d}" ]; then
  echo "ERROR:${0##*/}: dst directory must be specified" 1>&2
  exit 1
fi

if [ -z "${opt_l}" ]; then
  echo "ERROR:${0##*/}: log path must be specified" 1>&2
  exit 1
fi

if [ -z "${opt_p}" ]; then
  echo "ERROR:${0##*/}: peripheral file must be specified" 1>&2
  exit 1
fi

if [ -z "${opt_m}" ]; then
  echo "ERROR:${0##*/}: image md5sum must be specified" 1>&2
  exit 1
fi

SRC_DIR="${opr_s}"
DST_DIR="${opr_d}"

LOG_PATH="${opt_l}"
PERIPHERAL_FILE="${opt_p}"
IMAGE_MD5SUM="${opt_m}"

#####################################################################
# common setting
#####################################################################

THIS_DIR=$(dirname "$(realpath "$0")")
SETTING_FILE="${THIS_DIR}/../enable_setting.sh"

if [ ! -f "${SETTING_FILE}" ]; then
  echo "ERROR:${0##*/}: setting file not found <${SETTING_FILE}>" 1>&2
  exit 1
fi

. "${SETTING_FILE}"

#####################################################################
# setting
#####################################################################

ABS_LOG_DIR=${ME_ABS_LOG_DIR%/}/
MEASURER_MAIL=${ME_MEASURER_MAIL}
REALDEVICE_SERIAL=${ME_REALDEVICE_SERIAL}

#####################################################################
# check target files
#####################################################################

src_json_list=$(find "${SRC_DIR}" -maxdepth 1 -name '*.json' -type f)

if [ -z "${src_json_list}" ]; then
  echo "ERROR:${0##*/}: no file found <${SRC_DIR}>" 1>&2
  exit 1
fi

printf '%s\n' "${src_json_list}" |
  while read -r src_json; do
    if ! jq . "${src_json}" >/dev/null 2>&1; then
      echo "ERROR:${0##*/}: not follow the JSON format <${src_json}>" 1>&2
      exit 1
    fi
  done
exit_code=$?

if [ "${exit_code}" -ne 0 ]; then
  echo "ERROR:${0##*/}: some files are invalid for JSON" 1>&2
  exit "${exit_code}"
fi

#####################################################################
# get relative log path
#####################################################################

if printf '%s\n' "${LOG_PATH}" | grep -q '^/'; then
  if ! printf '%s\n' "${LOG_PATH}" | grep -q '^'"${ABS_LOG_DIR}"; then
    echo "ERROR:${0##*/}: invalid path specified <${LOG_PATH}>" 1>&2
    exit 1
  fi

  relative_log_path=$(
    printf '%s\n' "${LOG_PATH}" | sed 's!^'"${ABS_LOG_DIR%/}/"'!!'
  )
else
  relative_log_path=${LOG_PATH}
fi

#####################################################################
# get peripheral status
#####################################################################

if ! jq . "${PERIPHERAL_FILE}" >/dev/null 2>&1; then
  echo "ERROR:${0##*/}: invalid json specified <${PERIPHERAL_FILE}>" 1>&2
  exit 1
fi

peripheral_content=$(jq '@json' "${PERIPHERAL_FILE}")

#####################################################################
# prepare
#####################################################################

mkdir -p "${DST_DIR}"

#####################################################################
# convert
#####################################################################

printf '%s\n' "${src_json_list}" |
  while read -r src_json; do
    dst_json_base=$(basename "${src_json}")
    dst_json=${DST_DIR}/${dst_json_base}

    is_list=$(jq 'type == "array"' "${src_json}")

    if [ "${is_list}" = 'true' ]; then
      jq -c '.[]' "${src_json}"
    else
      jq -c '.' "${src_json}"
    fi |
      while read -r unit_data; do
        printf '%s\n' "${unit_data}" |
          jq '.+ {"measurer_mail": "'"${MEASURER_MAIL}"'"}' |
          jq '.+ {"image_md5sum": "'"${IMAGE_MD5SUM}"'"}' |
          jq '.+ {"realdevice_serial": "'"${REALDEVICE_SERIAL}"'"}' |
          jq '.+ {"log_path": "'"${relative_log_path}"'"}' |
          jq '.+ {"peripheral_condition": '"${peripheral_content}"'}'
      done |
      jq -s >"${dst_json}"
  done
