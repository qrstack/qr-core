#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefall

echo "Waiting for MySQL..."

while ! nc -z mysql 4306; do
  sleep 1
done

echo "MySQL started"

exec "$@"