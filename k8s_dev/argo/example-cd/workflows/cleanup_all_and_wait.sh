#!/bin/bash

WORKFLOWS=(monitoring-cleanup-workflow.yaml sock-shop-cleanup-workflow.yaml logging-cleanup-workflow.yaml)

ARGO2="argo2"
SUCCEEDED="Succeeded"
FAILED="Failed"
SUBMITTED="Pending"

declare -a WORKFLOW_INSTANCES
declare -a WORKFLOW_DONE

function submit_workflows {
  for workflow in "${WORKFLOWS[@]}"
  do
    local out=$(${ARGO2} submit ${workflow})
    local ret=$?
    if [ ${ret} -ne 0 ]
    then
      echo "ERROR: Submitting ${workflow}"
      exit 1
    fi
    local instance=$(echo ${out} | cut -d ' ' -f 2)
    WORKFLOW_INSTANCES+=("${instance}")
    WORKFLOW_DONE+=("${SUBMITTED}")
  done
}

function check_workflows {
  for i in ${!WORKFLOW_INSTANCES[@]}
  do
    if [ "${WORKFLOW_DONE[$i]}" != "${SUBMITTED}" ]
    then
      continue
    fi
    local status=$(${ARGO2} list | grep "${WORKFLOW_INSTANCES[$i]}" | sed -E "s/[[:space:]]+/ /g" | cut -d ' ' -f 2)
    if [ "${status}" == "${SUCCEEDED}" ] || [ "${status}" == "${FAILED}" ]
    then
      WORKFLOW_DONE[$i]="${status}"
    fi
    echo "${WORKFLOW_INSTANCES[$i]}: status - ${status}"
  done
}

function print_all_workflows {
  for i in "${!WORKFLOW_INSTANCES[@]}"
  do
    echo "${WORKFLOWS[$i]}: instance ${WORKFLOW_INSTANCES[$i]}: status - ${WORKFLOW_DONE[$i]}"
  done
}

function all_done_exit {
  for i in "${!WORKFLOW_DONE[@]}"
  do
    if [ "${WORKFLOW_DONE[$i]}" == "${SUBMITTED}" ]
    then
      return
    fi
  done
  print_all_workflows
  exit 0
}

submit_workflows
while true
do
  check_workflows
  all_done_exit
  sleep 5
  echo "Waiting on workflows to finish"
done
