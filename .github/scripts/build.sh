#!/bin/bash
set -xe

# prepare tarfile before zip
if [ -f "$revision_key" ]; then
  rm "$revision_key"
fi
touch "$revision_key"

# zip
tar --exclude={"*.env","$revision_key"} -czf "$revision_key" .
