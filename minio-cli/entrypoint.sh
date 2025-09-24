#!/bin/sh -l
set -euo pipefail

ls -la

mc alias set deploy $MINIO_ENDPOINT $MINIO_ACCESS_KEY $MINIO_SECRET_KEY --api S3v4

mc cp $1 "deploy/$2"
