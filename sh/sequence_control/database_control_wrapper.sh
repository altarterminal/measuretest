#!/bin/bash
set -u

me_insert_evaldata_to_database() {
  local me_this_dir
  local me_script_dir
  local me_database_dir

  me_this_dir=$(dirname "${BASH_SOURCE[0]}")
  me_script_dir=$(dirname "${me_this_dir}")
  me_database_dir="${me_script_dir}/database_control"

  "${me_database_dir}/insert_evaldata_to_database.sh" "$@"
}

me_supplement_evaldata() {
  local me_this_dir
  local me_script_dir
  local me_database_dir

  me_this_dir=$(dirname "${BASH_SOURCE[0]}")
  me_script_dir=$(dirname "${me_this_dir}")
  me_database_dir="${me_script_dir}/supplement_evaldata"
  
  "${me_database_dir}/supplement_evaldata.sh" "$@"
}
