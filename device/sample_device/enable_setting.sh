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

  echo "start: exec evaluation <${PARAM_FILE},${LOG_DIR}>"
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
  sleep 1
  echo "end:   generate evaluation result <${LOG_DIR},${EVALDATA_DIR}>"
}

me_cleanup_all() {
  echo 'start: cleanup all'
  sleep 1
  echo 'end:   cleanup all'
}
