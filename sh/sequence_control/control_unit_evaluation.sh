#!/bin/bash
set -u

me_determine_next_action() {
  local ME_EXIT_CODE=$1
  local ME_FUNC_NAME=$2
  local ME_TRY_COUNT=$3

  local me_this_file

  local me_exit_normal=0
  local me_exit_error=1
  local me_exit_repeat_error=2
  local me_exit_fatal_error=3

  local me_this_file=${BASH_SOURCE[0]}

  if [ "${ME_EXIT_CODE}" -eq 0 ]; then
    #################################################################
    # normal state
    #################################################################

    if [ "${ME_TRY_COUNT}" -eq 1 ]; then
      # the first try
      printf '%s\n' ':'; return
    else
      printf 'return %d\n' "${me_exit_normal}"; return
    fi
  else
    #################################################################
    # NOT normal state
    #################################################################

    echo "ERROR:${me_this_file##*/}: failed at <${ME_FUNC_NAME}> with exit code <${ME_EXIT_CODE}>" 1>&2

    if [ "${ME_TRY_COUNT}" -gt 3 ]; then
      printf 'return %d\n' "${me_exit_repeat_error}"; return
    fi

    case "${ME_EXIT_CODE}" in
      212|213) me_boot_process ;;
      *)       :               ;;
    esac

    case "${ME_EXIT_CODE}" in
      1|210|212)
        # current evaluation
        printf '%s\n' ':'; return
        ;;
      211|213)
        # next evaluation
        printf 'return %d\n' "${me_exit_error}"; return
        ;;
      *)
        echo "ERROR:${this_file##*/}: unknown exit code <${ME_EXIT_CODE}>" 1>&2
        printf 'return %d\n' "${me_exit_fatal_error}"; return
        ;;
    esac
  fi
}

me_control_unit_evaluation() {
  local ME_EVAL_LOG_DIR=$1
  local ME_PARAM_FILE=$2
  local ME_PERIPHERAL_FILE=$3
  local ME_IMAGE_MD5SUM=$4
  local ME_PARAM_NUMBER=$5

  local me_exit_code
  local me_try_count
  local me_func_name
  local me_action
  local me_unit_eval_log_dir_base
  local me_unit_eval_log_dir
  local me_unit_eval_param_file
  local me_logdata_dir
  local me_evaldata_device_dir
  local me_evaldata_control_dir

  me_exit_code=0
  me_try_count=0
  me_func_name='me_control_initialize'

  while true; do
    me_try_count=$((me_try_count + 1))

    me_action=$(me_determine_next_action ${me_exit_code} ${me_func_name} ${me_try_count})
    eval "${me_action}"

    me_unit_eval_log_dir_base=$(printf '%02d_%02d\n' "${ME_PARAM_NUMBER}" "${me_try_count}")
    me_unit_eval_log_dir="${ME_EVAL_LOG_DIR}/${me_unit_eval_log_dir_base}"

    mkdir -p "${me_unit_eval_log_dir}"

    me_logdata_dir="${me_unit_eval_log_dir}/raw"
    me_evaldata_device_dir="${me_unit_eval_log_dir}/evaldata_device"
    me_evaldata_control_dir="${me_unit_eval_log_dir}/evaldata_control"
    me_unit_eval_param_file="${me_unit_eval_log_dir}/param.json"

    mkdir -p "${me_logdata_dir}"
    mkdir -p "${me_evaldata_device_dir}"
    mkdir -p "${me_evaldata_control_dir}"
    cp "${ME_PARAM_FILE}" "${me_unit_eval_param_file}"

    me_func_name=me_setup_evaluation
    eval "${me_func_name}"
    me_exit_code=$?; if [ "${me_exit_code}" -ne 0 ]; then continue; fi

    me_func_name=me_exec_evaluation
    eval "${me_func_name}" "${ME_PARAM_FILE}" "${me_logdata_dir}"
    me_exit_code=$?; if [ "${me_exit_code}" -ne 0 ]; then continue; fi

    me_func_name=me_cleanup_evaluation
    eval "${me_func_name}"
    me_exit_code=$?; if [ "${me_exit_code}" -ne 0 ]; then continue; fi

    me_func_name=me_judge_evaluation_execution
    eval "${me_func_name}" "${me_logdata_dir}"
    me_exit_code=$?; if [ "${me_exit_code}" -ne 0 ]; then continue; fi

    me_func_name=me_generate_evaluation_result
    eval "${me_func_name}" "${me_logdata_dir}" "${me_evaldata_device_dir}"
    me_exit_code=$?; if [ "${me_exit_code}" -ne 0 ]; then continue; fi

    me_func_name=me_supplement_evaldata
    eval "${me_func_name}" \
      -l"${me_logdata_dir}" -p"${ME_PERIPHERAL_FILE}" -m"${ME_IMAGE_MD5SUM}" \
      "${me_evaldata_device_dir}" "${me_evaldata_control_dir}"
    me_exit_code=$?; if [ "${me_exit_code}" -ne 0 ]; then continue; fi

    me_func_name=me_insert_evaldata_to_database
    eval "${me_func_name}" "${me_evaldata_control_dir}"
    me_exit_code=$?; if [ "${me_exit_code}" -ne 0 ]; then continue; fi
  done
}
