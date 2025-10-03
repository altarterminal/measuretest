#!/bin/bash
set -u

me_check_interface_implement() {
  local this_file

  this_file=${BASH_SOURCE[0]}

  cat <<__EOF | sed 's!^ *!!' |
    me_setup_all
    me_setup_evaluation
    me_exec_evaluation
    me_cleanup_evaluation
    me_judge_evaluation_execution
    me_generate_evaluation_result
    me_cleanup_all
__EOF
    while read -r func_name; do
      if ! type "${func_name}" >/dev/null 2>&1; then
        echo "ERROR:${this_file##*/}: NOT defined <${func_name}>" 1>&2
        echo 'e'
      fi
    done |
    awk 'END { if (NR > 0) { exit 1; } }'
}
