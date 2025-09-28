#!/bin/bash
set -u

#####################################################################
# help
#####################################################################

print_usage_and_exit() {
  cat <<USAGE 1>&2
Usage   : ${0##*/} <project name> <project version>
Options : 

Get an environment template information.
USAGE
  exit 1
}

#####################################################################
# parameter
#####################################################################

opr_p=''
opr_v=''

i=1
for arg in ${1+"$@"}; do
  case "${arg}" in
    -h|--help|--version) print_usage_and_exit ;;
    *)
      if   [ $((i+1)) -eq $# ] && [ -z "${opr_p}" ]; then
        opr_p="${arg}"
      elif [ $((i+0)) -eq $# ] && [ -z "${opr_v}" ]; then
        opr_v="${arg}"
      else
        echo "ERROR:${0##*/}: invalid args" 1>&2
        exit 1
      fi
      ;;
  esac

  i=$((i + 1))
done

if [ -z "${opr_p}" ]; then
  echo "ERROR:${0##*/}: project name must be specified" 1>&2
  exit 1
fi

if [ -z "${opr_v}" ]; then
  echo "ERROR:${0##*/}: project version must be specified" 1>&2
  exit 1
fi

PROJECT_NAME="${opr_p}"
PROJECT_VERSION="${opr_v}"

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

IF_DIR=${COMMON_DATABASE_IF_DIR}
IF_SCRIPT="${IF_DIR}/get_env_template.sh"

#####################################################################
# call if
#####################################################################

info=$("${IF_SCRIPT}" "${PROJECT_NAME}" "${PROJECT_VERSION}")
exit_code=$?

if [ "${exit_code}" -ne 0 ]; then
  echo "ERROR:${0##*/}: get info failed" 1>&2
  exit "${exit_code}"
fi

printf '%s\n' "${info}"
