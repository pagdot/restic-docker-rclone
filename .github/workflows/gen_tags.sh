#!/bin/sh

RESTIC_VERSION=$(grep 'ARG RESTIC_VERSION=' Dockerfile | sed -E 's/.*=(.*)/\1/g')
RCLONE_VERSION=$(grep 'ARG RCLONE_VERSION=' Dockerfile | sed -E 's/.*=v(.*)/\1/g')

VER=( ${RESTIC_VERSION//./ } )

RESTIC_MAJOR=${VER[0]}
RESTIC_MINOR=${VER[1]}
RESTIC_PATCH=${VER[2]}

RESTIC_VERSION_TAGS+=(latest)
RESTIC_VERSION_TAGS+=("${RESTIC_MAJOR}")
RESTIC_VERSION_TAGS+=("${RESTIC_MAJOR}.${RESTIC_MINOR}")
RESTIC_VERSION_TAGS+=("${RESTIC_MAJOR}.${RESTIC_MINOR}.${RESTIC_PATCH}")

RESTIC_VERSION_TAGS+=("rclone-${RCLONE_VERSION}")
RESTIC_VERSION_TAGS+=("${RESTIC_MAJOR}_rclone-${RCLONE_VERSION}")
RESTIC_VERSION_TAGS+=("${RESTIC_MAJOR}.${RESTIC_MINOR}_rclone-${RCLONE_VERSION}")
RESTIC_VERSION_TAGS+=("${RESTIC_MAJOR}.${RESTIC_MINOR}.${RESTIC_PATCH}_rclone-${RCLONE_VERSION}")

BASES+=(${IMAGE_NAME})
BASES+=(ghcr.io/${IMAGE_NAME})

for b in "${BASES[@]}"
do
   for t in "${RESTIC_VERSION_TAGS[@]}"
   do
      TAGS+=( "${b}:${t}" )
   done
done


echo "TAGS<<EOF"
printf '%s\n' ${TAGS[@]}
echo "EOF"

echo "TAGS<<EOF" >> $GITHUB_ENV
printf '%s\n' ${TAGS[@]} >> $GITHUB_ENV
echo "EOF" >> $GITHUB_ENV
