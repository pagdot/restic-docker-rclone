FROM lsiobase/alpine:3.21 AS downloader

RUN apk --no-cache add wget unzip

ARG TARGETPLATFORM

ARG RCLONE_VERSION=v1.69.1

RUN echo Building for target ${TARGETPLATFORM}

RUN case ${TARGETPLATFORM} in "linux/amd64") ARCH=amd64;; "linux/arm/v7") ARCH=arm-v7;; "linux/arm64") ARCH=arm64;; esac && \
   wget -q https://downloads.rclone.org/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-${ARCH}.zip && \
   unzip rclone-${RCLONE_VERSION}-linux-${ARCH}.zip && \
   mv rclone-${RCLONE_VERSION}-linux-${ARCH}/rclone /rclone

ARG RESTIC_VERSION=0.17.3
RUN case ${TARGETPLATFORM} in "linux/amd64") ARCH=amd64;; "linux/arm/v7") ARCH=arm;; "linux/arm64") ARCH=arm64;; esac && \
   wget -q https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_${ARCH}.bz2 && \
   bzip2 -d restic_${RESTIC_VERSION}_linux_${ARCH}.bz2 && \
   mv restic_${RESTIC_VERSION}_linux_${ARCH} /restic && \
   chmod +x /restic

RUN RCLONE_VERSION=true /rclone version && \
   /restic version

# Begin final image
FROM lsiobase/alpine:3.21

RUN apk --no-cache add curl

ENV RCLONE_CONFIG=/tmp/rclone.conf
ENV RCLONE_CACHE_DIR=/cache/rclone
ENV RESTIC_CACHE_DIR=/cache/restic

COPY --from=downloader /rclone /usr/local/bin/
COPY --from=downloader /restic /usr/local/bin/
COPY root/ /

VOLUME /config

WORKDIR /config
