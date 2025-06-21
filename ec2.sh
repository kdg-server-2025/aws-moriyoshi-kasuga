#!/usr/bin/env bash
set -Ceux
set -o pipefail

GITHUB_USERNAME="moriyoshi-kasuga"
curl https://github.com/${GITHUB_USERNAME}.keys -o ${GITHUB_USERNAME}.keys

mkdir -p /home/ubuntu/.ssh/
mv ${GITHUB_USERNAME}.keys /home/ubuntu/.ssh/authorized_keys

chmod 600 /home/ubuntu/.ssh/authorized_keys
