#!/bin/bash
set -u

#####################################################################
# help
#####################################################################

THIS_DIR=$(dirname "$(realpath "$0")")
SCRIPT_DIR=$(dirname "${THIS_DIR}")

print_usage_and_exit() {
  cat <<USAGE 1>&2
Usage   : ${0##*/} <param file>
Options : -o<setting enabler file>

Check the environment of execution and create required files.

-o: Specify the file to enable setting (default: ${SCRIPT_DIR}/enable_setting.sh)
USAGE
  exit 1
}

#####################################################################
# parameter
#####################################################################

opr=''
opt_o="${SCRIPT_DIR}/enable_setting.sh"

i=1
for arg in ${1+"$@"}; do
  case "${arg}" in
    -h|--help|--version) print_usage_and_exit ;;
    -o*)                 opt_o="${arg#-o}"    ;;
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

PARAM_FILE="${opr}"
ENABLER_FILE="${opt_o}"

#####################################################################
# setting
#####################################################################

TOP_DIR=$(dirname "${SCRIPT_DIR}")
REPO_DIR="${TOP_DIR}/repo"
DATABASE_CONTROL_DIR="${SCRIPT_DIR}/database_control"

DATABASE_URL='https://github.com/altarterminal/postgrestest.git'
DATABASE_DIR="${REPO_DIR}/$(basename "${DATABASE_URL}" .git)"

HARDTOOL_URL='https://replace.me.com/'
HARDTOOL_DIR="${REPO_DIR}/$(basename "${HARDTOOL_URL}" .git)"

#####################################################################
# import and check param
#####################################################################

if [ ! -f "${PARAM_FILE}" ] || [ ! -r "${PARAM_FILE}" ]; then
  echo "ERROR:${0##*/}: invalid file specified <${PARAM_FILE}>" 1>&2
  exit 1
fi

if ! jq . "${PARAM_FILE}" >/dev/null 2>&1; then
  echo "ERROR:${0##*/}: file not JSON <${PARAM_FILE}>" 1>&2
  exit 1
fi

PROJECT_NAME=$(jq -r '.PROJECT_NAME // empty' "${PARAM_FILE}")
PROJECT_VERSION=$(jq -r '.EVALUATION_SOFTWARE_VERSION // empty' "${PARAM_FILE}")
ABS_LOG_DIR=$(jq -r '.ABSOLUTE_LOG_PATH // empty' "${PARAM_FILE}")
ABS_IMAGE_DIR=$(jq -r '.ABSOLUTE_IMAGE_PATH // empty' "${PARAM_FILE}")
MEASURER_MAIL=$(jq -r '.MEASURER_MAIL // empty' "${PARAM_FILE}")

ABS_LOG_DIR=${ABS_LOG_DIR%/}
ABS_IMAGE_DIR=${ABS_IMAGE_DIR%/}

if [ -z "${PROJECT_NAME}" ]; then
  echo "ERROR:${0##*/}: PROJECT_NAME not found <${PARAM_FILE}>" 1>&2
  exit 1
fi

if [ -z "${PROJECT_VERSION}" ]; then
  echo "ERROR:${0##*/}: EVALUATION_SOFTWARE_VERSION not found <${PARAM_FILE}>" 1>&2
  exit 1
fi

if [ -z "${ABS_LOG_DIR}" ]; then
  echo "ERROR:${0##*/}: ABSOLUTE_LOG_PATH not found <${PARAM_FILE}>" 1>&2
  exit 1
fi

if [ -z "${ABS_IMAGE_DIR}" ]; then
  echo "ERROR:${0##*/}: ABSOLUTE_IMAGE_PATH not found <${PARAM_FILE}>" 1>&2
  exit 1
fi

if [ -z "${MEASURER_MAIL}" ]; then
  echo "ERROR:${0##*/}: MEASURER_MAIL not found <${PARAM_FILE}>" 1>&2
  exit 1
fi

