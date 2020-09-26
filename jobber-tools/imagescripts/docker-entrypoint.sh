#!/bin/bash

set -o errexit

[[ ${DEBUG} == true ]] && set -x

if [ "$EUID" -eq 0 ]; then
  mkdir -p /root/.config/rclone/
  rclone_configfile="/root/.config/rclone/rclone.conf"
else
  mkdir -p /home/$(whoami)/.config/rclone/
  rclone_configfile="/home/$(whoami)/.config/rclone/rclone.conf"
fi

if [ -n "${GPG_PRIVATE_KEY}" ]; then
  gpg --allow-secret-key-import --import ${GPG_PRIVATE_KEY}
fi

if [ -n "${GPG_PUBLIC_KEY}" ]; then
  gpg --import ${GPG_PUBLIC_KEY}
  if [ "${AUTO_TRUST_GPG_PUBLIC_KEY}" = "true" ]; then
    # gpg1
    # ID=$(keyVal=$(gpg --list-keys | awk '/pub/{if (length($2) > 0) print $2}'); echo "${keyVal##*/}")
    # echo "$( gpg --list-keys --fingerprint \
    #   | grep $ID -A 1 | tail -1 \
    #   | tr -d '[:space:]' | awk 'BEGIN { FS = "=" } ; { print $2 }' \
    # ):6:" | gpg --import-ownertrust &> /dev/null;
    # gpg2
    gpg --export-ownertrust && echo $GPG_PUBLIC_KEY_ID:6: | gpg --import-ownertrust
  fi
fi

if [ -n "${RCLONE_DROPBOX_NAME}" ] && \
   [ -n "${RCLONE_DROPBOX_TOKEN}" ] && \
   [ -n "${RCLONE_DROPBOX_TOKEN_TYPE}" ] && \
   [ -n "${RCLONE_DROPBOX_TOKEN_EXPIRY}" ]; then
  cat >> ${rclone_configfile} <<_EOF_
[${RCLONE_DROPBOX_NAME}]
type = dropbox
client_id =
client_secret =
token = {"access_token":"${RCLONE_DROPBOX_TOKEN}","token_type":"${RCLONE_DROPBOX_TOKEN_TYPE}","expiry":"${RCLONE_DROPBOX_TOKEN_EXPIRY}"}

_EOF_
fi

if [ -n "${RCLONE_GOOGLE_DRIVE_NAME}" ] && \
   [ -n "${RCLONE_GOOGLE_DRIVE_TOKEN}" ] && \
   [ -n "${RCLONE_GOOGLE_DRIVE_TOKEN_TYPE}" ] && \
   [ -n "${RCLONE_GOOGLE_DRIVE_REFRESH_TOKEN}" ] && \
   [ -n "${RCLONE_GOOGLE_DRIVE_TOKEN_EXPIRY}" ] && \
   [ -n "${RCLONE_GOOGLE_DRIVE_ROOT_FOLDER_ID}" ]; then
  cat >> ${rclone_configfile} <<_EOF_
[${RCLONE_GOOGLE_DRIVE_NAME}]
type = drive
scope = drive
token = {"access_token":"${RCLONE_GOOGLE_DRIVE_TOKEN}","token_type":"${RCLONE_GOOGLE_DRIVE_TOKEN_TYPE}","refresh_token":"${RCLONE_GOOGLE_DRIVE_REFRESH_TOKEN}","expiry":"${RCLONE_GOOGLE_DRIVE_TOKEN_EXPIRY}"}
root_folder_id = ${RCLONE_GOOGLE_DRIVE_ROOT_FOLDER_ID}

_EOF_
fi

/opt/jobber/docker-entrypoint.sh "$@"
