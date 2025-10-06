#!/bin/bash
set -u

me_adb_run_command() {
  local ME_THIS_FILE=$(realpath "${BASH_SOURCE[0]}")
  local ME_VM_NAME=$1
  local ME_COMMAND=$2

  local me_exit_code

  if ! vmadb_run_command >/dev/null 2>&1; then
    echo "ERROR:${ME_THIS_FILE##*/}: function not defined <vmadb_run_command>" 1>&2
    return 1
  fi

  (
    cd "${ME_HARDTOOL_DIR}"
    vmadb_run_command "${ME_VM_NAME}" "${ME_COMMAND}"
  )
  me_exit_code=$?

  if [ "${me_exit_code}" -ne 0 ]; then
    echo "ERROR:${ME_THIS_FILE##*/}: adb run command failed <${ME_VM_NAME},${ME_COMMAND}>" 1>&2
    return "${me_exit_code}"
  fi
}

me_adb_push() {
  local ME_THIS_FILE=$(realpath "${BASH_SOURCE[0]}")
  local ME_VM_NAME=$1
  local ME_LOCAL_PATH=$2
  local ME_REMOTE_PATH=$3

  local me_exit_code
  local me_abs_localpath

  if ! vmadb_push >/dev/null 2>&1; then
    echo "ERROR:${ME_THIS_FILE##*/}: function not defined <vmadb_push>" 1>&2
    return 1
  fi

  me_abs_localpath=$(realpath "${ME_LOCAL_PATH}")

  (
    cd "${ME_HARDTOOL_DIR}"
    me_adb_push "${ME_VM_NAME}" "${me_abs_localpath}" "${ME_REMOTE_PATH}"
  )
  me_exit_code=$?

  if [ "${me_exit_code}" -ne 0 ]; then
    echo "ERROR:${ME_THIS_FILE##*/}: adb push failed <${ME_VM_NAME},${ME_LOCAL_PATH}>" 1>&2
    return "${me_exit_code}"
  fi
}

me_adb_pull() {
  local ME_THIS_FILE=$(realpath "${BASH_SOURCE[0]}")
  local ME_VM_NAME=$1
  local ME_REMOTE_PATH=$2
  local ME_LOCAL_PATH=$3

  local me_exit_code
  local me_abs_localpath

  if ! vmadb_pull >/dev/null 2>&1; then
    echo "ERROR:${ME_THIS_FILE##*/}: function not defined <vmadb_pull>" 1>&2
    return 1
  fi

  me_abs_localpath=$(realpath "${ME_LOCAL_PATH}")

  (
    cd "${ME_HARDTOOL_DIR}"
    me_adb_push "${ME_VM_NAME}" "${ME_REMOTE_PATH}" "${me_abs_localpath}"
  )
  me_exit_code=$?

  if [ "${me_exit_code}" -ne 0 ]; then
    echo "ERROR:${ME_THIS_FILE##*/}: adb pull failed <${ME_VM_NAME},${ME_REMOTE_PATH}>" 1>&2
    return "${me_exit_code}"
  fi
}

me_adb_install() {
  local ME_THIS_FILE=$(realpath "${BASH_SOURCE[0]}")
  local ME_VM_NAME=$1
  local ME_APK_FILE=$2

  local me_exit_code
  local me_abs_apk_file

  if ! vmadb_install >/dev/null 2>&1; then
    echo "ERROR:${ME_THIS_FILE##*/}: function not defined <vmadb_install>" 1>&2
    return 1
  fi

  me_abs_apk_file=$(realpath "${ME_APK_FILE}")

  (
    cd "${ME_HARDTOOL_DIR}"
    me_adb_install "${ME_VM_NAME}" "${me_abs_apk_file}"
  )
  me_exit_code=$?

  if [ "${me_exit_code}" -ne 0 ]; then
    echo "ERROR:${ME_THIS_FILE##*/}: adb install failed <${ME_VM_NAME},${APK_FILE}>" 1>&2
    return "${me_exit_code}"
  fi
}

me_adb_uninstall() {
  local ME_THIS_FILE=$(realpath "${BASH_SOURCE[0]}")
  local ME_VM_NAME=$1
  local ME_PACKAGE_NAME=$2

  local me_exit_code

  if ! vmadb_uninstall >/dev/null 2>&1; then
    echo "ERROR:${ME_THIS_FILE##*/}: function not defined <vmadb_uninstall>" 1>&2
    return 1
  fi

  (
    cd "${ME_HARDTOOL_DIR}"
    me_adb_install "${ME_VM_NAME}" "${ME_PACKAGE_NAME}"
  )
  me_exit_code=$?

  if [ "${me_exit_code}" -ne 0 ]; then
    echo "ERROR:${ME_THIS_FILE##*/}: adb uninstall failed <${ME_VM_NAME},${ME_PACKAGE_NAME}>" 1>&2
    return "${me_exit_code}"
  fi
}