if [ ! -d "${ABS_LOG_DIR}" ] || [ ! -w "${ABS_LOG_DIR}" ]; then
  echo "ERROR:${0##*/}: invalid path specified <${ABS_LOG_DIR}>" 1>&2
  exit 1
fi

if [ ! -d "${ABS_IMAGE_DIR}" ] || [ ! -r "${ABS_IMAGE_DIR}" ]; then
  echo "ERROR:${0##*/}: invalid path specified <${ABS_IMAGE_DIR}>" 1>&2
  exit 1
fi

#####################################################################
# setup database
#####################################################################

if [ -d "${DATABASE_DIR}" ]; then
  rm -rf "${DATABASE_DIR}"
fi

if ! git clone -q "${DATABASE_URL}" "${DATABASE_DIR}"; then
  echo "ERROR:${0##*/}: git clone failed <${DATABASE_URL}>" 1>&2
  exit 1
fi

"${DATABASE_DIR}/if/setup.sh" "${PARAM_FILE}"
exit_code=$?

if [ "${exit_code}" -ne 0 ]; then
  echo "ERROR:${0##*/}: database setup failed" 1>&2
  exit "${exit_code}"
fi

#####################################################################
# setup hardtool
#####################################################################

if [ -d "${HARDTOOL_DIR}" ]; then
  rm -rf "${HARDTOOL_DIR}"
fi

if ! git clone -q "${HARDTOOL_URL}" "${HARDTOOL_DIR}"; then
  echo "ERROR:${0##*/}: git clone failed <${HARDTOOL_URL}>" 1>&2
  exit 1
fi

"${HARDTOOL_DIR}/setup.sh"
exit_code=$?

if [ "${exit_code}" -ne 0 ]; then
  echo "ERROR:${0##*/}: hardtool setup failed" 1>&2
  exit "${exit_code}"
fi

#####################################################################
# output main setting
#####################################################################

trap '[ -e "${ENABLER_FILE}" ] && rm "${ENABLER_FILE}"' EXIT

: >"${ENABLER_FILE}"

cat <<EOF >>"${ENABLER_FILE}"
#!/bin/bash

export ME_DATABASE_DIR=${DATABASE_DIR}
export ME_HARDTOOL_DIR=${HARDTOOL_DIR}
export ME_PROJECT_NAME=${PROJECT_NAME}
export ME_PROJECT_VERSION=${PROJECT_VERSION}
export ME_ABS_LOG_DIR=${ABS_LOG_DIR}
export ME_ABS_IMAGE_DIR=${ABS_IMAGE_DIR}
export ME_MEASURER_MAIL=${MEASURER_MAIL}
EOF

#####################################################################
# get environment template
#####################################################################

env_template_info=$(
  "${DATABASE_CONTROL_DIR}/get_env_template_info.sh" \
    "${PROJECT_NAME}" "${PROJECT_VERSION}"
)
exit_code=$?

if [ "${exit_code}" -ne 0 ]; then
  echo "ERROR:${0##*/}: get environment template failed" 1>&2
  exit "${exit_code}"
fi

image_md5sum=$(
  printf '%s\n' "${env_template_info}" | jq -r '.image_md5sum // empty'
)

if ! printf '%s\n' "${image_md5sum}" | grep -Eq '^[0-9a-f]{32}$'; then
  echo "ERROR:${0##*/}: invalid image md5sum <${image_md5sum}>" 1>&2
  exit 1
fi

realdevice_serial=$(
  printf '%s\n' "${env_template_info}" | jq -r '.realdevice_serial // empty'
)

if ! printf '%s\n' "${realdevice_serial}" | grep -Eq '^[0-9a-f]{8}$'; then
  echo "ERROR:${0##*/}: invalid realdevice serial <${realdevice_serial}>" 1>&2
  exit 1
fi

#####################################################################
# output rest setting
#####################################################################

trap EXIT

cat <<EOF >>"${ENABLER_FILE}"
export ME_DEFAULT_IMAGE_MD5SUM=${image_md5sum}
export ME_REALDEVICE_SERIAL=${realdevice_serial}
EOF
