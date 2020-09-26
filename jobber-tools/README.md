# Dockerized Jobber-Cron plus additional tools

Includes:

* gpgme and gnupg
* wget and curl
* tar, gzip, zip, and unzip
* rsync
* pg_dump and pg_restore
* git and mercurial
* rclone

# GPG Public Keys

You can import a PGP public key and automatically trust the key (Necessary if the key isn't signed and if you want to use the key in batch jobs).

> Note: You should only automatically trust the key if it's your own key!

Example:

~~~~
$ docker run -d --name jobber \
    -v /some/directory:/backup
    -v /cloud/sync/directory:/cloud
    -e "GPG_PUBLIC_KEY=/backup/gpg/myown_public_key.asc" \
    -e "GPG_PUBLIC_KEY_ID=ABCDEFGH" \
    -e "AUTO_TRUST_GPG_PUBLIC_KEY=true" \
    -e "JOB_NAME1=backup" \
    -e "JOB_COMMAND1=gpgtar --encrypt --recipient "test" --output /cloud/test.tar.gpg /backup/xyz/" \
    -e "JOB_TIME1=0 0 2 * * *" \
    -e "JOB_ON_ERROR1=Continue" \
    ckotte/jobber:tools
~~~~

> Will compress and encrypt backup folder via gpgtar each day at 2am.
> You can use the fingerprint, the long key ID or the short key ID as the public key ID

# Rclone & Cloud Storage

You can use the command line program [rclone](https://rclone.org) to manage files on cloud storage. Rclone supports many [cloud storage providers](https://rclone.org#providers). However, a dynamic configuration is only supported for Dropbox and Google Drive. Alternatively, a rclone configuration file can be mapped inside the container.

Example (Dynamic configuration):

~~~~
$ docker run -d --name jobber \
    -e "JOB_NAME1=rclone" \
    -e "JOB_COMMAND1=rclone ls Dropbox: && rclone ls Google_Drive:" \
    -e "JOB_TIME1=0 0 2 * * *" \
    -e "JOB_ON_ERROR1=Continue" \
    -e "RCLONE_DROPBOX_NAME=Dropbox"
    -e "RCLONE_DROPBOX_TOKEN=iUbzKoSHcIsGGGAAAAAlilZVO31lKn9RQnc4uzMVbJEjn5WyLx1JnFI2xpLsHJDQ"
    -e "RCLONE_DROPBOX_TOKEN_TYPE=bearer"
    -e "RCLONE_DROPBOX_TOKEN_EXPIRY: "0001-01-01T00:00:00Z"
    -e "RCLONE_GOOGLE_DRIVE_NAME=Google_Drive"
    -e "RCLONE_GOOGLE_DRIVE_TOKEN=zb30.iUbzKoSHcIsGGGAAAAAlilZVO31lKn9RQnc4uzMVbJEjn5WyLx1JnFI2xpLsHJDQ"
    -e "RCLONE_GOOGLE_DRIVE_TOKEN_TYPE=bearer"
    -e "RCLONE_GOOGLE_DRIVE_REFRESH_TOKEN=2//iUbzKoSHcIsGGGAAAAAlilZVO31lKn9RQnc4uzMVbJEjn5WyLx1JnFI2xpLsHJDQ"
    -e "RCLONE_GOOGLE_DRIVE_TOKEN_EXPIRY=2020-08-17T18:03:42.301764255+02:00"
    -e "RCLONE_GOOGLE_DRIVE_ROOT_FOLDER_ID=0AEbE71WbqwYMUk9QVA"
    ckotte/jobber:tools
~~~~

Example (Existing configuration file):

~~~~
$ docker run -d --name jobber \
    -v "/rclone/config/directory:/root/.config/rclone"
    -e "JOB_NAME1=rclone" \
    -e "JOB_COMMAND1=rclone ls Dropbox:" \
    -e "JOB_TIME1=0 0 2 * * *" \
    -e "JOB_ON_ERROR1=Continue" \
    ckotte/jobber:tools
~~~~
