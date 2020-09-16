#!/bin/bash

set -o errexit

if [ "$EUID" -eq 0 ]; then
  # Jobber files
  configfile="/root/.jobber"
  logfile="/var/log/jobber.log"
  run_logfile="/var/log/jobber-runs.log"
  # ssmtp files
  ssmtp_configfile="/root/.msmtprc"
  ssmtp_aliasfile="/root/.msmtp_aliases"
  ssmtp_logfile="/var/log/msmtp.log"
else
  mkdir "/home/$(whoami)/log"
  # Jobber files
  configfile="/home/$(whoami)/.jobber"
  logfile="/home/$(whoami)/log/jobber.log"
  run_logfile="/home/$(whoami)/log/jobber-runs.log"
  # ssmtp files
  ssmtp_configfile="/home/$(whoami)/.msmtprc"
  ssmtp_aliasfile="/home/$(whoami)/.msmtp_aliases"
  ssmtp_logfile="/home/$(whoami)/log/msmtp.log"
fi

# Configure msmtp
cat > ${ssmtp_configfile} <<_EOF_
# msmtp configuration

# Set default values for all following accounts
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        ${ssmtp_logfile}

# Mail account
account        external
host           ${MAIL_SERVER}
port           ${MAIL_SERVER_PORT}
from           ${MAIL_ADDRESS}
user           ${MAIL_ADDRESS}
password       ${MAIL_PASSWORD}

# Set a default account
account default : external

# Aliases (Replace local recipients with addresses in the aliases file)
aliases		~/.msmtp_aliases
_EOF_

chmod 0600 ${ssmtp_configfile}

# Create aliases for local usernames
cat > ${ssmtp_aliasfile} <<_EOF_
# Aliases

# Send everything to external email address
default: ${MAIL_ADDRESS}
_EOF_

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
    VAR_JOB_NOTIFY_SUCC="JOB_NOTIFY_SUCC$i"
    VAR_JOB_NOTIFY_ERR="JOB_NOTIFY_ERR$i"
    VAR_JOB_NOTIFY_FAIL="JOB_NOTIFY_FAIL$i"

    if [ ! -n "${!VAR_JOB_NAME}" ]; then
      break
    fi

    it_job_on_error=${!VAR_JOB_ON_ERROR:-"Continue"}
    it_job_name=${!VAR_JOB_NAME}
    it_job_time=${!VAR_JOB_TIME}
    it_job_command=${!VAR_JOB_COMMAND}
    it_job_notify_success=${!VAR_JOB_NOTIFY_SUCC:-"false"}
    it_job_notify_error=${!VAR_JOB_NOTIFY_ERR:-"false"}
    it_job_notify_failure=${!VAR_JOB_NOTIFY_FAIL:-"false"}

    cat >> ${configfile} <<_EOF_
  ${it_job_name}:
    cmd: ${it_job_command}
    time: '${it_job_time}'
    onError: ${it_job_on_error}
_EOF_

  if [ "${it_job_notify_success}" = "true" ]; then
    cat >> ${configfile} <<_EOF_
    notifyOnSuccess:
      - type: program
        path: /usr/local/bin/send_email.sh
_EOF_
  fi
  if [ "${it_job_notify_error}" = "true" ]; then
    cat >> ${configfile} <<_EOF_
    notifyOnError:
      - type: program
        path: /usr/local/bin/send_email.sh
_EOF_
  fi
  if [ "${it_job_notify_failure}" = "true" ]; then
    cat >> ${configfile} <<_EOF_
    notifyOnFailure:
      - type: program
        path: /usr/local/bin/send_email.sh
_EOF_
  fi
  done
fi

echo "${configfile}:"
cat ${configfile}

if [ "$1" = 'jobberd' ]; then
  exec /usr/local/libexec/jobberrunner -u /usr/local/var/jobber/${EUID}/cmd.sock ${configfile}
fi

exec "$@"
