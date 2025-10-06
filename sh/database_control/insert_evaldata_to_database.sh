#!/bin/bash
set -u

#####################################################################
# help
#####################################################################

print_usage_and_exit() {
  cat <<USAGE 1>&2
Usage   : ${0##*/} <device name> <evaldata dir>
Options : -g

Insert evaldata in <evaldata dir> into the database.

-g: Set the measure group id to the same one of the last data (default: new id).
USAGE
  exit 1
}

#####################################################################
# parameter
#####################################################################

opr_n=''
opr_e=''
opt_g='no'

i=1
for arg in ${1+"$@"}; do
  case "${arg}" in
    -h|--help|--version) print_usage_and_exit ;;
    -g)                  opt_g='yes'          ;;
    *)
      if [ $((i + 1)) -eq $# ] && [ -z "${opr_n}" ]; then
        opr_n="${arg}"
      elif [ $i -eq $# ] && [ -z "${opr_e}" ]; then
        opr_e="${arg}"
      else
        echo "ERROR:${0##*/}: invalid args" 1>&2
        exit 1
      fi
      ;;
  esac

  i=$((i + 1))
done

if [ -z "${opr}" ]; then
  echo "ERROR:${0##*/}: evaldata directory must be specified" 1>&2
  exit 1
fi

if [ ! -d "${opr}" ]; then
  echo "ERROR:${0##*/}: invalid directory specified <${opr}>" 1>&2
  exit 1
fi

DEVICE_NAME="${opr_n}"
EVALDATA_DIR="${opr_e}"

IS_SAME_GROUP="${opt_g}"

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

PROJECT_NAME="${ME_PROJECT_NAME}"
PROJECT_VERSION="${ME_PROJECT_VERSION}"

LIST_FILE="${EVALDATA_DIR}/_evaldata_list.txt"

IF_DIR="${ME_DATABASE_DIR}/if"
IF_SCRIPT="${IF_DIR}/db_insert_evaldata.sh"

if [ "${IS_SAME_GROUP}" = 'yes' ]; then
  OPT_SAME_GROUP='-g'
else
  OPT_SAME_GROUP=''
fi

#####################################################################
# check directory
#####################################################################

evaldata_list=(find "${EVALDATA_DIR}" -maxdepth 1 -name '*.json' -type f)

if [ -z "${evaldata_list}" ]; then
  echo "ERROR:${0##*/}: no file found <${EVALDATA_DIR}>" 1>&2
  exit 1
fi

#####################################################################
# prepare list
#####################################################################

printf '%s\n' "${evaldata_list}" | xargs -L 1 realpath >"${LIST_FILE}"

#####################################################################
# insert
#####################################################################

"${IF_SCRIPT}" ${OPT_SAME_GROUP} -l \
  "${PROJECT_NAME}" "${PROJECT_VERSION}" "${DEVICE_NAME}" \
  "${LIST_FILE}"
