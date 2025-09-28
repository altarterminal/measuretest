#!/bin/bash
set -u

#####################################################################
# help
#####################################################################

print_usage_and_exit() {
  cat <<USAGE 1>&2
Usage   : ${0##*/}
Options :

Cleanup the environment.
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

#####################################################################
# common setting
#####################################################################

THIS_DIR=$(dirname "$(realpath "$0")")
SETTING_FILE="${THIS_DIR}/../enable_setting.sh"

if [ ! -f "${SETTING_FILE}" ]; then
  echo "INFO:${0##*/}: setting file not found <${SETTING_FILE}>" 1>&2
  exit 0
fi

. "${SETTING_FILE}"

#####################################################################
# check
#####################################################################

if [ -z "${ME_DATABASE_DIR}" ]; then
  echo "ERROR:${0##*/}: ME_DATABASE_DIR not set <${SETTING_FILE}>" 1>&2
  exit 1
fi

if [ ! -d "${ME_DATABASE_DIR}" ]; then
  echo "ERROR:${0##*/}: invalid dir specified <${ME_DATABASE_DIR}>" 1>&2
  exit 1
fi

#####################################################################
# cleanup
#####################################################################

rm -rf "${ME_DATABASE_DIR}"
rm "${SETTING_FILE}"
