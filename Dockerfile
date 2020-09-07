FROM alpine:3.12
MAINTAINER Christian Kotte

# build parameters
ARG JOBBER_VERSION=1.3.3
# Image Build Date By Buildsystem
ARG BUILD_DATE=undefined

RUN export JOBBER_HOME=/tmp/jobber && \
    export JOBBER_LIB=$JOBBER_HOME/lib && \
    export GOPATH=/tmp && \
    export CONTAINER_UID=1000 && \
    export CONTAINER_GID=1000 && \
    export CONTAINER_USER=jobber && \
    export CONTAINER_GROUP=jobber && \
    # Add user
    addgroup -g $CONTAINER_GID $CONTAINER_USER && \
    adduser -u $CONTAINER_UID -G $CONTAINER_GROUP -s /bin/bash -S $CONTAINER_USER && \
    # Install tools
    apk add --update --no-cache \
      go \
      git \
      curl \
      wget \
      bash \
      su-exec \
      gzip \
      tar \
      tini \
      tzdata \
      make \
      musl-dev \
      rsync \
      grep && \
    # Compile and install Jobber
    mkdir -p "/var/jobber/${CONTAINER_UID}" && chown -R $CONTAINER_UID:$CONTAINER_GID "/var/jobber/${CONTAINER_UID}" && \
    mkdir -p "/var/jobber/0" && \
    cd /tmp && \
    mkdir -p src/github.com/dshearer && \
    cd src/github.com/dshearer && \
    git clone https://github.com/dshearer/jobber.git && \
    cd jobber && \
    git checkout v${JOBBER_VERSION} && \
    make check && \
    make install && \
    # Clean caches and tmps
    rm -rf /var/cache/apk/*                         &&  \
    rm -rf /tmp/*                                   &&  \
    rm -rf /var/log/*

# Image Metadata
LABEL com.opencontainers.application.jobber.version=$JOBBER_VERSION \
      com.opencontainers.image.builddate.jobber=${BUILD_DATE}

COPY docker-entrypoint.sh /opt/jobber/docker-entrypoint.sh
ENTRYPOINT ["/sbin/tini","--","/opt/jobber/docker-entrypoint.sh"]
CMD ["jobberd"]
