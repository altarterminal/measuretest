#!/bin/bash
set -u

me_adb_run_command() {
  local THIS_FILE=${BASH_SOURCE[0]}
  local VM_NAME=$1
  local COMMAND=$2

  local exit_code

  if ! vmadb_run_command >/dev/null 2>&1; then
    echo "ERROR:${THIS_FILE##*/}: function not defined <vmadb_run_command>" 1>&2
    return 1
  fi

  vmadb_run_command "${VM_NAME}" "${COMMAND}"
  exit_code=$?

  if [ "${exit_code}" -ne 0 ]; then
    echo "ERROR:${THIS_FILE##*/}: adb run command failed <${VM_NAME},${COMMAND}>" 1>&2
    return "${exit_code}"
  fi
}

me_adb_push() {
  local THIS_FILE=${BASH_SOURCE[0]}
  local VM_NAME=$1
  local LOCAL_PATH=$2
  local REMOTE_PATH=$3

  local exit_code

  if ! vmadb_push >/dev/null 2>&1; then
    echo "ERROR:${THIS_FILE##*/}: function not defined <vmadb_push>" 1>&2
    return 1
  fi

  me_adb_push "${VM_NAME}" "${LOCAL_PATH}" "${REMOTE_PATH}"
  exit_code=$?

  if [ "${exit_code}" -ne 0 ]; then
    echo "ERROR:${THIS_FILE##*/}: adb push failed <${VM_NAME},${LOCAL_PATH}>" 1>&2
    return "${exit_code}"
  fi
}

me_adb_pull() {
  local THIS_FILE=${BASH_SOURCE[0]}
  local VM_NAME=$1
  local REMOTE_PATH=$2
  local LOCAL_PATH=$3

  local exit_code

  if ! vmadb_pull >/dev/null 2>&1; then
    echo "ERROR:${THIS_FILE##*/}: function not defined <vmadb_pull>" 1>&2
    return 1
  fi

  me_adb_push "${VM_NAME}" "${REMOTE_PATH}" "${LOCAL_PATH}"
  exit_code=$?

  if [ "${exit_code}" -ne 0 ]; then
    echo "ERROR:${THIS_FILE##*/}: adb pull failed <${VM_NAME},${REMOTE_PATH}>" 1>&2
    return "${exit_code}"
  fi
}

me_adb_install() {
  local THIS_FILE=${BASH_SOURCE[0]}
  local VM_NAME=$1
  local APK_FILE=$2

  local exit_code

  if ! vmadb_install >/dev/null 2>&1; then
    echo "ERROR:${THIS_FILE##*/}: function not defined <vmadb_install>" 1>&2
    return 1
  fi

  me_adb_install "${VM_NAME}" "${APK_FILE}"
  exit_code=$?

  if [ "${exit_code}" -ne 0 ]; then
    echo "ERROR:${THIS_FILE##*/}: adb install failed <${VM_NAME},${APK_FILE}>" 1>&2
    return "${exit_code}"
  fi
}

me_adb_uninstall() {
  local THIS_FILE=${BASH_SOURCE[0]}
  local VM_NAME=$1
  local PACKAGE_NAME=$2

  local exit_code

  if ! vmadb_uninstall >/dev/null 2>&1; then
    echo "ERROR:${THIS_FILE##*/}: function not defined <vmadb_uninstall>" 1>&2
    return 1
  fi

  me_adb_install "${VM_NAME}" "${PACKAGE_NAME}"
  exit_code=$?

  if [ "${exit_code}" -ne 0 ]; then
    echo "ERROR:${THIS_FILE##*/}: adb uninstall failed <${VM_NAME},${PACKAGE_NAME}>" 1>&2
    return "${exit_code}"
  fi
}
