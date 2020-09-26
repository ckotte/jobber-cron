#!/bin/bash

# set -o errexit

[[ ${DEBUG} == true ]] && set -x

SUBJECT=""
NAME=""
BODY=""

usage() {
  echo "Usage: $0 [ -s SUBJECT ] [-n NAME] [ -b HTML_BODY ] [-h]" 1>&2
}

exit_abnormal() {
  usage
  exit 1
}

while getopts "hs:n:b:" options; do
  case "${options}" in
    h)
      usage
      exit 0
      ;;
    s)
      SUBJECT=${OPTARG}
      ;;
    n)
      NAME=${OPTARG}
      ;;
    b)
      BODY=${OPTARG}
      ;;
    :)
      echo "Error: -${OPTARG} requires an argument."
      exit_abnormal
      ;;
    *)
      exit_abnormal
      ;;
  esac
done

if [ -z "$NAME" ]; then
  if [ -n "${MAIL_FROM_NAME}" ]; then
    if [ "${MAIL_FROM_NAME}" = "hostname" ]; then
      FROM="${HOSTNAME} <${MAIL_ADDRESS}>"
    else
      FROM="${MAIL_FROM_NAME} <${MAIL_ADDRESS}>"
    fi
  else
    FROM="jobber <${MAIL_ADDRESS}>"
  fi
else
  FROM="${NAME} <${MAIL_ADDRESS}>"
fi

sendmail ${MAIL_ADDRESS} <<MAIL_END
Subject: ${SUBJECT}
From: ${FROM}
Content-Type: text/html; charset="utf8"

${BODY}
MAIL_END
