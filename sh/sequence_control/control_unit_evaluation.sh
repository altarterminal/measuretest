#!/bin/bash
set -u

me_determine_next_action_before_judge_error() {
  local ME_EXIT_CODE=$1

  local me_this_file

  me_this_file=$(realpath "${BASH_SOURCE[0]}")

  case "${ME_EXIT_CODE}" in
    "${ME_ERROR_GENERAL}"|\
    "${ME_ERROR_TO_RETRY}"|\
    "${ME_ERROR_WITH_REBOOT_TO_RETRY}")
      printf '%s\n' ':'
      ;;
    "${ME_ERROR_TO_NEXT}"|\
    "${ME_ERROR_WITH_REBOOT_TO_NEXT}")
      printf 'return %d\n' "${ME_CONTROL_ERROR}"
      ;;
    *)
      echo "ERROR:${me_this_file##*/}: unknown exit code <${ME_EXIT_CODE}>" 1>&2
      printf 'return %d\n' "${ME_CONTROL_FATAL_ERROR}"
      ;;
  esac
}

me_determine_next_action_after_judge_error() {
  local ME_EXIT_CODE=$1

  local me_this_file

  me_this_file=$(realpath "${BASH_SOURCE[0]}")

  case "${ME_EXIT_CODE}" in
    "${ME_ERROR_GENERAL}"|\
    "${ME_ERROR_TO_NEXT}"|\
    "${ME_ERROR_WITH_REBOOT_TO_NEXT}")
      printf 'return %d\n' "${ME_CONTROL_ERROR}"
      ;;
    "${ME_ERROR_TO_RETRY}"|\
    "${ME_ERROR_WITH_REBOOT_TO_RETRY}")
      echo "WARN:${me_this_file##*/}: invalid exit code from func after judge <${ME_EXIT_CODE}>" 1>&2
      printf 'return %d\n' "${ME_CONTROL_ERROR}"
      ;;
    *)
      echo "ERROR:${me_this_file##*/}: unknown exit code <${ME_EXIT_CODE}>" 1>&2
      printf 'return %d\n' "${ME_CONTROL_FATAL_ERROR}"
      ;;
  esac
}

me_determine_next_action() {
  local ME_EXIT_CODE=$1
  local ME_FUNC_NAME=$2
  local ME_TRY_COUNT=$3

  local me_this_file

  me_this_file=$(realpath "${BASH_SOURCE[0]}")

  if [ "${ME_EXIT_CODE}" -eq 0 ]; then
    #################################################################
    # normal state
    #################################################################

    if [ "${ME_TRY_COUNT}" -eq 1 ]; then
      # the first try
      printf '%s\n' ':'
    else
      printf 'return %d\n' '0'
    fi
  else
    #################################################################
    # NOT normal state
    #################################################################

    printf 'ERROR:%s: failed at <%s> with exit code <%s>\n' \
      "${me_this_file##*/}" "${ME_FUNC_NAME}" "${ME_EXIT_CODE}" 1>&2

    if [ "${ME_TRY_COUNT}" -gt 3 ]; then
      printf 'return %d\n' "${ME_CONTROL_REPEAT_ERROR}"
      return
    fi

    case "${ME_EXIT_CODE}" in
      "${ME_ERROR_WITH_REBOOT_TO_NEXT}"|\
      "${ME_ERROR_WITH_REBOOT_TO_RETRY}")
        me_boot_process
        ;;
      *)
        :
        ;;
    esac

    case "${ME_FUNC_NAME}" in
      'me_setup_evaluation'|\
      'me_exec_evaluation'|\
      'me_cleanup_evaluation'|\
      'me_judge_evaluation_execution')
        me_determine_next_action_before_judge_error "${ME_EXIT_CODE}"
        ;;
      'me_generate_evaluation_result')
        me_determine_next_action_after_judge_error "${ME_EXIT_CODE}"
        ;;
      'me_supplement_evaldata'|\
      'me_insert_evaldata_to_database')
        printf 'return %d\n' "${ME_CONTROL_ERROR}"
        ;;
      *)
        echo "ERROR:${me_this_file##*/}: unknown exit code <${ME_EXIT_CODE}>" 1>&2
        printf 'return %d\n' "${ME_CONTROL_FATAL_ERROR}"
        ;;
    esac
  fi
}

me_control_unit_evaluation() {
  local ME_DEVICE_NAME=$1
  local ME_EVAL_LOG_DIR=$2
  local ME_PARAM_FILE=$3
  local ME_PERIPHERAL_FILE=$4
  local ME_IMAGE_MD5SUM=$5
  local ME_PARAM_NUMBER=$6

  local me_exit_code
  local me_try_count
  local me_func_name
  local me_action
  local me_unit_eval_log_dir_base
  local me_unit_eval_log_dir
  local me_logdata_dir
  local me_evaldata_device_dir
  local me_evaldata_control_dir
  local me_unit_eval_param_file

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
    if [ "${ME_PARAM_NUMBER}" -eq 1 ]; then
      eval "${me_func_name}"    "${ME_DEVICE_NAME}" "${me_evaldata_control_dir}"
    else
      eval "${me_func_name}" -g "${ME_DEVICE_NAME}" "${me_evaldata_control_dir}"
    fi
    me_exit_code=$?; if [ "${me_exit_code}" -ne 0 ]; then continue; fi
  done
}
