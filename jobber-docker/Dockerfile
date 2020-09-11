FROM ckotte/jobber:1.4.4
MAINTAINER Christian Kotte

# Image Build Date By Buildsystem
ARG BUILD_DATE=undefined

USER root

ENV DOCKER_VERSION=17.09.1-ce
ENV DOCKER_MACHINE_VERSION=v0.13.0

RUN apk add --update \
      gpgme \
      curl \
      py-pip \
      python3-dev \
      libffi-dev \
      openssl-dev && \
    pip install --upgrade pip && \
    # Install docker
    curl -L -o /tmp/docker-${DOCKER_VERSION}.tgz https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz && \
    tar -xz -C /tmp -f /tmp/docker-${DOCKER_VERSION}.tgz && \
    mv /tmp/docker/docker /usr/local/bin && \
    chmod +x /usr/local/bin/docker && \
    # Install docker-compose
    pip install docker-compose && \
    # Install docker-machine
    curl -L https://github.com/docker/machine/releases/download/${DOCKER_MACHINE_VERSION}/docker-machine-`uname -s`-`uname -m` > /usr/local/bin/docker-machine && \
    chmod +x /usr/local/bin/docker-machine && \
    # Clean caches and tmps
    rm -rf /var/cache/apk/* &&  \
    rm -rf /tmp/* &&  \
    rm -rf /var/log/*

# Image Metadata
LABEL com.opencontainers.application.jobber-docker.docker.version=$DOCKER_VERSION \
      com.opencontainers.application.jobber-docker.docker-machine.version=$DOCKER_MACHINE_VERSION \
      com.opencontainers.image.builddate.jobber-docker=${BUILD_DATE}

COPY imagescripts /opt/jobber-docker
ENTRYPOINT ["/opt/jobber-docker/docker-entrypoint.sh"]
CMD ["jobberd"]
