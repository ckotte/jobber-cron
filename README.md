# Dockerized Jobber Cron

Docker container cron alternative with jobber.

## Supported tags and respective Dockerfile links

| Bundle | Version | Dockerfile | Readme |
|--------|---------|------------|--------|
| Jobber | 1.4.4 | [Dockerfile](https://github.com/ckotte/jobber-cron/blob/master/Dockerfile) | [Readme](https://github.com/ckotte/jobber-cron/blob/master/README.md) |
| Jobber + Tools | 1.4.4 | [Dockerfile](https://github.com/ckotte/jobber-cron/blob/master/jobber-tools/Dockerfile) | [Readme](https://github.com/ckotte/jobber-cron/blob/master/jobber-tools/README.md) |
| Jobber + Docker Tools | 1.4.4 | [Dockerfile](https://github.com/ckotte/jobber-cron/blob/master/jobber-docker/Dockerfile) | [Readme](https://github.com/ckotte/jobber-cron/blob/master/jobber-docker/README.md) |


# Make It Short!

In short, you can define periodic tasks for an arbitrary number of jobs.

Example:

~~~~
$ docker run -d \
    --name jobber \
    -e "JOB_NAME1=TestEcho" \
    -e "JOB_COMMAND1=echo hello world" \
    ckotte/jobber
~~~~

> Will print "hello world" to console every second.

# How It Works

The environment variables are numerated. Just add the number behind the environment variable and
the container will create a job definition for Jobber!

This way the container can handle an arbitrary number of jobs without file handling or cumbersome syntax!

Example with two tasks:

~~~~
$ docker run -d \
    --name jobber \
    -e "JOB_NAME1=TestEcho" \
    -e "JOB_COMMAND1=echo hello world" \
    -e "JOB_NAME2=TestEcho" \
    -e "JOB_COMMAND2=echo hello moon" \
    ckotte/jobber
~~~~

> First job will print "hello world" and then second job will print "hello moon" to console every second.

# Environment Variables

You can define the following global variables if Jobber should send an email after job execution:

* MAIL_SERVER: The mail server FQDN.
* MAIL_SERVER_PORT: The mail server port.
* MAIL_ADDRESS: The email address used to login and send emails.
* MAIL_PASSWORD: The password used to login.
* MAIL_FROM_NAME: Specify the name in the from field. Values: any text or `hostname` to use the hostname variable. Default is `jobber`.

Note: TLS is enabled by default and cannot be disabled.

Every job definition is specified by up to four environment variables:

* JOB_NAME: The identifier for the job, must not contain empty spaces!
* JOB_COMMAND: The bash command to be executed.
* JOB_TIME: The cron schedule for the job. See [Documentation](https://dshearer.github.io/jobber/doc/v1.4/#time-strings)
* JOB_ON_ERROR: How Jobber should act on errors. Values: Stop, Backoff, Continue (Default). See [Documentation](https://dshearer.github.io/jobber/doc/v1.4/#error-handling)
* JOB_NOTIFY_SUCC: If Jobber should send an email on job success. Values: `true`, `false`. Default is `false`. See [Documentation](https://dshearer.github.io/jobber/doc/v1.4/#notifications)
* JOB_NOTIFY_ERR: If Jobber should send an email on job error. Values: `true`, `false`. Default is `false`
* JOB_NOTIFY_FAIL: If Jobber should send an email when the job status is set to `Failed`. Values: `true`, `false`. Default is `false`

Full example:

~~~~
$ docker run -d \
    --name jobber \
    -e "MAIL_SERVER=mail.gmx.net" \
    -e "MAIL_SERVER_PORT=587" \
    -e "MAIL_ADDRESS=some.email.address@gmx.de" \
    -e "MAIL_PASSWORD=Secr3tPassw0rd" \
    -e "MAIL_FROM_NAME=hostname" \
    -e "JOB_NAME1=TestEcho" \
    -e "JOB_COMMAND1=echo hello world" \
    -e "JOB_TIME1=1" \
    -e "JOB_ON_ERROR1=Backoff" \
    -e "JOB_NOTIFY_SUCC1=false" \
    -e "JOB_NOTIFY_ERR1=true" \
    -e "JOB_NOTIFY_FAIL1=true" \
    ckotte/jobber
~~~~

> Will print "hello world" at second 1 of every minute.

# The Cron Time

When it comes to the cron string then Jobber is a little bit different. If you do not
define any time then the resulting cron table will be

~~~~
* * * * * *
~~~~

and the job will be executed every second.

You can also define just one number "1". This will be interpreted as

~~~~
1 * * * * *
~~~~

Example:

~~~~
$ docker run \
    --name jobber \
    -e "JOB_NAME1=TestEcho" \
    -e "JOB_COMMAND1=echo hello world" \
    -e "JOB_TIME1=1 * * * * *"
    ckotte/jobber
~~~~

> Will print "hello world" every second.

so you can see that you have to specify the time string from the back and the rest will be filled up by Jobber.

As a reminder, cron timetable is like follows:

1. Token: Second
1. Token: Minute
1. Token: Hour
1. Token: Day of Month
1. Token: Month
1. Token: Day of Week

# Send Email Script

Jobs can use the embedded script /usr/local/bin/send_email.sh to send custom HTML emails. The script uses the global email variables and it provides a few parameters to compose the email. Execute ```/usr/local/bin/send_email.sh -h``` for more details.

Example:

~~~~
/usr/local/bin/send_email.sh -s "Test" -b "<b>This is a test</b>"
~~~~

> Will send a test email to the configured email address.

# References

* [Jobber](https://github.com/dshearer/jobber)
* [Docker Homepage](https://www.docker.com/)
* [Docker Userguide](https://docs.docker.com/userguide/)
