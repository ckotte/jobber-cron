#!/bin/bash

set -o errexit

if [ "$EUID" -eq 0 ]; then
  # Jobber files
  configfile="/root/.jobber"
  logfile="/var/log/jobber.log"
  run_logfile="/var/log/jobber-runs.log"
else
  # Jobber files
  configfile="/home/$(whoami)/.jobber"
  logfile="/home/$(whoami)/.jobber.log"
  run_logfile="/home/$(whoami)/.jobber-runs.log"
fi

if [ ! -f "${configfile}" ]; then
  touch ${configfile}

  # Set jobfile version and configure logging
  cat > ${configfile} <<_EOF_
version: 1.4

prefs:
  logPath: ${logfile}
  runLog:
    type: file
    path: ${run_logfile}
    maxFileLen: 100m
    maxHistories: 2

_EOF_

  # Configure jobs
  cat >> ${configfile} <<_EOF_
jobs:
_EOF_
  for (( i = 1; ; i++ ))
  do
    VAR_JOB_ON_ERROR="JOB_ON_ERROR$i"
    VAR_JOB_NAME="JOB_NAME$i"
    VAR_JOB_COMMAND="JOB_COMMAND$i"
    VAR_JOB_TIME="JOB_TIME$i"
    VAR_JOB_NOTIFY_ERR="JOB_NOTIFY_ERR$i"
    VAR_JOB_NOTIFY_FAIL="JOB_NOTIFY_FAIL$i"

    if [ ! -n "${!VAR_JOB_NAME}" ]; then
      break
    fi

    it_job_on_error=${!VAR_JOB_ON_ERROR:-"Continue"}
    it_job_name=${!VAR_JOB_NAME}
    it_job_time=${!VAR_JOB_TIME}
    it_job_command=${!VAR_JOB_COMMAND}
    it_job_notify_error=${!VAR_JOB_NOTIFY_ERR:-"false"}
    it_job_notify_failure=${!VAR_JOB_NOTIFY_FAIL:-"false"}

    cat >> ${configfile} <<_EOF_
  ${it_job_name}:
    cmd: ${it_job_command}
    time: '${it_job_time}'
    onError: ${it_job_on_error}
_EOF_
  done
fi

echo "${configfile}:"
cat ${configfile}

if [ "$1" = 'jobberd' ]; then
  exec /usr/local/libexec/jobberrunner -u /usr/local/var/jobber/${EUID}/cmd.sock ${configfile}
fi

exec "$@"
