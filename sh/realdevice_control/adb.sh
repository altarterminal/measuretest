#!/bin/bash
set -u

me_adb_run_command() {
  local ME_VM_NAME=$1
  local ME_COMMAND=$2

  local me_exit_code
  local me_this_file

  me_this_file=$(realpath "${BASH_SOURCE[0]}")

  if ! vmadb_run_command >/dev/null 2>&1; then
    echo "ERROR:${me_this_file##*/}: function not defined <vmadb_run_command>" 1>&2
    return 1
  fi

  (
    cd "${ME_HARDTOOL_DIR}"
    vmadb_run_command "${ME_VM_NAME}" "${ME_COMMAND}"
  )
  me_exit_code=$?

  if [ "${me_exit_code}" -ne 0 ]; then
    echo "ERROR:${me_this_file##*/}: adb run command failed <${ME_VM_NAME},${ME_COMMAND}>" 1>&2
    return "${me_exit_code}"
  fi
}

me_adb_push() {
  local ME_VM_NAME=$1
  local ME_LOCAL_PATH=$2
  local ME_REMOTE_PATH=$3

  local me_exit_code
  local me_this_file
  local me_abs_localpath

  me_this_file=$(realpath "${BASH_SOURCE[0]}")

  if ! vmadb_push >/dev/null 2>&1; then
    echo "ERROR:${me_this_file##*/}: function not defined <vmadb_push>" 1>&2
    return 1
  fi

  me_abs_localpath=$(realpath "${ME_LOCAL_PATH}")

  (
    cd "${ME_HARDTOOL_DIR}"
    vmadb_push "${ME_VM_NAME}" "${me_abs_localpath}" "${ME_REMOTE_PATH}"
  )
  me_exit_code=$?

  if [ "${me_exit_code}" -ne 0 ]; then
    echo "ERROR:${me_this_file##*/}: adb push failed <${ME_VM_NAME},${ME_LOCAL_PATH}>" 1>&2
    return "${me_exit_code}"
  fi
}

me_adb_pull() {
  local ME_VM_NAME=$1
  local ME_REMOTE_PATH=$2
  local ME_LOCAL_PATH=$3

  local me_exit_code
  local me_this_file
  local me_abs_localpath

  me_this_file=$(realpath "${BASH_SOURCE[0]}")

  if ! vmadb_pull >/dev/null 2>&1; then
    echo "ERROR:${me_this_file##*/}: function not defined <vmadb_pull>" 1>&2
    return 1
  fi

  me_abs_localpath=$(realpath "${ME_LOCAL_PATH}")

  (
    cd "${ME_HARDTOOL_DIR}"
    vmadb_push "${ME_VM_NAME}" "${ME_REMOTE_PATH}" "${me_abs_localpath}"
  )
  me_exit_code=$?

  if [ "${me_exit_code}" -ne 0 ]; then
    echo "ERROR:${me_this_file##*/}: adb pull failed <${ME_VM_NAME},${ME_REMOTE_PATH}>" 1>&2
    return "${me_exit_code}"
  fi
}

me_adb_install() {
  local ME_VM_NAME=$1
  local ME_APK_FILE=$2

  local me_exit_code
  local me_this_file
  local me_abs_apk_file

  me_this_file=$(realpath "${BASH_SOURCE[0]}")

  if ! vmadb_install >/dev/null 2>&1; then
    echo "ERROR:${me_this_file##*/}: function not defined <vmadb_install>" 1>&2
    return 1
  fi

  me_abs_apk_file=$(realpath "${ME_APK_FILE}")

  (
    cd "${ME_HARDTOOL_DIR}"
    vmadb_install "${ME_VM_NAME}" "${me_abs_apk_file}"
  )
  me_exit_code=$?

  if [ "${me_exit_code}" -ne 0 ]; then
    echo "ERROR:${me_this_file##*/}: adb install failed <${ME_VM_NAME},${APK_FILE}>" 1>&2
    return "${me_exit_code}"
  fi
}

me_adb_uninstall() {
  local ME_VM_NAME=$1
  local ME_PACKAGE_NAME=$2

  local me_exit_code
  local me_this_file

  me_this_file=$(realpath "${BASH_SOURCE[0]}")

  if ! vmadb_uninstall >/dev/null 2>&1; then
    echo "ERROR:${me_this_file##*/}: function not defined <vmadb_uninstall>" 1>&2
    return 1
  fi

  (
    cd "${ME_HARDTOOL_DIR}"
    vmadb_install "${ME_VM_NAME}" "${ME_PACKAGE_NAME}"
  )
  me_exit_code=$?

  if [ "${me_exit_code}" -ne 0 ]; then
    echo "ERROR:${me_this_file##*/}: adb uninstall failed <${ME_VM_NAME},${ME_PACKAGE_NAME}>" 1>&2
    return "${me_exit_code}"
  fi
}
