#!/bin/bash
set -u

#####################################################################
# help
#####################################################################

print_usage_and_exit() {
  cat <<USAGE 1>&2
Usage   : ${0##*/} <image md5sum>
Options : 

Get an image information.
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

if ! printf '%s\n' "${opr}" | grep -Eq '^[a-f0-9]{32}$'; then
  echo "ERROR:${0##*/}: invalid md5sum specified <${opr}>" 1>&2
  exit 1
fi

IMAGE_MD5SUM="${opr}"

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
IF_SCRIPT="${IF_DIR}/get_image.sh"

#####################################################################
# call if
#####################################################################

info=$("${IF_SCRIPT}" "${IMAGE_MD5SUM}")
exit_code=$?

if [ "${exit_code}" -ne 0 ]; then
  echo "ERROR:${0##*/}: get info failed" 1>&2
  exit "${exit_code}"
fi

printf '%s\n' "${info}"
