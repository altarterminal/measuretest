#!/bin/bash
set -u

me_insert_evaldata_to_database() {
  local me_this_file
  local me_this_dir
  local me_database_control_dir

  me_this_file=$(realpath "${BASH_SOURCE[0]}")
  me_this_dir=$(dirname "${me_this_file}")
  me_database_control_dir="${me_this_dir}/../database_control"

  "${me_database_control_dir}/insert_evaldata_to_database.sh" "$@"
}

me_supplement_evaldata() {
  local me_this_file
  local me_this_dir
  local me_database_control_dir

  me_this_file=$(realpath "${BASH_SOURCE[0]}")
  me_this_dir=$(dirname "${me_this_file}")
  me_database_control_dir="${me_this_dir}/../database_control"

  "${me_database_control_dir}/supplement_evaldata.sh" "$@"
}
