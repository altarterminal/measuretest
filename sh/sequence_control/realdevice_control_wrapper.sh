#!/bin/bash
set -u

me_import_realdevice_control() {
  local me_exit_code
  local me_this_file
  local me_this_dir
  local me_realdevice_control_dir

  me_this_file=$(realpath "${BASH_SOURCE[0]}")
  me_this_dir=$(dirname "${me_this_file}")
  me_realdevice_control_dir="${me_this_dir}/../realdevice_control"

  . "${me_realdevice_control_dir}/realdevice_control_setting.sh"
  me_exit_code=$?

  if [ "${me_exit_code}" -ne 0 ]; then
    echo "ERROR:${me_this_file##*/}: import failed <realdevice_control_setting.sh>" 1>&2
    return "${me_exit_code}"
  fi

  . "${me_realdevice_control_dir}/flash_image.sh"
  . "${me_realdevice_control_dir}/power_on_board.sh"
  . "${me_realdevice_control_dir}/power_off_board.sh"
  . "${me_realdevice_control_dir}/boot_process.sh"
  . "${me_realdevice_control_dir}/shutdown_process.sh"
  . "${me_realdevice_control_dir}/serial.sh"
  . "${me_realdevice_control_dir}/adb.sh"
}
