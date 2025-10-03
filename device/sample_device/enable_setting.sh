#!/bin/bash

me_setup_all() {
  echo 'start: setup all'
  sleep 1
  echo 'end:   setup all'
}

me_setup_evaluation() {
  echo 'start: setup evaluation'
  sleep 1
  echo 'end:   setup evaluation'
}

me_exec_evaluation() {
  local PARAM_FILE=$1
  local LOG_DIR=$2

  local input_1
  local input_2
  local input_3

  echo "start: exec evaluation <${PARAM_FILE},${LOG_DIR}>"

  input_1=$(jq -r '.input_1' "${PARAM_FILE}")
  input_2=$(jq -r '.input_2' "${PARAM_FILE}")
  input_3=$(jq -r '.input_3' "${PARAM_FILE}")

  cat <<__EOF | sed 's!^ *!!'
  input_1 = "${input_1}"
  input_2 = "${input_2}"
  input_3 = "${input_3}"
__EOF

  var_input_1=${input_1}
  var_input_2=${input_2}
  var_input_3=${input_3}

  sleep 1
  echo "end:   exec evaluation <${PARAM_FILE},${LOG_DIR}>"
}

me_cleanup_evaluation() {
  echo 'start: cleanup evaluation'
  sleep 1
  echo 'end:   cleanup evaluation'
}

me_judge_evaluation_execution() {
  local LOG_DIR=$1

  echo "start: judge evaluation execution <${LOG_DIR}>"
  sleep 1
  echo "end:   judge evaluation execution <${LOG_DIR}>"
}

me_generate_evaluation_result() {
  local LOG_DIR=$1
  local EVALDATA_DIR=$2

  echo "start: generate evaluation result <${LOG_DIR},${EVALDATA_DIR}>"

  cat <<__EOF | jq . >"${EVALDATA_DIR}/evaldata.json"
  {
    "in": {
      "input_1": ${var_input_1},
      "input_2": "${var_input_2}",
      "input_3": "${var_input_3}"
    },

    "out": {
      "output_1": 10,
      "output_2": "This is the value of output 2",
      "output_3": "This is the value of output 3"
    },

    "procedure_url": "http://sample.com",
    "free_description": "This is the free description"
  }
__EOF

  sleep 1
  echo "end:   generate evaluation result <${LOG_DIR},${EVALDATA_DIR}>"
}

me_cleanup_all() {
  echo 'start: cleanup all'
  sleep 1
  echo 'end:   cleanup all'
}
