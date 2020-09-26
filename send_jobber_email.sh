#!/bin/bash

# set -o errexit

[[ ${DEBUG} == true ]] && set -x

read stdin

# {
#     "job": {
#         "command": "cat 'hello world'",
#         "name": "TestFail",
#         "status": "Failed",
#         "time": "*/60 * * * * *"
#     },
#     "startTime": "Sep 13 17:35:00 2020",
#     "stderr": "cat: can't open 'hello world': No such file or directoryn",
#     "stderr_base64": false,
#     "stdout": "",
#     "stdout_base64": false,
#     "succeeded": false,
#     "user": "root"
# }

job_name=$(echo "$stdin" | jq '.job.name')
# job_command=$(echo "$stdin" | jq '.job.command')
job_status=$(echo "$stdin" | jq '.job.status')

succeeded=$(echo "$stdin" | jq '.succeeded')
# stdout=$(echo "$stdin" | jq '.stdout')
# stderr=$(echo "$stdin" | jq '.stderr')

if [ "${succeeded}" = "true" ]; then
  subject="Successfully executed job ${job_name}"
  text="Successfully executed the job ${job_name} on container ${HOSTNAME}"
else
  subject="Error occurred during execution of job ${job_name}"
  text="An error occurred during execution of the job ${job_name} on container ${HOSTNAME}"
  if [ "${job_status}" = '"Failed"' ]; then
    text="An error occurred during execution of job ${job_name} on container ${HOSTNAME}. The job is now in failure state."
  fi
fi

if [ -n "${MAIL_FROM_NAME}" ]; then
  if [ "${MAIL_FROM_NAME}" = "hostname" ]; then
    FROM="${HOSTNAME} <${MAIL_ADDRESS}>"
  else
    FROM="${MAIL_FROM_NAME} <${MAIL_ADDRESS}>"
  fi
else
  FROM="jobber <${MAIL_ADDRESS}>"
fi

json=$(echo "$stdin" | python3 -m json.tool)
sendmail ${MAIL_ADDRESS} <<MAIL_END
Subject: ${subject}
From: ${FROM}

$text

$json
MAIL_END
