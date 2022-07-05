#!/bin/bash

set -eu


S3_BASE_URI=s3://${BUCKET_NAME:?required}

echo ">>>> UPLOADING FILE S3"
aws s3 mv buildspec.yml "${S3_BASE_URI}/buildspec.yml"

