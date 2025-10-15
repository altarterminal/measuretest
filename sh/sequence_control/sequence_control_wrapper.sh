#!/bin/bash
set -u

me_import_sequence_control() {
  local me_this_file
  local me_this_dir

  me_this_file=$(realpath "${BASH_SOURCE[0]}")
  me_this_dir=$(dirname "${me_this_file}")

  . "${me_this_dir}/control_unit_evaluation.sh"
  . "${me_this_dir}/check_interface_implement.sh"
  . "${me_this_dir}/get_peripheral_condition.sh"
}

me_stable_setup_all() {
  local ME_REPEAT_NUM=3

  local me_exit_code
  local me_this_file
  local me_i

  me_this_file=$(realpath "${BASH_SOURCE[0]}")

  if ! type me_setup_all >/dev/null 2>&1; then
    echo "ERROR:${me_this_file##*/}: me_setup_all not defined" 1>&2
    return 1
  fi

  for me_i in $(seq 1 "${ME_REPEAT_NUM}"); do
    me_setup_all
    me_exit_code=$?

    if [ "${me_exit_code}" -eq 0 ]; then
      echo "INFO:${me_this_file##*/}: me_setup_all succeeded <${me_i}>" 1>&2
      return 0
    else
      echo "ERROR:${me_this_file##*/}: me_setup_all failed <${me_i}>" 1>&2

      if [ "${me_i}" -eq "${ME_REPEAT_NUM}" ]; then
        echo "ERROR:${me_this_file##*/}: me_setup_all failed max times <${ME_REPEAT_NUM}>" 1>&2
        return 1
      fi
    fi
  done
}
